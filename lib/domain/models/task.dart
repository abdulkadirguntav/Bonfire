enum TaskCategory {
  physical(staminaCost: 40, essenceReward: 40, label: 'Fiziksel'),
  mental(staminaCost: 30, essenceReward: 30, label: 'Zihinsel'),
  mindful(staminaCost: 15, essenceReward: 15, label: 'Ruhsal'),
  routine(staminaCost: 10, essenceReward: 10, label: 'Rutin');

  const TaskCategory({
    required this.staminaCost,
    required this.essenceReward,
    required this.label,
  });

  final int staminaCost;
  final int essenceReward;
  final String label;

  static TaskCategory fromName(String? value) => TaskCategory.values.firstWhere(
        (category) => category.name == value,
        orElse: () => TaskCategory.routine,
      );
}

/// A recurring habit or one-off task. Completion dates are kept separately so
/// that a recurring habit can be resolved correctly after the day has passed.
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
    this.description = '',
    this.healthDamage = 10,
    this.habitTime,
    this.scheduledDays = const {},
    this.completedDateKeys = const {},
    this.acceptedWhileExhausted = false,
  });

  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final int healthDamage;
  final String? habitTime;
  final Set<int> scheduledDays;
  final Set<String> completedDateKeys;
  final DateTime createdAt;
  final bool acceptedWhileExhausted;

  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  bool isCompletedOn(DateTime date) => completedDateKeys.contains(dateKey(date));

  bool matchesDate(DateTime date) {
    if (scheduledDays.isNotEmpty) return scheduledDays.contains(date.weekday);
    return dateKey(createdAt) == dateKey(date);
  }

  Task copyWith({
    String? title,
    String? description,
    TaskCategory? category,
    int? healthDamage,
    String? habitTime,
    Set<int>? scheduledDays,
    Set<String>? completedDateKeys,
    bool? acceptedWhileExhausted,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      healthDamage: healthDamage ?? this.healthDamage,
      habitTime: habitTime ?? this.habitTime,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      completedDateKeys: completedDateKeys ?? this.completedDateKeys,
      createdAt: createdAt,
      acceptedWhileExhausted:
          acceptedWhileExhausted ?? this.acceptedWhileExhausted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'healthDamage': healthDamage,
        'habitTime': habitTime,
        'scheduledDays': scheduledDays.toList(),
        'completedDateKeys': completedDateKeys.toList(),
        'createdAt': createdAt.toIso8601String(),
        'acceptedWhileExhausted': acceptedWhileExhausted,
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.now();
    final legacyCompletedOn =
        DateTime.tryParse(json['completedOn'] as String? ?? '');
    final completedKeys = (json['completedDateKeys'] as List? ?? [])
        .whereType<String>()
        .toSet();
    if (legacyCompletedOn != null) completedKeys.add(dateKey(legacyCompletedOn));

    return Task(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: TaskCategory.fromName(json['category'] as String?),
      healthDamage: json['healthDamage'] as int? ?? 10,
      habitTime: json['habitTime'] as String?,
      scheduledDays: (json['scheduledDays'] as List? ?? []).cast<int>().toSet(),
      completedDateKeys: completedKeys,
      createdAt: createdAt,
      acceptedWhileExhausted: json['acceptedWhileExhausted'] as bool? ?? false,
    );
  }
}
