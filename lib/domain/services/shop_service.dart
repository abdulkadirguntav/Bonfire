import 'package:bonfire/domain/models/shop_item.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';

class InsufficientEssenceException implements Exception {
  const InsufficientEssenceException();

  @override
  String toString() => 'Yeterli Öz (Essence) bulunmuyor.';
}

class ItemNotOwnedException implements Exception {
  const ItemNotOwnedException();

  @override
  String toString() => 'Envanterinizde bu eşyadan bulunmuyor.';
}

class ShopService {
  const ShopService._();

  /// Satın alma işlemi: Essence düşer, envantere eklenir.
  static User buyItem(User user, ItemType item, {int quantity = 1}) {
    final totalCost = item.cost * quantity;
    if (user.essence < totalCost) {
      throw const InsufficientEssenceException();
    }

    final currentCount = user.itemCount(item.id);
    final updatedInventory = Map<String, int>.from(user.inventory)
      ..[item.id] = currentCount + quantity;

    return user.copyWith(
      essence: user.essence - totalCost,
      inventory: updatedInventory,
    );
  }

  /// Eşya kullanma işlemi: Envanterden 1 adet düşer ve eşyanın etkisi uygulanır.
  static User useItem(User user, ItemType item, {DateTime? now}) {
    final count = user.itemCount(item.id);
    if (count <= 0) {
      throw const ItemNotOwnedException();
    }

    final updatedInventory = Map<String, int>.from(user.inventory);
    if (count == 1) {
      updatedInventory.remove(item.id);
    } else {
      updatedInventory[item.id] = count - 1;
    }

    switch (item) {
      case ItemType.estusFlask:
        // Estus Flask: 40 HP doldurur (maxHp'yi geçemez).
        final nextHp = (user.currentHp + 40).clamp(0, user.maxHp);
        return user.copyWith(
          currentHp: nextHp,
          inventory: updatedInventory,
        );

      case ItemType.ashenEstus:
        // Ashen Estus: Stamina'yı maxStamina'ya doldurur.
        return user.copyWith(
          currentStamina: user.maxStamina,
          inventory: updatedInventory,
        );

      case ItemType.purgingStone:
        // Purging Stone: Gün sonu 1 adet ihmal edilen görevin cezasını engeller.
        return user.copyWith(
          activePurgingStones: user.activePurgingStones + 1,
          inventory: updatedInventory,
        );

      case ItemType.scrollOfStasis:
        // Scroll of Stasis: Mevcut günü dondurur.
        final targetDate = now ?? DateTime.now();
        final updatedStasis = Set<String>.from(user.activeStasisDateKeys)
          ..add(Task.dateKey(targetDate));
        return user.copyWith(
          activeStasisDateKeys: updatedStasis,
          inventory: updatedInventory,
        );

      case ItemType.ringOfSacrifice:
        // Pasif eşyadır, envanterde bekler; ölüm anında DeathService tarafından otomatik tüketilir.
        return user;
    }
  }
}
