import 'dart:math';

import 'package:bonfire/domain/models/ash_mark.dart';
import 'package:bonfire/domain/models/user.dart';

class DeathService {
  const DeathService();

  static bool shouldDie(User user) => user.currentHp <= 0;

  static AshMark createAshMark(User user, {String? id, DateTime? createdAt}) {
    return AshMark(
      id: id ?? 'ash_${DateTime.now().millisecondsSinceEpoch}',
      lostEssence: user.totalEssence,
      targetStreak: user.currentStreak,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  static User applyDeath(User user) {
    final baseHp = user.selectedClass.baseHp;
    return user.copyWith(
      currentHp: baseHp,
      maxHp: baseHp,
      totalEssence: 0,
      currentStreak: 0,
    );
  }

  static bool canReclaim(User user, AshMark ashMark) {
    return user.currentStreak >= ashMark.targetStreak;
  }

  static User reclaim(User user, AshMark ashMark) {
    if (!canReclaim(user, ashMark)) {
      return user;
    }

    return user.copyWith(
      totalEssence: user.totalEssence + ashMark.lostEssence,
    );
  }

  static int recoverHpFromItem(User user, int healAmount) {
    final diff = user.maxHp - user.currentHp;
    return min(diff, healAmount);
  }
}
