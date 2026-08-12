class Task {
  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isBoss = false,
    this.isCompleted = false,
    this.rewardValue = 10,
    this.habitTime,
    this.scheduledDays = const {},
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final bool isBoss;
  final bool isCompleted;
  final int rewardValue;
  final String? habitTime;
  final Set<int> scheduledDays;
  final DateTime createdAt;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isBoss,
    bool? isCompleted,
    int? rewardValue,
    String? habitTime,
    Set<int>? scheduledDays,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isBoss: isBoss ?? this.isBoss,
      isCompleted: isCompleted ?? this.isCompleted,
      rewardValue: rewardValue ?? this.rewardValue,
      habitTime: habitTime ?? this.habitTime,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isBoss': isBoss,
        'isCompleted': isCompleted,
        'rewardValue': rewardValue,
        'habitTime': habitTime,
        'scheduledDays': scheduledDays.toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    final scheduledDays = (json['scheduledDays'] as List? ?? []).map((day) => day as int).toSet();

    return Task(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isBoss: json['isBoss'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      rewardValue: json['rewardValue'] as int? ?? 10,
      habitTime: json['habitTime'] as String?,
      scheduledDays: scheduledDays,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  bool matchesDate(DateTime date) {
    if (scheduledDays.isNotEmpty) {
      return scheduledDays.contains(date.weekday);
    }

    return createdAt.year == date.year &&
        createdAt.month == date.month &&
        createdAt.day == date.day;
  }
}
