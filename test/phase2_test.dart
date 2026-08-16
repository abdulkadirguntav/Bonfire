import 'package:flutter_test/flutter_test.dart';
import 'package:bonfire/domain/models/character_class.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/domain/services/boss_service.dart';
import 'package:bonfire/domain/services/stamina_service.dart';
import 'package:bonfire/domain/services/task_economy_service.dart';

void main() {
  group('1. Bug Fix - Stamina Hesaplama ve Görev Silme / Geri Alma', () {
    test('uncompleted task deletion does NOT touch stamina or essence', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      ).copyWith(currentStamina: 30, essence: 50);

      // Simulating deleting an uncompleted task:
      // When isCompleted is false, refund should not happen
      expect(user.currentStamina, 30);
      expect(user.essence, 50);
    });

    test('completed task deletion refunds stamina but NEVER exceeds maxStamina', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior, // maxStamina = 100
      ).copyWith(currentStamina: 90, essence: 100);

      // A Physical task (+40 stamina refund) is deleted
      final refundedUser = StaminaService.refundCompletion(
        user,
        TaskCategory.physical,
      );

      // 90 + 40 = 130 -> Clamped at maxStamina (100)
      expect(refundedUser.currentStamina, 100);
      expect(refundedUser.currentStamina <= user.maxStamina, isTrue);
    });

    test('toggling task complete when cost > stamina clamps stamina to 0 and never goes negative', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      ).copyWith(currentStamina: 20); // 20 stamina remaining

      final spentUser = StaminaService.spendForCompletion(
        user,
        TaskCategory.physical, // cost = 40
      );

      // 20 - 40 = -20 -> Clamped to 0
      expect(spentUser.currentStamina, 0);
      expect(StaminaService.isExhausted(spentUser), isTrue);
    });

    test('unchecking a completed task refunds stamina capped at maxStamina and deducts essence', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      ).copyWith(currentStamina: 80, essence: 100);

      final undoneUser = StaminaService.refundCompletion(
        user,
        TaskCategory.physical, // cost = 40
      ).copyWith(
        essence: (user.essence - TaskEconomyService.rewardFor(TaskCategory.physical, user: user))
            .clamp(0, 1 << 31),
      );

      expect(undoneUser.currentStamina, 100); // 80 + 40 -> 100
      expect(undoneUser.essence, 60); // 100 - 40
    });
  });

  group('2. Karakter Sınıfları (Character Classes)', () {
    test('Warrior has 150 HP, 100 Stamina, 0.8x damage, 1.0x essence', () {
      const warrior = CharacterClass.warrior;
      expect(warrior.baseHp, 150);
      expect(warrior.maxStamina, 100);
      expect(warrior.damageMultiplier, 0.8);
      expect(warrior.essenceMultiplier, 1.0);

      final user = User.create(id: 'u-warrior', selectedClass: warrior);
      expect(user.currentHp, 150);
      expect(user.maxHp, 150);
      expect(user.currentStamina, 100);
      expect(user.maxStamina, 100);
    });

    test('Mage has 80 HP, 150 Stamina, 1.0x damage, 1.2x essence', () {
      const mage = CharacterClass.mage;
      expect(mage.baseHp, 80);
      expect(mage.maxStamina, 150);
      expect(mage.damageMultiplier, 1.0);
      expect(mage.essenceMultiplier, 1.2);

      final user = User.create(id: 'u-mage', selectedClass: mage);
      expect(user.currentHp, 80);
      expect(user.maxHp, 80);
      expect(user.currentStamina, 150);
      expect(user.maxStamina, 150);

      // Reward multiplier test: 40 * 1.2 = 48
      expect(TaskEconomyService.rewardFor(TaskCategory.physical, user: user), 48);
    });

    test('Prisoner has 50 HP, 70 Stamina, 1.5x damage, 1.5x essence', () {
      const prisoner = CharacterClass.prisoner;
      expect(prisoner.baseHp, 50);
      expect(prisoner.maxStamina, 70);
      expect(prisoner.damageMultiplier, 1.5);
      expect(prisoner.essenceMultiplier, 1.5);

      final user = User.create(id: 'u-prisoner', selectedClass: prisoner);
      expect(user.currentHp, 50);
      expect(user.maxHp, 50);
      expect(user.currentStamina, 70);
      expect(user.maxStamina, 70);

      // Reward multiplier test: 40 * 1.5 = 60
      expect(TaskEconomyService.rewardFor(TaskCategory.physical, user: user), 60);

      // Damage penalty test: 10 * 1.5 (class) = 15
      final normalTask = Task(
        id: 't1',
        title: 'Task 1',
        category: TaskCategory.routine,
        healthDamage: 10,
        createdAt: DateTime.now(),
      );
      expect(TaskEconomyService.penaltyFor(normalTask, user: user), 15);

      // Exhausted damage penalty test: 10 * 1.5 (exhausted) * 1.5 (class) = 22.5 -> 23
      final exhaustedTask = Task(
        id: 't2',
        title: 'Task 2',
        category: TaskCategory.routine,
        healthDamage: 10,
        createdAt: DateTime.now(),
        acceptedWhileExhausted: true,
      );
      expect(TaskEconomyService.penaltyFor(exhaustedTask, user: user), 23);
    });
  });

  group('3. Uzun Vadeli Boss (Bağımlılık) Sistemi', () {
    test('Boss creation initializes with 30 HP and Phase 1', () {
      final boss = BossService.createBoss(title: 'Sigarayı Bırak', initialHp: 30);
      expect(boss.title, 'Sigarayı Bırak');
      expect(boss.currentHp, 30);
      expect(boss.maxHp, 30);
      expect(boss.phase, 1);
    });

    test('Direndim (Resisted) reduces Boss HP by 1 and grants Essence', () {
      final boss = BossService.createBoss(title: 'Sigarayı Bırak', initialHp: 30);
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.mage, // 1.2x essence multiplier
      );

      final result = BossService.resist(boss: boss, user: user);
      expect(result.boss.currentHp, 29);
      expect(result.didPhaseMutate, isFalse);
      expect(result.essenceGained, 30); // 25 * 1.2 = 30
      expect(result.user.essence, 30);
    });

    test('Yenildim (Failed) damages user and heals Boss (+1 HP up to maxHp)', () {
      final boss = BossService.createBoss(title: 'Sigarayı Bırak', initialHp: 30)
          .copyWith(currentHp: 25);
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior, // 0.8x damage multiplier
      );

      final result = BossService.fail(boss: boss, user: user);
      expect(result.boss.currentHp, 26); // 25 + 1
      expect(result.damageTaken, 32); // 40 * 0.8 = 32
      expect(result.user.currentHp, 118); // 150 - 32 = 118
    });

    test('Failed cannot heal boss beyond maxHp', () {
      final boss = BossService.createBoss(title: 'Sigarayı Bırak', initialHp: 30);
      final user = User.create(id: 'u1', selectedClass: CharacterClass.warrior);

      final result = BossService.fail(boss: boss, user: user);
      expect(result.boss.currentHp, 30); // Capped at maxHp (30)
    });

    test('Phase Mutation: when Boss HP reaches 0, mutates to Phase 2 with 90 HP and grants massive Essence', () {
      final boss = BossService.createBoss(title: 'Sigarayı Bırak', initialHp: 30)
          .copyWith(currentHp: 1, phase: 1);
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior, // 1.0x multiplier
      );

      final result = BossService.resist(boss: boss, user: user);
      expect(result.didPhaseMutate, isTrue);
      expect(result.boss.phase, 2);
      expect(result.boss.maxHp, 90);
      expect(result.boss.currentHp, 90);
      expect(result.essenceGained, 225); // 25 (daily) + 200 (phase bonus) = 225
      expect(result.user.essence, 225);
    });
  });
}
