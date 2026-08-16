import 'package:flutter_test/flutter_test.dart';

import 'package:bonfire/domain/models/attributes.dart';
import 'package:bonfire/domain/models/character_class.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/domain/services/attribute_service.dart';
import 'package:bonfire/domain/services/shop_service.dart';
import 'package:bonfire/domain/services/task_economy_service.dart';

void main() {
  group('1. Stat Geliştirme (Level Up) ve 4 Temel Stat Kuralları', () {
    test('Vitality increases maxHp by +15 per level', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior, // baseHp = 150
      ).copyWith(
        currentStreak: 3, // Bonfire day!
        essence: 200,
      );

      final upgraded = AttributeService.levelUp(user, AttributeType.vitality);
      expect(upgraded.vitalityLevel, 1);
      expect(upgraded.maxHp, 165); // 150 + 15
      expect(upgraded.currentHp, 165);
      expect(upgraded.essence, 100); // 200 - 100 = 100
    });

    test('Endurance increases maxStamina by +10 per level', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior, // maxStamina = 100
      ).copyWith(
        currentStreak: 7, // Bonfire day!
        essence: 200,
      );

      final upgraded = AttributeService.levelUp(user, AttributeType.endurance);
      expect(upgraded.enduranceLevel, 1);
      expect(upgraded.maxStamina, 110); // 100 + 10
      expect(upgraded.currentStamina, 110);
    });

    test('Strength increases Essence reward multiplier by +5% per level', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior, // base essenceMultiplier = 1.0
      ).copyWith(
        currentStreak: 14, // Bonfire day!
        essence: 200,
      );

      final upgraded = AttributeService.levelUp(user, AttributeType.strength);
      expect(upgraded.strengthLevel, 1);
      expect(upgraded.totalEssenceMultiplier, closeTo(1.05, 0.001));

      // Physical task base reward = 8 Essence -> 8 * 1.05 = 8.4 -> 8 Essence
      final reward = TaskEconomyService.rewardFor(TaskCategory.physical, user: upgraded);
      expect(reward, 8);
    });

    test('Adaptability reduces HP penalty damage by -4% per level', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.mage, // base damageMultiplier = 1.0
      ).copyWith(
        currentStreak: 30, // Bonfire day!
        essence: 200,
      );

      final upgraded = AttributeService.levelUp(user, AttributeType.adaptability);
      expect(upgraded.adaptabilityLevel, 1);
      expect(upgraded.totalDamageMultiplier, closeTo(0.96, 0.001));

      // Missed physical task (30 damage) -> 30 * 0.96 = 28.8 -> 29 damage
      final task = Task(
        id: 't1',
        title: 'Exercise',
        category: TaskCategory.physical,
        healthDamage: 30,
        createdAt: DateTime.now(),
      );
      final penalty = TaskEconomyService.penaltyFor(task, user: upgraded);
      expect(penalty, 29);
    });
  });

  group('2. Bonfire Kilit Mantığı (Zorunlu Kural)', () {
    test('Level up is BLOCKED on non-Bonfire days (streak 1, 2, 4, 5, 8...)', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      ).copyWith(
        currentStreak: 2, // NOT a Bonfire day (3, 7, 14, 30)
        essence: 500,
      );

      expect(user.isAtBonfireDay, isFalse);
      expect(
        () => AttributeService.levelUp(user, AttributeType.vitality),
        throwsA(isA<NotAtBonfireDayException>()),
      );
    });

    test('Level up is ALLOWED on Bonfire days (streak 3, 7, 14, 30)', () {
      for (final streak in [3, 7, 14, 30]) {
        final user = User.create(
          id: 'u1',
          selectedClass: CharacterClass.warrior,
        ).copyWith(
          currentStreak: streak,
          essence: 100,
        );

        expect(user.isAtBonfireDay, isTrue);
        final upgraded = AttributeService.levelUp(user, AttributeType.vitality);
        expect(upgraded.vitalityLevel, 1);
      }
    });
  });

  group('3. RPG Essence Bedeli Artışı ve Yetersiz Öz Kontrolü', () {
    test('level up cost scales exponentially with current attribute level', () {
      expect(AttributeType.costForLevel(0), 100);
      expect(AttributeType.costForLevel(1), 145);
      expect(AttributeType.costForLevel(2), 210);
      expect(AttributeType.costForLevel(3), 305);
    });

    test('throws InsufficientEssenceException when user cannot afford upgrade', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      ).copyWith(
        currentStreak: 3,
        essence: 30, // Needs 100
      );

      expect(
        () => AttributeService.levelUp(user, AttributeType.vitality),
        throwsA(isA<InsufficientEssenceException>()),
      );
    });
  });

  group('4. Genel İstatistikler (Lifetime Statistics)', () {
    test('tracking enemies defeated, boss phases, deaths, and highest streak', () {
      var user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      );

      expect(user.enemiesDefeated, 0);
      expect(user.bossPhasesDefeated, 0);
      expect(user.deathCount, 0);
      expect(user.ashMarksReclaimed, 0);
      expect(user.highestStreak, 1);

      user = user.copyWith(
        enemiesDefeated: 15,
        bossPhasesDefeated: 2,
        deathCount: 3,
        ashMarksReclaimed: 2,
        currentStreak: 12,
        highestStreak: 12,
      );

      expect(user.enemiesDefeated, 15);
      expect(user.bossPhasesDefeated, 2);
      expect(user.deathCount, 3);
      expect(user.ashMarksReclaimed, 2);
      expect(user.highestStreak, 12);
    });
  });
}
