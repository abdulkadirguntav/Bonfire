import 'dart:math';

/// 4 Core Attributes for Bonfire character progression.
enum AttributeType {
  vitality(
    id: 'vitality',
    name: 'Vitality',
    nameTr: 'Can (Kudret)',
    description: 'Bedenin dayanıklılığı. Her seviye maxHp değerini +15 artırır.',
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
    description: 'Yeminlerin gücü. Her seviye kazanılan Öz çarpanını +%5 artırır.',
    iconName: 'fitness_center',
  ),
  adaptability(
    id: 'adaptability',
    name: 'Adaptability',
    nameTr: 'Uyum',
    description: 'Hatalara karşı direnç. Her seviye alınan ceza hasarını -%4 azaltır.',
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

  /// RPG Exponential Level-up Cost Formula
  /// Level 0 -> 50 Essence
  /// Level 1 -> 68 Essence
  /// Level 2 -> 91 Essence
  /// Level 3 -> 123 Essence, etc.
  static int costForLevel(int currentLevel) {
    if (currentLevel <= 0) return 50;
    return (50 * pow(1.35, currentLevel)).round();
  }
}
