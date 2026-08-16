enum CharacterClass {
  warrior(
    className: 'Warrior',
    baseHp: 150,
    maxStamina: 100,
    damageMultiplier: 0.8,
    essenceMultiplier: 1.0,
    description: 'Yüksek can ve hasar direnci (0.8x) ile dayanıklı bir savaşçı.',
  ),
  mage(
    className: 'Mage',
    baseHp: 80,
    maxStamina: 150,
    damageMultiplier: 1.0,
    essenceMultiplier: 1.2,
    description: 'Yüksek stamina (150) ve ekstra Öz kazancı (1.2x) sağlayan disiplinli bir büyücü.',
  ),
  prisoner(
    className: 'Prisoner',
    baseHp: 50,
    maxStamina: 70,
    damageMultiplier: 1.5,
    essenceMultiplier: 1.5,
    description: 'Düşük can ve stamina, ancak 1.5x hasar ve 1.5x devasa ödül potansiyeli.',
  );

  const CharacterClass({
    required this.className,
    required this.baseHp,
    required this.maxStamina,
    required this.damageMultiplier,
    required this.essenceMultiplier,
    required this.description,
  });

  final String className;
  final int baseHp;
  final int maxStamina;
  final double damageMultiplier;
  final double essenceMultiplier;
  final String description;

  static CharacterClass fromString(String? value) =>
      CharacterClass.values.firstWhere(
        (c) => c.name == value || c.className.toLowerCase() == value?.toLowerCase(),
        orElse: () => CharacterClass.warrior,
      );

  String toJson() => name;
}
