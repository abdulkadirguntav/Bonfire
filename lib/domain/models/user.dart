import 'package:bonfire/domain/models/character_class.dart';

class User {
  const User({
    required this.id,
    required this.selectedClass,
    required this.currentHp,
    required this.maxHp,
    required this.totalEssence,
    required this.currentStreak,
    this.currentStamina = 100,
    this.staminaUpdatedAt,
    this.hasDefeatedFirstBoss = false,
  });

  final String id;
  final CharacterClass selectedClass;
  final int currentHp;
  final int maxHp;
  final int totalEssence;
  final int currentStamina;
  final DateTime? staminaUpdatedAt;
  final int currentStreak;
  final bool hasDefeatedFirstBoss;

  User copyWith({
    String? id,
    CharacterClass? selectedClass,
    int? currentHp,
    int? maxHp,
    int? totalEssence,
    int? currentStreak,
    int? currentStamina,
    DateTime? staminaUpdatedAt,
    bool? hasDefeatedFirstBoss,
  }) {
    return User(
      id: id ?? this.id,
      selectedClass: selectedClass ?? this.selectedClass,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      totalEssence: totalEssence ?? this.totalEssence,
      currentStreak: currentStreak ?? this.currentStreak,
      currentStamina: currentStamina ?? this.currentStamina,
      staminaUpdatedAt: staminaUpdatedAt ?? this.staminaUpdatedAt,
      hasDefeatedFirstBoss: hasDefeatedFirstBoss ?? this.hasDefeatedFirstBoss,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'selectedClass': selectedClass.name,
      'currentHp': currentHp,
      'maxHp': maxHp,
      'totalEssence': totalEssence,
      'currentStamina': currentStamina,
      'staminaUpdatedAt': staminaUpdatedAt?.toIso8601String(),
      'currentStreak': currentStreak,
      'hasDefeatedFirstBoss': hasDefeatedFirstBoss,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      selectedClass: CharacterClass.fromString(json['selectedClass'] as String?),
      currentHp: json['currentHp'] as int? ?? 0,
      maxHp: json['maxHp'] as int? ?? 0,
      totalEssence: json['totalEssence'] as int? ?? 0,
      currentStamina: json['currentStamina'] as int? ?? 100,
      staminaUpdatedAt: DateTime.tryParse(json['staminaUpdatedAt'] as String? ?? ''),
      currentStreak: json['currentStreak'] as int? ?? 0,
      hasDefeatedFirstBoss: json['hasDefeatedFirstBoss'] as bool? ?? false,
    );
  }
}
