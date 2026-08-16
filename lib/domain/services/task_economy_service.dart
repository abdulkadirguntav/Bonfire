import 'package:bonfire/domain/models/task.dart';

/// Phase 1 has no class or boss multipliers: a completed task earns the
/// Essence defined by its category.
class TaskEconomyService {
  const TaskEconomyService._();

  static int rewardFor(TaskCategory category) => category.essenceReward;
}
