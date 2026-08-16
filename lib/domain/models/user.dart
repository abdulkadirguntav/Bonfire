/// Persistent player state for Bonfire Phase 1.
class User {
  const User({
    required this.id,
    required this.currentHp,
    required this.maxHp,
    required this.essence,
    required this.currentStreak,
    this.currentStamina = maxStamina,
    this.staminaUpdatedAt,
    this.lastDailyResolutionAt,
  });

  static const int maxStamina = 100;
  static const int defaultMaxHp = 100;

  final String id;
  final int currentHp;
  final int maxHp;
  final int essence;
  final int currentStreak;
  final int currentStamina;
  final DateTime? staminaUpdatedAt;
  final DateTime? lastDailyResolutionAt;

  User copyWith({
    String? id,
    int? currentHp,
    int? maxHp,
    int? essence,
    int? currentStreak,
    int? currentStamina,
    DateTime? staminaUpdatedAt,
    DateTime? lastDailyResolutionAt,
  }) {
    return User(
      id: id ?? this.id,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      essence: essence ?? this.essence,
      currentStreak: currentStreak ?? this.currentStreak,
      currentStamina: currentStamina ?? this.currentStamina,
      staminaUpdatedAt: staminaUpdatedAt ?? this.staminaUpdatedAt,
      lastDailyResolutionAt:
          lastDailyResolutionAt ?? this.lastDailyResolutionAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'currentHp': currentHp,
        'maxHp': maxHp,
        'essence': essence,
        'currentStreak': currentStreak,
        'currentStamina': currentStamina,
        'staminaUpdatedAt': staminaUpdatedAt?.toIso8601String(),
        'lastDailyResolutionAt': lastDailyResolutionAt?.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      currentHp: json['currentHp'] as int? ?? defaultMaxHp,
      maxHp: json['maxHp'] as int? ?? defaultMaxHp,
      // `totalEssence` keeps saves from pre-Phase 1 builds readable.
      essence: json['essence'] as int? ?? json['totalEssence'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      currentStamina: json['currentStamina'] as int? ?? maxStamina,
      staminaUpdatedAt:
          DateTime.tryParse(json['staminaUpdatedAt'] as String? ?? ''),
      lastDailyResolutionAt:
          DateTime.tryParse(json['lastDailyResolutionAt'] as String? ?? ''),
    );
  }
}
