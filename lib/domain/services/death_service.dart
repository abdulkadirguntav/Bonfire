import 'package:bonfire/domain/models/ash_mark.dart';
import 'package:bonfire/domain/models/shop_item.dart';
import 'package:bonfire/domain/models/user.dart';

class DeathService {
  const DeathService._();

  static bool shouldDie(User user) => user.currentHp <= 0;

  static AshMark? createAshMark(User user, {DateTime? createdAt}) {
    // Ring of Sacrifice saves essence and prevents Ash Mark creation
    if (user.hasRingOfSacrifice) {
      return null;
    }

    return AshMark(
      id: 'ash_${(createdAt ?? DateTime.now()).millisecondsSinceEpoch}',
      lostEssence: user.essence,
      targetStreak: user.currentStreak,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Resets the user after death.
  /// If Ring of Sacrifice was present:
  /// - Streak resets to 1
  /// - Essence is PRESERVED (not lost)
  /// - 1 Ring of Sacrifice is consumed
  /// If no Ring of Sacrifice:
  /// - Streak resets to 1, Essence resets to 0.
  static User applyDeath(User user, {DateTime? now}) {
    final hasRing = user.hasRingOfSacrifice;
    final updatedInventory = Map<String, int>.from(user.inventory);

    if (hasRing) {
      final ringCount = user.itemCount(ItemType.ringOfSacrifice.id);
      if (ringCount <= 1) {
        updatedInventory.remove(ItemType.ringOfSacrifice.id);
      } else {
        updatedInventory[ItemType.ringOfSacrifice.id] = ringCount - 1;
      }
    }

    return user.copyWith(
      currentHp: user.selectedClass.baseHp,
      maxHp: user.selectedClass.baseHp,
      currentStamina: user.selectedClass.maxStamina,
      maxStamina: user.selectedClass.maxStamina,
      staminaUpdatedAt: now ?? DateTime.now(),
      essence: hasRing ? user.essence : 0,
      currentStreak: 1,
      inventory: updatedInventory,
    );
  }

  static bool canReclaim(User user, AshMark ashMark) =>
      user.currentStreak >= ashMark.targetStreak;

  static User reclaim(User user, AshMark ashMark) => canReclaim(user, ashMark)
      ? user.copyWith(essence: user.essence + ashMark.lostEssence)
      : user;
}
