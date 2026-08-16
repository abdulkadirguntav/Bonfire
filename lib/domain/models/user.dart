import 'package:bonfire/domain/models/character_class.dart';

/// Persistent player state for Bonfire Phase 2.
class User {
  const User({
    required this.id,
    required this.selectedClass,
    required this.currentHp,
    required this.maxHp,
    required this.essence,
    required this.currentStreak,
    required this.maxStamina,
    required this.currentStamina,
    this.staminaUpdatedAt,
    this.lastDailyResolutionAt,
  });

  final String id;
  final CharacterClass selectedClass;
  final int currentHp;
  final int maxHp;
  final int essence;
  final int currentStreak;
  final int maxStamina;
  final int currentStamina;
  final DateTime? staminaUpdatedAt;
  final DateTime? lastDailyResolutionAt;

  factory User.create({
    required String id,
    required CharacterClass selectedClass,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    return User(
      id: id,
      selectedClass: selectedClass,
      currentHp: selectedClass.baseHp,
      maxHp: selectedClass.baseHp,
      essence: 0,
      currentStreak: 1,
      maxStamina: selectedClass.maxStamina,
      currentStamina: selectedClass.maxStamina,
      staminaUpdatedAt: currentTime,
    );
  }

  User copyWith({
    String? id,
    CharacterClass? selectedClass,
    int? currentHp,
    int? maxHp,
    int? essence,
    int? currentStreak,
    int? maxStamina,
    int? currentStamina,
    DateTime? staminaUpdatedAt,
    DateTime? lastDailyResolutionAt,
  }) {
    return User(
      id: id ?? this.id,
      selectedClass: selectedClass ?? this.selectedClass,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      essence: essence ?? this.essence,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStamina: maxStamina ?? this.maxStamina,
      currentStamina: currentStamina ?? this.currentStamina,
      staminaUpdatedAt: staminaUpdatedAt ?? this.staminaUpdatedAt,
      lastDailyResolutionAt:
          lastDailyResolutionAt ?? this.lastDailyResolutionAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'selectedClass': selectedClass.name,
        'currentHp': currentHp,
        'maxHp': maxHp,
        'essence': essence,
        'currentStreak': currentStreak,
        'maxStamina': maxStamina,
        'currentStamina': currentStamina,
        'staminaUpdatedAt': staminaUpdatedAt?.toIso8601String(),
        'lastDailyResolutionAt': lastDailyResolutionAt?.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) {
    final characterClass =
        CharacterClass.fromString(json['selectedClass'] as String?);
    final maxHp = json['maxHp'] as int? ?? characterClass.baseHp;
    final maxStam = json['maxStamina'] as int? ?? characterClass.maxStamina;

    return User(
      id: json['id'] as String? ?? '',
      selectedClass: characterClass,
      currentHp: json['currentHp'] as int? ?? maxHp,
      maxHp: maxHp,
      essence: json['essence'] as int? ?? json['totalEssence'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 1,
      maxStamina: maxStam,
      currentStamina: json['currentStamina'] as int? ?? maxStam,
      staminaUpdatedAt:
          DateTime.tryParse(json['staminaUpdatedAt'] as String? ?? ''),
      lastDailyResolutionAt:
          DateTime.tryParse(json['lastDailyResolutionAt'] as String? ?? ''),
    );
  }
}
