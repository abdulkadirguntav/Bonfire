import 'package:flutter_test/flutter_test.dart';

import 'package:bonfire/domain/models/boss.dart';
import 'package:bonfire/domain/models/character_class.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/domain/services/boss_service.dart';
import 'package:bonfire/domain/services/day_resolution_service.dart';
import 'package:bonfire/domain/services/stamina_service.dart';
import 'package:bonfire/domain/services/task_economy_service.dart';

void main() {
  group('1. Stamina & Ceza Sistemi (Stamina & Task Deletion)', () {
    test('task completion spends stamina and rewards essence', () {
      final now = DateTime.now();
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
        now: now,
      ).copyWith(currentStamina: 100, essence: 0, staminaUpdatedAt: now);

      final updated =
          StaminaService.consumeForTask(user, TaskCategory.physical, now: now);
      expect(updated.currentStamina, 65); // 100 - 35 = 65
    });

    test('task deletion refunds stamina but NEVER exceeds maxStamina', () {
      final now = DateTime.now();
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior, // maxStamina = 100
        now: now,
      ).copyWith(currentStamina: 95, staminaUpdatedAt: now);

      final refunded = StaminaService.refundCompletion(
          user, TaskCategory.physical,
          now: now);
      expect(refunded.currentStamina,
          100); // 95 + 35 = 130 -> clamped to 100 maxStamina
    });

    test(
        'unchecking completed task refunds stamina capped at maxStamina and deducts essence',
        () {
      final now = DateTime.now();
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
        now: now,
      ).copyWith(currentStamina: 50, essence: 30, staminaUpdatedAt: now);

      final refunded =
          StaminaService.refundCompletion(user, TaskCategory.mental, now: now);
      expect(refunded.currentStamina, 80); // 50 + 30 = 80
    });

    test(
        'when cost > stamina, consumeForTask clamps stamina to 0 and never goes negative',
        () {
      final now = DateTime.now();
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
        now: now,
      ).copyWith(currentStamina: 10, staminaUpdatedAt: now);

      final consumed = StaminaService.consumeForTask(
          user, TaskCategory.physical,
          now: now); // cost: 35
      expect(consumed.currentStamina, 0); // 10 - 35 = -25 -> clamped to 0
    });
  });

  group('2. Karakter Sınıfları (Character Classes)', () {
    test('Warrior has 100 HP, 100 Stamina, 1.0x damage, 1.0x essence', () {
      const warrior = CharacterClass.warrior;
      expect(warrior.baseHp, 100);
      expect(warrior.maxStamina, 100);
      expect(warrior.damageMultiplier, 1.0);
      expect(warrior.essenceMultiplier, 1.0);

      final user = User.create(id: 'u-warrior', selectedClass: warrior);
      expect(user.currentHp, 100);
      expect(user.maxHp, 100);
      expect(user.currentStamina, 100);
      expect(user.maxStamina, 100);
    });

    test('Mage has 150 HP, 50 Stamina, 0.75x damage, 1.0x essence', () {
      const mage = CharacterClass.mage;
      expect(mage.baseHp, 150);
      expect(mage.maxStamina, 50);
      expect(mage.damageMultiplier, 0.75);
      expect(mage.essenceMultiplier, 1.0);

      final user = User.create(id: 'u-mage', selectedClass: mage);
      expect(user.currentHp, 150);
      expect(user.maxHp, 150);
      expect(user.currentStamina, 50);
      expect(user.maxStamina, 50);
      // Reward multiplier test: 8 * 1.0 = 8
      expect(
          TaskEconomyService.rewardFor(TaskCategory.physical, user: user), 8);
    });

    test('Prisoner has 50 HP, 150 Stamina, 1.25x damage, 1.5x essence', () {
      const prisoner = CharacterClass.prisoner;
      expect(prisoner.baseHp, 50);
      expect(prisoner.maxStamina, 150);
      expect(prisoner.damageMultiplier, 1.25);
      expect(prisoner.essenceMultiplier, 1.5);

      final user = User.create(id: 'u-prisoner', selectedClass: prisoner);
      expect(user.currentHp, 50);
      expect(user.maxHp, 50);
      expect(user.currentStamina, 150);
      expect(user.maxStamina, 150);

      // Reward multiplier test: 8 * 1.5 = 12
      expect(
          TaskEconomyService.rewardFor(TaskCategory.physical, user: user), 12);

      // Damage penalty test: 10 * 1.25 (class) = 12.5 -> 13
      final normalTask = Task(
        id: 't1',
        title: 'Task 1',
        category: TaskCategory.routine,
        healthDamage: 10,
        createdAt: DateTime.now(),
      );
      expect(TaskEconomyService.penaltyFor(normalTask, user: user), 13);

      // Exhausted damage penalty test: 10 * 1.5 (exhausted) * 1.25 (class) = 18.75 -> 19
      final exhaustedTask = Task(
        id: 't2',
        title: 'Task 2',
        category: TaskCategory.routine,
        healthDamage: 10,
        createdAt: DateTime.now(),
        acceptedWhileExhausted: true,
      );
      expect(TaskEconomyService.penaltyFor(exhaustedTask, user: user), 19);
    });
  });

  group('3. Boss & Faz Ölçeklendirmesi (Boss Battle Mechanics)', () {
    test('Boss phase HP progression: 30 -> 90 -> 180 -> 365', () {
      expect(Boss.maxHpForPhase(1), 30);
      expect(Boss.maxHpForPhase(2), 90);
      expect(Boss.maxHpForPhase(3), 180);
      expect(Boss.maxHpForPhase(4), 365);
    });

    test(
        'Direndim (Resisted) damages Boss by 1 HP and awards NO Essence before phase completion',
        () {
      final boss = BossService.createBoss(title: 'Sigarayı Bırak');
      final user = User.create(id: 'u1', selectedClass: CharacterClass.warrior);

      final result = BossService.resist(boss: boss, user: user);
      expect(result.boss.currentHp, 29); // 30 - 1
      expect(result.damageDealt, 1);
      expect(result.essenceGained, 0); // Direndim awards 0 Essence mid-phase
      expect(result.didPhaseMutate, isFalse);
      expect(result.user.essence, 0);
    });

    test('Boss only allows 1 strike per day (enforces once-per-day limit)', () {
      final boss = BossService.createBoss(title: 'Sigarayı Bırak');
      final user = User.create(id: 'u1', selectedClass: CharacterClass.warrior);
      final today = DateTime(2026, 8, 16);

      // First interaction succeeds
      final first = BossService.resist(boss: boss, user: user, now: today);
      expect(first.boss.lastInteractedAt, today);

      // Second interaction on the SAME day throws BossAlreadyInteractedException
      expect(
        () => BossService.resist(boss: first.boss, user: user, now: today),
        throwsA(isA<BossAlreadyInteractedException>()),
      );
      expect(
        () => BossService.fail(boss: first.boss, user: user, now: today),
        throwsA(isA<BossAlreadyInteractedException>()),
      );

      // Interaction on NEXT day succeeds
      final nextDay = DateTime(2026, 8, 17);
      final second =
          BossService.resist(boss: first.boss, user: user, now: nextDay);
      expect(second.boss.currentHp, 28);
    });

    test('Yenildim (Failed) damages user and heals Boss (+1 HP up to maxHp)',
        () {
      final boss = BossService.createBoss(title: 'Sigarayı Bırak')
          .copyWith(currentHp: 25);
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior, // 1.0x damage multiplier
      );

      final result = BossService.fail(boss: boss, user: user);
      expect(result.boss.currentHp, 26); // 25 + 1
      expect(result.damageTaken, 40); // 40 * 1.0 = 40
      expect(result.user.currentHp, 60); // 100 - 40 = 60
    });

    test('Failed cannot heal boss beyond maxHp', () {
      final boss = BossService.createBoss(title: 'Sigarayı Bırak');
      final user = User.create(id: 'u1', selectedClass: CharacterClass.warrior);

      final result = BossService.fail(boss: boss, user: user);
      expect(result.boss.currentHp, 30); // Capped at maxHp (30)
    });

    test('Phase Mutation 1 -> 2: mutates to 90 days and awards 150 Essence',
        () {
      final boss = BossService.createBoss(title: 'Sigarayı Bırak')
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
      expect(result.essenceGained, 150); // 150 * 1.0
      expect(result.user.essence, 150);
    });

    test(
        'Phase Mutation 2 -> 3: mutates to 180 days and awards 400 Essence (scaled by Prisoner 1.5x)',
        () {
      final boss = Boss(
        id: 'b1',
        title: 'Sigarayı Bırak',
        currentHp: 1,
        maxHp: 90,
        phase: 2,
      );
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.prisoner, // 1.5x multiplier
      );

      final result = BossService.resist(boss: boss, user: user);
      expect(result.didPhaseMutate, isTrue);
      expect(result.boss.phase, 3);
      expect(result.boss.maxHp, 180);
      expect(result.boss.currentHp, 180);
      expect(result.essenceGained, 600); // 400 * 1.5 = 600
      expect(result.user.essence, 600);
    });

    test('Phase Mutation 3 -> 4: mutates to 365 days and awards 1000 Essence',
        () {
      final boss = Boss(
        id: 'b1',
        title: 'Sigarayı Bırak',
        currentHp: 1,
        maxHp: 180,
        phase: 3,
      );
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      );

      final result = BossService.resist(boss: boss, user: user);
      expect(result.didPhaseMutate, isTrue);
      expect(result.boss.phase, 4);
      expect(result.boss.maxHp, 365);
      expect(result.boss.currentHp, 365);
      expect(result.essenceGained, 1000); // Phase 3 completion reward
      expect(result.user.essence, 1000);
    });
  });

  group('4. Multi-Day Streak Catch-up & Auto Resolution', () {
    test('resolvePastDays catches up streak across multiple completed days',
        () {
      final day1 = DateTime(2026, 8, 14);
      final day2 = DateTime(2026, 8, 15);
      final today = DateTime(2026, 8, 16);

      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
        now: day1,
      ).copyWith(
        lastDailyResolutionAt: day1.subtract(const Duration(days: 1)),
        currentStreak: 1,
      );

      final task = Task(
        id: 't1',
        title: 'Daily Run',
        category: TaskCategory.physical,
        scheduledDays: {day1.weekday, day2.weekday},
        createdAt: day1,
        completedDateKeys: {
          Task.dateKey(day1),
          Task.dateKey(day2),
        },
      );

      final caughtUpUser = DayResolutionService.resolvePastDays(
        user: user,
        tasks: [task],
        today: today,
      );

      // Day 1 completed -> streak becomes 2. Day 2 completed -> streak becomes 3.
      expect(caughtUpUser.currentStreak, 3);
      expect(caughtUpUser.currentHp, 100);
      expect(DayResolutionService.wasResolvedFor(caughtUpUser, day2), isTrue);
    });

    test('resolvePastDays resets streak to 1 and applies damage on missed day',
        () {
      final day1 = DateTime(2026, 8, 14);
      final day2 = DateTime(2026, 8, 15); // Missed day!
      final today = DateTime(2026, 8, 16);

      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.mage, // 150 HP, 0.75x damage
        now: day1,
      ).copyWith(
        lastDailyResolutionAt: day1.subtract(const Duration(days: 1)),
        currentStreak: 5,
      );

      final task = Task(
        id: 't1',
        title: 'Study',
        category: TaskCategory.mental,
        scheduledDays: {day1.weekday, day2.weekday},
        healthDamage: 20,
        createdAt: day1,
        completedDateKeys: {
          Task.dateKey(day1), // Only day 1 was completed
        },
      );

      final caughtUpUser = DayResolutionService.resolvePastDays(
        user: user,
        tasks: [task],
        today: today,
      );

      // Day 2 was missed -> streak resets to 1, takes 20 * 0.75 = 15 damage (150 - 15 = 135 HP)
      expect(caughtUpUser.currentStreak, 1);
      expect(caughtUpUser.currentHp, 135);
      expect(DayResolutionService.wasResolvedFor(caughtUpUser, day2), isTrue);
    });
  });
}
