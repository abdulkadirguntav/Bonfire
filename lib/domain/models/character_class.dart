enum CharacterClass {
  warrior(
    className: 'Warrior',
    baseHp: 150,
    maxStamina: 100,
    essenceMultiplier: 1.0,
    damageMultiplier: 0.8,
    description:
        'A steadfast guardian forged in the heat of battle. Reliable and resilient.',
  ),
  mage(
    className: 'Mage',
    baseHp: 80,
    maxStamina: 150,
    essenceMultiplier: 1.2,
    damageMultiplier: 1.0,
    description:
        'A disciplined spellcaster who earns more Essence and has high stamina.',
  ),
  prisoner(
    className: 'Prisoner',
    baseHp: 50,
    maxStamina: 70,
    essenceMultiplier: 1.5,
    damageMultiplier: 1.5,
    description:
        'A hardened survivor with fragile health but dangerous potential.',
  );

  const CharacterClass({
    required this.className,
    required this.baseHp,
    required this.maxStamina,
    required this.essenceMultiplier,
    required this.damageMultiplier,
    required this.description,
  });

  final String className;
  final int baseHp;
  final int maxStamina;
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
