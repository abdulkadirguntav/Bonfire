enum TaskStatus { pending, completed, missed }

class Task {
  final String id;
  final String title;
  final DateTime scheduledDate;
  final int essenceReward;
  final int hpPenalty;
  final bool isBoss;
  TaskStatus status;

  Task({
    required this.id,
    required this.title,
    required this.scheduledDate,
    required this.essenceReward,
    required this.hpPenalty,
    this.isBoss = false,
    this.status = TaskStatus.pending,
  });

  bool get isCompleted => status == TaskStatus.completed;
  bool get isMissed => status == TaskStatus.missed;
  bool get isPending => status == TaskStatus.pending;

  void complete() {
    status = TaskStatus.completed;
  }

  void miss() {
    status = TaskStatus.missed;
  }
}
