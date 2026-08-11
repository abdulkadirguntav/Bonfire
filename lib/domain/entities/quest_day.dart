import 'task.dart';

class QuestDay {
  final DateTime date;
  final List<Task> tasks;
  bool isSettled;

  QuestDay({
    required this.date,
    required this.tasks,
    this.isSettled = false,
  });

  Task? get bossTask => tasks.firstWhere(
        (task) => task.isBoss,
        orElse: () => Task(
          id: 'none',
          title: 'No Boss',
          scheduledDate: date,
          essenceReward: 0,
          hpPenalty: 0,
          isBoss: false,
        ),
      );

  List<Task> get pendingTasks => tasks.where((task) => task.isPending).toList();
}
