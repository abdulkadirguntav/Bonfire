/// Model representing a long-term Boss (Willpower / Addiction battle).
class Boss {
  const Boss({
    required this.id,
    required this.title,
    required this.currentHp,
    required this.maxHp,
    this.phase = 1,
    this.lastInteractionDate,
  });

  final String id;
  final String title;
  final int currentHp;
  final int maxHp;
  final int phase;
  final DateTime? lastInteractionDate;

  static const int defaultInitialHp = 30;
  static const int dailyResistEssence = 0; // Direndim gives 0 daily essence as per requirements
  static const int dailyFailDamage = 40;

  static int maxHpForPhase(int phase) {
    switch (phase) {
      case 1:
        return 30;
      case 2:
        return 90;
      case 3:
        return 180;
      case 4:
      default:
        return 365;
    }
  }

  static int rewardForPhaseCompletion(int completedPhase) {
    switch (completedPhase) {
      case 1:
        return 150;
      case 2:
        return 400;
      case 3:
        return 1000;
      case 4:
      default:
        return 2500;
    }
  }

  bool isDefeated() => currentHp <= 0;

  bool wasInteractedOn(DateTime date) {
    if (lastInteractionDate == null) return false;
    return lastInteractionDate!.year == date.year &&
        lastInteractionDate!.month == date.month &&
        lastInteractionDate!.day == date.day;
  }

  Boss copyWith({
    String? id,
    String? title,
    int? currentHp,
    int? maxHp,
    int? phase,
    DateTime? lastInteractionDate,
  }) {
    return Boss(
      id: id ?? this.id,
      title: title ?? this.title,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      phase: phase ?? this.phase,
      lastInteractionDate: lastInteractionDate ?? this.lastInteractionDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'currentHp': currentHp,
        'maxHp': maxHp,
        'phase': phase,
        'lastInteractionDate': lastInteractionDate?.toIso8601String(),
      };

  factory Boss.fromJson(Map<String, dynamic> json) {
    final phase = json['phase'] as int? ?? 1;
    final maxHp = json['maxHp'] as int? ?? maxHpForPhase(phase);
    return Boss(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      currentHp: json['currentHp'] as int? ?? maxHp,
      maxHp: maxHp,
      phase: phase,
      lastInteractionDate:
          DateTime.tryParse(json['lastInteractionDate'] as String? ?? ''),
    );
  }
}
