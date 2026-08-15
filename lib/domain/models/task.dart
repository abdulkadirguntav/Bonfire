enum TaskCategory {
  physical(staminaCost: 40, essenceReward: 40, label: 'Fiziksel'),
  mental(staminaCost: 30, essenceReward: 30, label: 'Zihinsel'),
  mindful(staminaCost: 15, essenceReward: 15, label: 'Ruhsal'),
  routine(staminaCost: 10, essenceReward: 10, label: 'Rutin');

  const TaskCategory({required this.staminaCost, required this.essenceReward, required this.label});
  final int staminaCost;
  final int essenceReward;
  final String label;
  static TaskCategory fromName(String? value) => TaskCategory.values.firstWhere((c) => c.name == value, orElse: () => TaskCategory.routine);
}

class Task {
  const Task({required this.id, required this.title, required this.category, required this.createdAt, this.description = '', this.healthDamage = 10, this.habitTime, this.scheduledDays = const {}, this.completedOn, this.acceptedWhileExhausted = false, this.isBoss = false, this.isCompleted = false, this.rewardValue = 10});
  final String id; final String title; final String description; final TaskCategory category; final int healthDamage; final String? habitTime; final Set<int> scheduledDays; final DateTime createdAt; final DateTime? completedOn; final bool acceptedWhileExhausted; final bool isBoss; final bool isCompleted; final int rewardValue;
  bool isCompletedOn(DateTime date) => completedOn != null && completedOn!.year == date.year && completedOn!.month == date.month && completedOn!.day == date.day;
  Task copyWith({String? id, String? title, String? description, TaskCategory? category, int? healthDamage, String? habitTime, Set<int>? scheduledDays, DateTime? createdAt, DateTime? completedOn, bool clearCompletedOn = false, bool? acceptedWhileExhausted, bool? isBoss, bool? isCompleted, int? rewardValue}) => Task(id: id ?? this.id, title: title ?? this.title, description: description ?? this.description, category: category ?? this.category, healthDamage: healthDamage ?? this.healthDamage, habitTime: habitTime ?? this.habitTime, scheduledDays: scheduledDays ?? this.scheduledDays, createdAt: createdAt ?? this.createdAt, completedOn: clearCompletedOn ? null : completedOn ?? this.completedOn, acceptedWhileExhausted: acceptedWhileExhausted ?? this.acceptedWhileExhausted, isBoss: isBoss ?? this.isBoss, isCompleted: isCompleted ?? this.isCompleted, rewardValue: rewardValue ?? this.rewardValue);
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'description': description, 'category': category.name, 'healthDamage': healthDamage, 'habitTime': habitTime, 'scheduledDays': scheduledDays.toList(), 'createdAt': createdAt.toIso8601String(), 'completedOn': completedOn?.toIso8601String(), 'acceptedWhileExhausted': acceptedWhileExhausted, 'isBoss': isBoss, 'isCompleted': isCompleted, 'rewardValue': rewardValue};
  factory Task.fromJson(Map<String, dynamic> json) { final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(); return Task(id: json['id'] as String? ?? '', title: json['title'] as String? ?? '', description: json['description'] as String? ?? '', category: TaskCategory.fromName(json['category'] as String?), healthDamage: json['healthDamage'] as int? ?? 10, habitTime: json['habitTime'] as String?, scheduledDays: (json['scheduledDays'] as List? ?? []).cast<int>().toSet(), createdAt: createdAt, completedOn: DateTime.tryParse(json['completedOn'] as String? ?? '') ?? ((json['isCompleted'] as bool? ?? false) ? createdAt : null), acceptedWhileExhausted: json['acceptedWhileExhausted'] as bool? ?? false, isBoss: json['isBoss'] as bool? ?? false, isCompleted: json['isCompleted'] as bool? ?? false, rewardValue: json['rewardValue'] as int? ?? 10); }
  bool matchesDate(DateTime date) => scheduledDays.isNotEmpty ? scheduledDays.contains(date.weekday) : (createdAt.year == date.year && createdAt.month == date.month && createdAt.day == date.day);
}
