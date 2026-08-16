import 'package:bonfire/domain/models/task.dart';

/// Phase 1 task economy rules: Essence rewards by category and missed task penalties.
class TaskEconomyService {
  const TaskEconomyService._();

  /// Essence rewarded upon completing a task of the given category.
  static int rewardFor(TaskCategory category) => category.essenceReward;

  /// HP penalty damage applied when a task is missed at day resolution.
  /// If the task was accepted while exhausted, the damage is multiplied by 1.5x.
  static int penaltyFor(Task task) {
    final multiplier = task.acceptedWhileExhausted ? 1.5 : 1.0;
    return (task.healthDamage * multiplier).round();
  }
}
