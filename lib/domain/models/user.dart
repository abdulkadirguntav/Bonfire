import 'package:bonfire/domain/models/character_class.dart';
import 'package:bonfire/domain/models/shop_item.dart';
import 'package:bonfire/domain/models/task.dart';

/// Persistent player state for Bonfire Phase 3.
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

  static const int maxStaminaDefault = 100;

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
      inventory: inv,
      activePurgingStones: json['activePurgingStones'] as int? ?? 0,
      activeStasisDateKeys: stasisSet,
      claimedMilestones: milestoneSet,
      equippedAuraId: json['equippedAuraId'] as String?,
      equippedTitleId: json['equippedTitleId'] as String?,
    );
  }
}
