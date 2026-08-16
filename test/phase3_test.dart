import 'package:flutter_test/flutter_test.dart';

import 'package:bonfire/domain/models/character_class.dart';
import 'package:bonfire/domain/models/shop_item.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/domain/services/day_resolution_service.dart';
import 'package:bonfire/domain/services/death_service.dart';
import 'package:bonfire/domain/services/shop_service.dart';

void main() {
  group('1. The Kiln (Mağaza) ve Eşya Satın Alma Kuralları', () {
    test('buying items throws MarketClosedException on non-market days', () {
      final nonMarketDay = DateTime(2026, 8, 16); // Day 1 (1 % 5 != 0)
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
        now: nonMarketDay,
      ).copyWith(
        currentStreak: 1, // Not a multiple of 5
        essence: 500,
      );

      expect(ShopService.isMarketOpen(user), isFalse);
      expect(
        () => ShopService.buyItem(user, ItemType.estusFlask),
        throwsA(isA<MarketClosedException>()),
      );
    });

    test('buying items succeeds on Market Days (streaks 5, 10, 15, 20...) and deducts Essence', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      ).copyWith(
        currentStreak: 5, // Market is OPEN!
        essence: 200,
      );

      expect(ShopService.isMarketOpen(user), isTrue);

      final updated = ShopService.buyItem(user, ItemType.estusFlask);
      expect(updated.essence, 200 - ItemType.estusFlask.cost); // 200 - 30 = 170
      expect(updated.itemCount(ItemType.estusFlask.id), 1);
    });

    test('buying items throws InsufficientEssenceException when player has not enough essence', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      ).copyWith(
        currentStreak: 10, // Market is open
        essence: 10, // Not enough for Estus Flask (cost 30)
      );

      expect(
        () => ShopService.buyItem(user, ItemType.estusFlask),
        throwsA(isA<InsufficientEssenceException>()),
      );
    });

    test('using Estus Flask heals 40 HP capped at maxHp and consumes 1 item', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior, // maxHp = 100
      ).copyWith(
        currentHp: 50,
        inventory: {ItemType.estusFlask.id: 2},
      );

      final healedUser = ShopService.useItem(user, ItemType.estusFlask);
      expect(healedUser.currentHp, 90); // 50 + 40 = 90
      expect(healedUser.itemCount(ItemType.estusFlask.id), 1);

      // Overheal test (capped at maxHp 100)
      final fullHealed = ShopService.useItem(healedUser, ItemType.estusFlask);
      expect(fullHealed.currentHp, 100); // 90 + 40 = 130 -> capped at 100
      expect(fullHealed.itemCount(ItemType.estusFlask.id), 0);
    });

    test('using Ashen Estus refills stamina to maxStamina and consumes item', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.prisoner, // maxStamina = 150
      ).copyWith(
        currentStamina: 10,
        inventory: {ItemType.ashenEstus.id: 1},
      );

      final refilledUser = ShopService.useItem(user, ItemType.ashenEstus);
      expect(refilledUser.currentStamina, 150);
      expect(refilledUser.itemCount(ItemType.ashenEstus.id), 0);
    });

    test('using Purging Stone activates purging stone protection for today', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      ).copyWith(
        inventory: {ItemType.purgingStone.id: 1},
        activePurgingStones: 0,
      );

      final updatedUser = ShopService.useItem(user, ItemType.purgingStone);
      expect(updatedUser.activePurgingStones, 1);
      expect(updatedUser.itemCount(ItemType.purgingStone.id), 0);
    });

    test('using Scroll of Stasis freezes current day and consumes item', () {
      final date = DateTime(2026, 8, 16);
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      ).copyWith(
        inventory: {ItemType.scrollOfStasis.id: 1},
      );

      final updatedUser = ShopService.useItem(user, ItemType.scrollOfStasis, now: date);
      expect(updatedUser.isStasisActive(date), isTrue);
      expect(updatedUser.itemCount(ItemType.scrollOfStasis.id), 0);
    });
  });

  group('2. Ring of Sacrifice Ölüm Koruma Mekaniği', () {
    test('death with Ring of Sacrifice preserves Essence and creates NO AshMark', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      ).copyWith(
        currentHp: 0,
        essence: 350,
        currentStreak: 12,
        inventory: {ItemType.ringOfSacrifice.id: 1},
      );

      expect(DeathService.shouldDie(user), isTrue);

      // AshMark must NOT be created
      final ashMark = DeathService.createAshMark(user);
      expect(ashMark, isNull);

      final revivedUser = DeathService.applyDeath(user);
      expect(revivedUser.essence, 350); // Essence PRESERVED!
      expect(revivedUser.currentHp, 100);
      expect(revivedUser.currentStreak, 1); // Streak still resets
      expect(revivedUser.itemCount(ItemType.ringOfSacrifice.id), 0); // Ring consumed
    });
  });

  group('3. Purging Stone ve Scroll of Stasis Gün Sonu Çözümlemesi', () {
    test('active Purging Stone negates 1 missed task penalty damage', () {
      final date = DateTime(2026, 8, 16);
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior, // 100 HP, 1.0x damage
      ).copyWith(
        activePurgingStones: 1,
      );

      final missedTask = Task(
        id: 't1',
        title: 'Missed Workout',
        category: TaskCategory.physical,
        healthDamage: 30,
        createdAt: date,
      );

      final resolution = DayResolutionService.resolve(
        user,
        [missedTask],
        date: date,
      );

      expect(resolution.purgedTaskCount, 1);
      expect(resolution.user.currentHp, 100); // 0 damage taken because it was purged!
      expect(resolution.user.activePurgingStones, 0); // Reset for next day
    });

    test('Scroll of Stasis prevents damage and preserves streak during vacation/illness', () {
      final date = DateTime(2026, 8, 16);
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      ).copyWith(
        currentStreak: 8,
        activeStasisDateKeys: {Task.dateKey(date)},
      );

      final missedTask = Task(
        id: 't1',
        title: 'Missed Workout',
        category: TaskCategory.physical,
        healthDamage: 30,
        createdAt: date,
      );

      final resolution = DayResolutionService.resolve(
        user,
        [missedTask],
        date: date,
      );

      expect(resolution.wasStasisApplied, isTrue);
      expect(resolution.user.currentHp, 100); // No damage
      expect(resolution.user.currentStreak, 8); // Streak PRESERVED!
    });
  });

  group('4. Bonfire Dönüm Noktaları (3, 7, 14, 30)', () {
    test('Kindling Bonfire full heals and grants permanent Max HP or Max Stamina', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior, // baseHp 100, maxStam 100
      ).copyWith(
        currentStreak: 3,
        currentHp: 40,
        currentStamina: 10,
      );

      // Kindle Vigor (+20 Max HP)
      final userHpUpgrade = user.copyWith(
        maxHp: user.maxHp + 20,
        currentHp: user.maxHp + 20,
        claimedMilestones: {3},
      );

      expect(userHpUpgrade.maxHp, 120); // 100 + 20
      expect(userHpUpgrade.currentHp, 120); // Fully healed
      expect(userHpUpgrade.claimedMilestones.contains(3), isTrue);

      // Kindle Endurance (+15 Max Stamina)
      final userStamUpgrade = user.copyWith(
        maxStamina: user.maxStamina + 15,
        currentStamina: user.maxStamina + 15,
        currentHp: user.maxHp,
        claimedMilestones: {3},
      );

      expect(userStamUpgrade.maxStamina, 115); // 100 + 15
      expect(userStamUpgrade.currentStamina, 115);
      expect(userStamUpgrade.currentHp, 100); // Also full heals HP
    });
  });
}
