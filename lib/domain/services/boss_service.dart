import 'package:bonfire/domain/models/boss.dart';
import 'package:bonfire/domain/models/user.dart';

class BossInteractionResult {
  const BossInteractionResult({
    required this.boss,
    required this.user,
    required this.didPhaseMutate,
    required this.essenceGained,
    required this.damageTaken,
  });

  final Boss boss;
  final User user;
  final bool didPhaseMutate;
  final int essenceGained;
  final int damageTaken;
}

class BossService {
  const BossService._();

  static Boss createBoss({
    required String title,
    int initialHp = Boss.defaultInitialHp,
    String? id,
  }) {
    return Boss(
      id: id ?? 'boss_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      currentHp: initialHp,
      maxHp: initialHp,
      phase: 1,
    );
  }

  /// Direndim (Resisted):
  /// - Boss currentHp decreases by 1
  /// - User earns extra Essence (scaled by class essenceMultiplier)
  /// - If Boss currentHp <= 0: Phase Mutation!
  ///   - phase becomes 2
  ///   - maxHp becomes 90
  ///   - currentHp = 90
  ///   - user receives massive Essence reward
  static BossInteractionResult resist({
    required Boss boss,
    required User user,
    DateTime? now,
  }) {
    final interactionDate = now ?? DateTime.now();
    final newHp = boss.currentHp - 1;
    final baseEssence =
        (Boss.dailyResistEssence * user.selectedClass.essenceMultiplier).round();

    if (newHp <= 0) {
      final nextPhase = boss.phase + 1;
      const newMaxHp = Boss.phase2Hp;
      final phaseReward =
          (Boss.phaseRewardEssence * user.selectedClass.essenceMultiplier)
              .round();
      final totalEssence = baseEssence + phaseReward;

      final mutatedBoss = boss.copyWith(
        phase: nextPhase,
        maxHp: newMaxHp,
        currentHp: newMaxHp,
        lastInteractionDate: interactionDate,
      );

      final updatedUser = user.copyWith(
        essence: user.essence + totalEssence,
      );

      return BossInteractionResult(
        boss: mutatedBoss,
        user: updatedUser,
        didPhaseMutate: true,
        essenceGained: totalEssence,
        damageTaken: 0,
      );
    } else {
      final updatedBoss = boss.copyWith(
        currentHp: newHp,
        lastInteractionDate: interactionDate,
      );

      final updatedUser = user.copyWith(
        essence: user.essence + baseEssence,
      );

      return BossInteractionResult(
        boss: updatedBoss,
        user: updatedUser,
        didPhaseMutate: false,
        essenceGained: baseEssence,
        damageTaken: 0,
      );
    }
  }

  /// Yenildim (Failed):
  /// - User takes heavy HP damage (40 * class damageMultiplier)
  /// - Boss currentHp increases by +1 (heals, but cannot exceed maxHp)
  static BossInteractionResult fail({
    required Boss boss,
    required User user,
    DateTime? now,
  }) {
    final interactionDate = now ?? DateTime.now();
    final healedHp = (boss.currentHp + 1).clamp(0, boss.maxHp);
    final damage =
        (Boss.dailyFailDamage * user.selectedClass.damageMultiplier).round();

    final updatedBoss = boss.copyWith(
      currentHp: healedHp,
      lastInteractionDate: interactionDate,
    );

    final updatedUser = user.copyWith(
      currentHp: user.currentHp - damage,
    );

    return BossInteractionResult(
      boss: updatedBoss,
      user: updatedUser,
      didPhaseMutate: false,
      essenceGained: 0,
      damageTaken: damage,
    );
  }
}
