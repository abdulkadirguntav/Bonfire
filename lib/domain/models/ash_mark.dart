class AshMark {
  const AshMark({
    required this.id,
    required this.lostEssence,
    required this.targetStreak,
    required this.createdAt,
  });

  final String id;
  final int lostEssence;
  final int targetStreak;
  final DateTime createdAt;

  AshMark copyWith({
    String? id,
    int? lostEssence,
    int? targetStreak,
    DateTime? createdAt,
  }) {
    return AshMark(
      id: id ?? this.id,
      lostEssence: lostEssence ?? this.lostEssence,
      targetStreak: targetStreak ?? this.targetStreak,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lostEssence': lostEssence,
        'targetStreak': targetStreak,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AshMark.fromJson(Map<String, dynamic> json) {
    return AshMark(
      id: json['id'] as String? ?? '',
      lostEssence: json['lostEssence'] as int? ?? 0,
      targetStreak: json['targetStreak'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
