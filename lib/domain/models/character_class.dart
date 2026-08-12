enum CharacterClass {
  warrior(
    className: 'Warrior',
    baseHp: 100,
    essenceMultiplier: 1.0,
    damageMultiplier: 1.0,
    description:
        'A steadfast guardian forged in the heat of battle. Reliable and resilient.',
  ),
  mage(
    className: 'Mage',
    baseHp: 120,
    essenceMultiplier: 1.25,
    damageMultiplier: 0.9,
    description:
        'A disciplined spellcaster who earns more Essence but is less durable.',
  ),
  prisoner(
    className: 'Prisoner',
    baseHp: 80,
    essenceMultiplier: 0.9,
    damageMultiplier: 1.1,
    description:
        'A hardened survivor with fragile health and dangerous momentum.',
  );

  const CharacterClass({
    required this.className,
    required this.baseHp,
    required this.essenceMultiplier,
    required this.damageMultiplier,
    required this.description,
  });

  final String className;
  final int baseHp;
  final double essenceMultiplier;
  final double damageMultiplier;
  final String description;

  static CharacterClass fromString(String? value) {
    return CharacterClass.values.firstWhere(
      (characterClass) => characterClass.name == value,
      orElse: () => CharacterClass.warrior,
    );
  }

  String toJson() => name;
}
