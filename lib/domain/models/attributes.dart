import 'dart:math';

/// 4 Core Attributes for Bonfire character progression.
enum AttributeType {
  vitality(
    id: 'vitality',
    name: 'Vitality',
    nameTr: 'Can (Kudret)',
    description:
        'Bedenin dayanıklılığı. Her seviye maxHp değerini +15 artırır.',
    iconName: 'favorite',
  ),
  endurance(
    id: 'endurance',
    name: 'Endurance',
    nameTr: 'Dayanıklılık',
    description: 'Ruhun enerjisi. Her seviye maxStamina değerini +10 artırır.',
    iconName: 'bolt',
  ),
  strength(
    id: 'strength',
    name: 'Strength',
    nameTr: 'İrade (Kuvvet)',
    description:
        'Yeminlerin gücü. Her seviye kazanılan Öz çarpanını +%5 artırır.',
    iconName: 'fitness_center',
  ),
  adaptability(
    id: 'adaptability',
    name: 'Adaptability',
    nameTr: 'Uyum',
    description:
        'Hatalara karşı direnç. Her seviye alınan ceza hasarını -%4 azaltır.',
    iconName: 'shield',
  );

  const AttributeType({
    required this.id,
    required this.name,
    required this.nameTr,
    required this.description,
    required this.iconName,
  });

  final String id;
  final String name;
  final String nameTr;
  final String description;
  final String iconName;

  String get nameEn => name;
  String get descriptionTr => description;
  String get descriptionEn {
    switch (this) {
      case AttributeType.vitality:
        return 'Fortitude of body. Each level grants +15 Max HP.';
      case AttributeType.endurance:
        return 'Energy of spirit. Each level grants +10 Max Stamina.';
      case AttributeType.strength:
        return 'Power of vows. Each level increases Essence multiplier by +5%.';
      case AttributeType.adaptability:
        return 'Resilience against failure. Each level reduces penalty damage by -4%.';
    }
  }

  /// RPG Exponential Level-up Cost Formula
  /// Level 0 -> 100 Essence
  /// Level 1 -> 145 Essence
  /// Level 2 -> 210 Essence
  /// Level 3 -> 305 Essence, etc.
  static int costForLevel(int currentLevel) {
    if (currentLevel <= 0) return 100;
    return (100 * pow(1.45, currentLevel)).round();
  }
}
