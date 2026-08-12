import 'dart:math';

import 'package:bonfire/domain/models/shop_item.dart';
import 'package:bonfire/domain/models/user.dart';

class ShopService {
  const ShopService();

  static List<ShopItem> defaultCatalog() => [ShopItem.estusFlask()];

  static bool canAfford(User user, ShopItem item) => user.totalEssence >= item.price;

  static User purchase(User user, ShopItem item) {
    if (!canAfford(user, item)) {
      throw StateError('Not enough Essence to buy ${item.name}.');
    }

    final healedAmount = min(item.healAmount, user.maxHp - user.currentHp);
    final nextUser = user.copyWith(
      totalEssence: user.totalEssence - item.price,
      currentHp: min(user.maxHp, user.currentHp + healedAmount),
    );

    return nextUser;
  }
}
