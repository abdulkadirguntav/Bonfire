import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';

class TaskEconomyService {
  const TaskEconomyService();

  static int calculateReward(User user, int baseEssence) {
    final multiplier = user.selectedClass.essenceMultiplier;
    final total = baseEssence * multiplier;
    return total.round();
  }

  static int calculateBossReward(User user, int baseEssence) {
    final total = baseEssence * user.selectedClass.essenceMultiplier * 3;
    return total.round();
  }

  static int calculatePenalty(User user, int baseDamage) {
    final multiplier = user.selectedClass.damageMultiplier;
    final total = baseDamage * multiplier;
    return total.round();
  }

  static int calculateBossPenalty(User user, int baseDamage) {
    final total = baseDamage * user.selectedClass.damageMultiplier * 4;
    return total.round();
  }

  static int resolveReward(User user, {required bool isBoss, required int baseEssence}) {
    if (isBoss) {
      return calculateBossReward(user, baseEssence);
    }
    return calculateReward(user, baseEssence);
  }

  static int resolvePenalty(User user, {required bool isBoss, required int baseDamage}) {
    if (isBoss) {
      return calculateBossPenalty(user, baseDamage);
    }
    return calculatePenalty(user, baseDamage);
  }

  static int calculateCompletionDelta(
    User user,
    Task task, {
    required bool isCompleted,
  }) {
    final oldValue = task.isCompleted;
    if (oldValue == isCompleted) {
      return 0;
    }

    final reward = resolveReward(
      user,
      isBoss: task.isBoss,
      baseEssence: task.rewardValue,
    );

    if (oldValue && !isCompleted) {
      return -reward;
    }

    if (!oldValue && isCompleted) {
      return reward;
    }

    return 0;
  }
}
