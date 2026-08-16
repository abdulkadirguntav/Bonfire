import 'package:bonfire/domain/models/attributes.dart';
import 'package:bonfire/domain/models/character_class.dart';
import 'package:bonfire/domain/models/shop_item.dart';
import 'package:bonfire/domain/models/task.dart';

/// Persistent player state for Bonfire Phase 5.
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
    this.inventory = const {},
    this.activePurgingStones = 0,
    this.activeStasisDateKeys = const {},
    this.claimedMilestones = const {},
    this.equippedAuraId,
    this.equippedTitleId,
    // Phase 5 Attributes & Statistics
    this.vitalityLevel = 0,
    this.enduranceLevel = 0,
    this.strengthLevel = 0,
    this.adaptabilityLevel = 0,
    this.enemiesDefeated = 0,
    this.bossPhasesDefeated = 0,
    this.deathCount = 0,
    this.ashMarksReclaimed = 0,
    this.highestStreak = 1,
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

  // Phase 3 Inventory & Bonfire Mechanics
  final Map<String, int> inventory;
  final int activePurgingStones;
  final Set<String> activeStasisDateKeys;
  final Set<int> claimedMilestones;
  final String? equippedAuraId;
  final String? equippedTitleId;

  // Phase 5 Core Attributes (Levels)
  final int vitalityLevel;
  final int enduranceLevel;
  final int strengthLevel;
  final int adaptabilityLevel;

  // Phase 5 Lifetime Statistics
  final int enemiesDefeated;
  final int bossPhasesDefeated;
  final int deathCount;
  final int ashMarksReclaimed;
  final int highestStreak;

  static const int maxStaminaDefault = 100;

  int get totalLevel =>
      vitalityLevel + enduranceLevel + strengthLevel + adaptabilityLevel;

  /// Essence multiplier combining Class trait + Strength levels (+5% per level)
  double get totalEssenceMultiplier =>
      selectedClass.essenceMultiplier + (strengthLevel * 0.05);

  /// Damage taken multiplier combining Class trait - Adaptability levels (-4% per level)
  double get totalDamageMultiplier =>
      (selectedClass.damageMultiplier - (adaptabilityLevel * 0.04))
          .clamp(0.20, 2.5);

  /// Stat upgrade (+) buttons are enabled ONLY on Bonfire streak days (3, 7, 14, 30)
  bool get isAtBonfireDay => const [3, 7, 14, 30].contains(currentStreak);

  int attributeLevel(AttributeType type) {
    switch (type) {
      case AttributeType.vitality:
        return vitalityLevel;
      case AttributeType.endurance:
        return enduranceLevel;
      case AttributeType.strength:
        return strengthLevel;
      case AttributeType.adaptability:
        return adaptabilityLevel;
    }
  }

  int itemCount(String itemId) => inventory[itemId] ?? 0;

  bool get hasRingOfSacrifice =>
      (inventory[ItemType.ringOfSacrifice.id] ?? 0) > 0;

  bool isStasisActiveOn(DateTime date) =>
      activeStasisDateKeys.contains(Task.dateKey(date));

  bool hasClaimedMilestone(int streak) => claimedMilestones.contains(streak);

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
      inventory: const {},
      activePurgingStones: 0,
      activeStasisDateKeys: const {},
      claimedMilestones: const {},
      vitalityLevel: 0,
      enduranceLevel: 0,
      strengthLevel: 0,
      adaptabilityLevel: 0,
      enemiesDefeated: 0,
      bossPhasesDefeated: 0,
      deathCount: 0,
      ashMarksReclaimed: 0,
      highestStreak: 1,
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
    Map<String, int>? inventory,
    int? activePurgingStones,
    Set<String>? activeStasisDateKeys,
    Set<int>? claimedMilestones,
    String? equippedAuraId,
    String? equippedTitleId,
    int? vitalityLevel,
    int? enduranceLevel,
    int? strengthLevel,
    int? adaptabilityLevel,
    int? enemiesDefeated,
    int? bossPhasesDefeated,
    int? deathCount,
    int? ashMarksReclaimed,
    int? highestStreak,
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
      inventory: inventory ?? this.inventory,
      activePurgingStones: activePurgingStones ?? this.activePurgingStones,
      activeStasisDateKeys: activeStasisDateKeys ?? this.activeStasisDateKeys,
      claimedMilestones: claimedMilestones ?? this.claimedMilestones,
      equippedAuraId: equippedAuraId ?? this.equippedAuraId,
      equippedTitleId: equippedTitleId ?? this.equippedTitleId,
      vitalityLevel: vitalityLevel ?? this.vitalityLevel,
      enduranceLevel: enduranceLevel ?? this.enduranceLevel,
      strengthLevel: strengthLevel ?? this.strengthLevel,
      adaptabilityLevel: adaptabilityLevel ?? this.adaptabilityLevel,
      enemiesDefeated: enemiesDefeated ?? this.enemiesDefeated,
      bossPhasesDefeated: bossPhasesDefeated ?? this.bossPhasesDefeated,
      deathCount: deathCount ?? this.deathCount,
      ashMarksReclaimed: ashMarksReclaimed ?? this.ashMarksReclaimed,
      highestStreak: highestStreak ?? this.highestStreak,
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
        'inventory': inventory,
        'activePurgingStones': activePurgingStones,
        'activeStasisDateKeys': activeStasisDateKeys.toList(),
        'claimedMilestones': claimedMilestones.toList(),
        'equippedAuraId': equippedAuraId,
        'equippedTitleId': equippedTitleId,
        'vitalityLevel': vitalityLevel,
        'enduranceLevel': enduranceLevel,
        'strengthLevel': strengthLevel,
        'adaptabilityLevel': adaptabilityLevel,
        'enemiesDefeated': enemiesDefeated,
        'bossPhasesDefeated': bossPhasesDefeated,
        'deathCount': deathCount,
        'ashMarksReclaimed': ashMarksReclaimed,
        'highestStreak': highestStreak,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    final characterClass =
        CharacterClass.fromString(json['selectedClass'] as String?);
    final maxHp = json['maxHp'] as int? ?? characterClass.baseHp;
    final maxStam = json['maxStamina'] as int? ?? characterClass.maxStamina;

    final rawInv = json['inventory'];
    final Map<String, int> inv = {};
    if (rawInv is Map) {
      rawInv.forEach((key, value) {
        if (value is int) inv[key.toString()] = value;
      });
    }

    final rawStasis = json['activeStasisDateKeys'] as List<dynamic>? ?? [];
    final stasisSet = rawStasis.map((e) => e.toString()).toSet();

    final rawMilestones = json['claimedMilestones'] as List<dynamic>? ?? [];
    final milestoneSet = rawMilestones.whereType<int>().toSet();

    final streak = json['currentStreak'] as int? ?? 1;
    final storedHighest = json['highestStreak'] as int? ?? streak;

    return User(
      id: json['id'] as String? ?? '',
      selectedClass: characterClass,
      currentHp: json['currentHp'] as int? ?? maxHp,
      maxHp: maxHp,
      essence: json['essence'] as int? ?? json['totalEssence'] as int? ?? 0,
      currentStreak: streak,
      maxStamina: maxStam,
      currentStamina: json['currentStamina'] as int? ?? maxStam,
      staminaUpdatedAt:
          DateTime.tryParse(json['staminaUpdatedAt'] as String? ?? ''),
      lastDailyResolutionAt:
          DateTime.tryParse(json['lastDailyResolutionAt'] as String? ?? ''),
      inventory: inv,
      activePurgingStones: json['activePurgingStones'] as int? ?? 0,
      activeStasisDateKeys: stasisSet,
      claimedMilestones: milestoneSet,
      equippedAuraId: json['equippedAuraId'] as String?,
      equippedTitleId: json['equippedTitleId'] as String?,
      vitalityLevel: json['vitalityLevel'] as int? ?? 0,
      enduranceLevel: json['enduranceLevel'] as int? ?? 0,
      strengthLevel: json['strengthLevel'] as int? ?? 0,
      adaptabilityLevel: json['adaptabilityLevel'] as int? ?? 0,
      enemiesDefeated: json['enemiesDefeated'] as int? ?? 0,
      bossPhasesDefeated: json['bossPhasesDefeated'] as int? ?? 0,
      deathCount: json['deathCount'] as int? ?? 0,
      ashMarksReclaimed: json['ashMarksReclaimed'] as int? ?? 0,
      highestStreak: storedHighest > streak ? storedHighest : streak,
    );
  }
}
