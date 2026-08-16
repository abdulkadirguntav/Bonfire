import 'package:bonfire/domain/models/ash_mark.dart';
import 'package:bonfire/domain/models/user.dart';

class DeathService {
  const DeathService._();

  static bool shouldDie(User user) => user.currentHp <= 0;

  static AshMark createAshMark(User user, {DateTime? createdAt}) => AshMark(
        id: 'ash_${(createdAt ?? DateTime.now()).millisecondsSinceEpoch}',
        lostEssence: user.essence,
        targetStreak: user.currentStreak,
        createdAt: createdAt ?? DateTime.now(),
      );

  /// Resets the user after death: HP is restored to baseHp, stamina is refilled to maxStamina,
  /// essence is zeroed, and streak resets to day 1.
  static User applyDeath(User user, {DateTime? now}) => user.copyWith(
        currentHp: user.selectedClass.baseHp,
        maxHp: user.selectedClass.baseHp,
        currentStamina: user.selectedClass.maxStamina,
        maxStamina: user.selectedClass.maxStamina,
        staminaUpdatedAt: now ?? DateTime.now(),
        essence: 0,
        currentStreak: 1,
      );

  static bool canReclaim(User user, AshMark ashMark) =>
      user.currentStreak >= ashMark.targetStreak;

  static User reclaim(User user, AshMark ashMark) => canReclaim(user, ashMark)
      ? user.copyWith(essence: user.essence + ashMark.lostEssence)
      : user;
}
