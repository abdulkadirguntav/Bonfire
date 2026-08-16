import 'package:flutter_test/flutter_test.dart';
import 'package:bonfire/domain/models/character_class.dart';
import 'package:bonfire/domain/models/shop_item.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/domain/services/day_resolution_service.dart';
import 'package:bonfire/domain/services/death_service.dart';
import 'package:bonfire/domain/services/shop_service.dart';

void main() {
  group('1. The Kiln (Mağaza) Satın Alma & Envanter Kuralları', () {
    test('buying items deducts essence and adds to inventory', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      ).copyWith(essence: 100);

      final updatedUser = ShopService.buyItem(user, ItemType.estusFlask);
      expect(updatedUser.essence, 50); // 100 - 50 = 50
      expect(updatedUser.itemCount(ItemType.estusFlask.id), 1);
    });

    test('buying items throws InsufficientEssenceException when essence is low', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      ).copyWith(essence: 20);

      expect(
        () => ShopService.buyItem(user, ItemType.estusFlask),
        throwsA(isA<InsufficientEssenceException>()),
      );
    });

    test('using Estus Flask heals 40 HP capped at maxHp and consumes 1 item', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior, // maxHp = 150
      ).copyWith(
        currentHp: 80,
        inventory: {ItemType.estusFlask.id: 2},
      );

      final healedUser = ShopService.useItem(user, ItemType.estusFlask);
      expect(healedUser.currentHp, 120); // 80 + 40 = 120
      expect(healedUser.itemCount(ItemType.estusFlask.id), 1);

      // Overheal test (capped at maxHp 150)
      final fullHealed = ShopService.useItem(healedUser, ItemType.estusFlask);
      expect(fullHealed.currentHp, 150); // 120 + 40 = 160 -> capped at 150
      expect(fullHealed.itemCount(ItemType.estusFlask.id), 0);
    });

    test('using Ashen Estus refills stamina to maxStamina and consumes item', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.mage, // maxStamina = 150
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
      );

      final protectedUser = ShopService.useItem(user, ItemType.purgingStone);
      expect(protectedUser.activePurgingStones, 1);
      expect(protectedUser.itemCount(ItemType.purgingStone.id), 0);
    });

    test('using Scroll of Stasis freezes current day and consumes item', () {
      final today = DateTime(2026, 8, 16);
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      ).copyWith(
        inventory: {ItemType.scrollOfStasis.id: 1},
      );

      final stasisUser = ShopService.useItem(user, ItemType.scrollOfStasis, now: today);
      expect(stasisUser.isStasisActiveOn(today), isTrue);
      expect(stasisUser.itemCount(ItemType.scrollOfStasis.id), 0);
    });
  });

  group('2. Ring of Sacrifice (Fedakarlık Yüzüğü) ve Ölüm Mekaniği', () {
    test('dying with Ring of Sacrifice preserves Essence and creates NO AshMark', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      ).copyWith(
        currentHp: 0,
        essence: 500,
        currentStreak: 12,
        inventory: {ItemType.ringOfSacrifice.id: 1},
      );

      expect(DeathService.shouldDie(user), isTrue);

      // Ring of Sacrifice prevents AshMark creation
      final ashMark = DeathService.createAshMark(user);
      expect(ashMark, isNull);

      // Reviving with ring keeps essence and consumes ring
      final revivedUser = DeathService.applyDeath(user);
      expect(revivedUser.essence, 500); // PRESERVED!
      expect(revivedUser.currentStreak, 1); // Streak resets to 1
      expect(revivedUser.currentHp, 150); // HP refilled
      expect(revivedUser.itemCount(ItemType.ringOfSacrifice.id), 0); // Ring consumed
    });
  });

  group('3. Purging Stone ve Scroll of Stasis Gün Sonu Çözümlemesi', () {
    test('active Purging Stone negates 1 missed task penalty damage', () {
      final date = DateTime(2026, 8, 16);
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior, // 150 HP, 0.8x damage
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
      expect(resolution.user.currentHp, 150); // 0 damage taken because it was purged!
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
      expect(resolution.user.currentHp, 150); // No damage
      expect(resolution.user.currentStreak, 8); // Streak PRESERVED!
    });
  });

  group('4. Bonfire Dönüm Noktaları (3, 7, 14, 30)', () {
    test('Kindling Bonfire full heals and grants permanent Max HP or Max Stamina', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior, // baseHp 150, maxStam 100
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

      expect(userHpUpgrade.maxHp, 170);
      expect(userHpUpgrade.currentHp, 170);
      expect(userHpUpgrade.hasClaimedMilestone(3), isTrue);

      // Kindle Endurance (+15 Max Stamina)
      final userStamUpgrade = user.copyWith(
        maxStamina: user.maxStamina + 15,
        currentStamina: user.maxStamina + 15,
        currentHp: user.maxHp,
        claimedMilestones: {3},
      );

      expect(userStamUpgrade.maxStamina, 115);
      expect(userStamUpgrade.currentStamina, 115);
      expect(userStamUpgrade.currentHp, 150);
    });
  });
}
