import 'task.dart';

class Boss {
  final String taskId;
  final int essenceMultiplier;
  final int hpPenaltyMultiplier;

  const Boss({
    required this.taskId,
    this.essenceMultiplier = 3,
    this.hpPenaltyMultiplier = 4,
  });

  int reward(int baseEssence) => baseEssence * essenceMultiplier;
  int penalty(int baseHp) => baseHp * hpPenaltyMultiplier;

  bool isBossTask(Task task) => task.id == taskId && task.isBoss;
}
