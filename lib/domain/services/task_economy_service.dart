import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';

/// Phase 2 task economy rules: Essence rewards and damage penalties scaled by class multipliers.
class TaskEconomyService {
  const TaskEconomyService._();

  /// Essence rewarded upon completing a task of the given category.
  static int rewardFor(TaskCategory category, {User? user}) {
    final multiplier = user?.selectedClass.essenceMultiplier ?? 1.0;
    return (category.essenceReward * multiplier).round();
  }

  /// HP penalty damage applied when a task is missed at day resolution.
  /// Scaled by 1.5x if accepted while exhausted, and by the character's damageMultiplier.
  static int penaltyFor(Task task, {User? user}) {
    final exhaustedMultiplier = task.acceptedWhileExhausted ? 1.5 : 1.0;
    final classMultiplier = user?.selectedClass.damageMultiplier ?? 1.0;
    return (task.healthDamage * exhaustedMultiplier * classMultiplier).round();
  }
}
