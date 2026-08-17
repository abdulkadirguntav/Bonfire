enum TaskCategory {
  routine(staminaCost: 10, essenceReward: 3, label: 'Rutin'),
  physical(staminaCost: 35, essenceReward: 8, label: 'Fiziksel'),
  mental(staminaCost: 30, essenceReward: 8, label: 'Zihinsel'),
  spiritual(staminaCost: 20, essenceReward: 5, label: 'Ruhsal');

  const TaskCategory({
    required this.staminaCost,
    required this.essenceReward,
    required this.label,
  });

  final int staminaCost;
  final int essenceReward;
  final String label;

  static const TaskCategory mindful = TaskCategory.spiritual;

  static TaskCategory fromString(String? value) {
    if (value == 'mindful') return TaskCategory.spiritual;
    return TaskCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => TaskCategory.routine,
    );
  }
}

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.category,
    this.healthDamage = 15,
    required this.createdAt,
    this.description = '',
    this.completedDateKeys = const {},
    this.habitTime,
    this.isScheduled = false,
    this.selectedWeekdays = const {},
    Set<int>? scheduledDays,
    this.acceptedWhileExhausted = false,
  }) : _scheduledDays = scheduledDays;

  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final int healthDamage;
  final DateTime createdAt;
  final Set<String> completedDateKeys;
  final String? habitTime;
  final bool isScheduled;
  final Set<int> selectedWeekdays;
  final Set<int>? _scheduledDays;
  final bool acceptedWhileExhausted;

  Set<int> get scheduledDays => _scheduledDays ?? selectedWeekdays;

  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  bool isCompletedOn(DateTime date) =>
      completedDateKeys.contains(dateKey(date));

  bool matchesDate(DateTime date) {
    if (isScheduled || scheduledDays.isNotEmpty) {
      final days = scheduledDays;
      return days.contains(date.weekday);
    }
    final created = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final current = DateTime(date.year, date.month, date.day);
    return created == current;
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    int? healthDamage,
    DateTime? createdAt,
    Set<String>? completedDateKeys,
    String? habitTime,
    bool? isScheduled,
    Set<int>? selectedWeekdays,
    Set<int>? scheduledDays,
    bool? acceptedWhileExhausted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      healthDamage: healthDamage ?? this.healthDamage,
      createdAt: createdAt ?? this.createdAt,
      completedDateKeys: completedDateKeys ?? this.completedDateKeys,
      habitTime: habitTime ?? this.habitTime,
      isScheduled: isScheduled ?? this.isScheduled,
      selectedWeekdays: selectedWeekdays ?? this.selectedWeekdays,
      scheduledDays: scheduledDays ?? _scheduledDays,
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
        'createdAt': createdAt.toIso8601String(),
        'completedDateKeys': completedDateKeys.toList(),
        'habitTime': habitTime,
        'isScheduled': isScheduled,
        'selectedWeekdays': scheduledDays.toList(),
        'acceptedWhileExhausted': acceptedWhileExhausted,
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    final rawDates = json['completedDateKeys'] as List<dynamic>? ?? [];
    final dateKeys = rawDates.map((item) => item.toString()).toSet();
    final legacyCompleted = json['isCompleted'] as bool? ?? false;
    final created =
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
    if (legacyCompleted && dateKeys.isEmpty) {
      dateKeys.add(dateKey(created));
    }

    final rawWeekdays = json['selectedWeekdays'] as List<dynamic>? ??
        json['scheduledDays'] as List<dynamic>? ??
        [];
    final weekdays = rawWeekdays.whereType<int>().toSet();

    return Task(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: TaskCategory.fromString(json['category'] as String?),
      healthDamage: json['healthDamage'] as int? ?? 15,
      createdAt: created,
      completedDateKeys: dateKeys,
      habitTime: json['habitTime'] as String?,
      isScheduled: json['isScheduled'] as bool? ?? false,
      selectedWeekdays: weekdays,
      acceptedWhileExhausted: json['acceptedWhileExhausted'] as bool? ?? false,
    );
  }
}
