import 'package:bonfire/domain/models/boss.dart';
import 'package:bonfire/domain/models/user.dart';

class BossAlreadyInteractedException implements Exception {
  const BossAlreadyInteractedException();

  @override
  String toString() =>
      'Bugün bu boss ile zaten etkileşime girdiniz. Yarın tekrar deneyin.';
}

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
    int? initialHp,
    String? id,
  }) {
    final hp = initialHp ?? Boss.maxHpForPhase(1);
    return Boss(
      id: id ?? 'boss_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      currentHp: hp,
      maxHp: hp,
      phase: 1,
    );
  }

  /// Direndim (Resisted):
  /// - Can only be called once per day!
  /// - Boss currentHp decreases by 1
  /// - No daily Essence is given on normal strikes (0 essence).
  /// - When Boss currentHp reaches 0: Phase Mutation!
  ///   - phase becomes phase + 1 (Phase 2: 90 days, Phase 3: 180 days, Phase 4: 365 days)
  ///   - maxHp and currentHp scale according to phase
  ///   - user receives a massive Essence reward scaled by completed phase and class multiplier!
  static BossInteractionResult resist({
    required Boss boss,
    required User user,
    DateTime? now,
  }) {
    final interactionDate = now ?? DateTime.now();

    if (boss.wasInteractedOn(interactionDate)) {
      throw const BossAlreadyInteractedException();
    }

    final newHp = boss.currentHp - 1;

    if (newHp <= 0) {
      final completedPhase = boss.phase;
      final nextPhase = completedPhase + 1;
      final newMaxHp = Boss.maxHpForPhase(nextPhase);
      final phaseReward = (Boss.rewardForPhaseCompletion(completedPhase) *
              user.selectedClass.essenceMultiplier)
          .round();

      final mutatedBoss = boss.copyWith(
        phase: nextPhase,
        maxHp: newMaxHp,
        currentHp: newMaxHp,
        lastInteractionDate: interactionDate,
      );

      final updatedUser = user.copyWith(
        essence: user.essence + phaseReward,
      );

      return BossInteractionResult(
        boss: mutatedBoss,
        user: updatedUser,
        didPhaseMutate: true,
        essenceGained: phaseReward,
        damageTaken: 0,
      );
    } else {
      final updatedBoss = boss.copyWith(
        currentHp: newHp,
        lastInteractionDate: interactionDate,
      );

      return BossInteractionResult(
        boss: updatedBoss,
        user: user,
        didPhaseMutate: false,
        essenceGained: 0,
        damageTaken: 0,
      );
    }
  }

  /// Yenildim (Failed):
  /// - Can only be called once per day!
  /// - User takes heavy HP damage (40 * class damageMultiplier)
  /// - Boss currentHp increases by +1 (heals, but cannot exceed maxHp)
  static BossInteractionResult fail({
    required Boss boss,
    required User user,
    DateTime? now,
  }) {
    final interactionDate = now ?? DateTime.now();

    if (boss.wasInteractedOn(interactionDate)) {
      throw const BossAlreadyInteractedException();
    }

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
