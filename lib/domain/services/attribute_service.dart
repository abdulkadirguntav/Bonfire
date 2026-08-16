import 'package:bonfire/domain/models/attributes.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/domain/services/shop_service.dart';

class NotAtBonfireDayException implements Exception {
  const NotAtBonfireDayException();

  @override
  String toString() =>
      'Stat geliştirme (Level Up) yalnızca bir Bonfire gününde (Gün 3, 7, 14, 30) yapılabilir.';
}

class AttributeService {
  const AttributeService._();

  static int getUpgradeCost(User user, AttributeType type) {
    final currentLevel = user.attributeLevel(type);
    return AttributeType.costForLevel(currentLevel);
  }

  static User levelUp(
    User user,
    AttributeType type, {
    bool bypassBonfireCheck = false,
  }) {
    if (!bypassBonfireCheck && !user.isAtBonfireDay) {
      throw const NotAtBonfireDayException();
    }

    final cost = getUpgradeCost(user, type);
    if (user.essence < cost) {
      throw const InsufficientEssenceException();
    }

    final nextEssence = user.essence - cost;

    switch (type) {
      case AttributeType.vitality:
        final nextLevel = user.vitalityLevel + 1;
        final nextMaxHp = user.maxHp + 15;
        final nextCurrentHp = (user.currentHp + 15).clamp(0, nextMaxHp);
        return user.copyWith(
          essence: nextEssence,
          vitalityLevel: nextLevel,
          maxHp: nextMaxHp,
          currentHp: nextCurrentHp,
        );

      case AttributeType.endurance:
        final nextLevel = user.enduranceLevel + 1;
        final nextMaxStam = user.maxStamina + 10;
        final nextCurrentStam = (user.currentStamina + 10).clamp(0, nextMaxStam);
        return user.copyWith(
          essence: nextEssence,
          enduranceLevel: nextLevel,
          maxStamina: nextMaxStam,
          currentStamina: nextCurrentStam,
        );

      case AttributeType.strength:
        final nextLevel = user.strengthLevel + 1;
        return user.copyWith(
          essence: nextEssence,
          strengthLevel: nextLevel,
        );

      case AttributeType.adaptability:
        final nextLevel = user.adaptabilityLevel + 1;
        return user.copyWith(
          essence: nextEssence,
          adaptabilityLevel: nextLevel,
        );
    }
  }
}
