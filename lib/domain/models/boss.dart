class Boss {
  const Boss({
    required this.id,
    required this.title,
    required this.currentHp,
    required this.maxHp,
    this.phase = 1,
  });

  final String id;
  final String title;
  final int currentHp;
  final int maxHp;
  final int phase;

  Boss copyWith({
    String? id,
    String? title,
    int? currentHp,
    int? maxHp,
    int? phase,
  }) {
    return Boss(
      id: id ?? this.id,
      title: title ?? this.title,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      phase: phase ?? this.phase,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'currentHp': currentHp,
        'maxHp': maxHp,
        'phase': phase,
      };

  factory Boss.fromJson(Map<String, dynamic> json) => Boss(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        currentHp: json['currentHp'] as int? ?? 30,
        maxHp: json['maxHp'] as int? ?? 30,
        phase: json['phase'] as int? ?? 1,
      );
}
