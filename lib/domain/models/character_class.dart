enum CharacterClass {
  mage(
    className: 'Mage',
    baseHp: 150,
    maxStamina: 50,
    damageMultiplier: 0.75,
    essenceMultiplier: 1.0,
    description: 'Yeni başlayanlar ve alışkanlık bilinci arayanlar için. Yüksek can (150) ve düşük ceza hasarı (%75).',
  ),
  warrior(
    className: 'Warrior',
    baseHp: 100,
    maxStamina: 100,
    damageMultiplier: 1.0,
    essenceMultiplier: 1.0,
    description: 'Dengeli deneyim arayanlar için. 100 Can, 100 Stamina ve standart risk oranı.',
  ),
  prisoner(
    className: 'Prisoner',
    baseHp: 50,
    maxStamina: 150,
    damageMultiplier: 1.25,
    essenceMultiplier: 1.5,
    description: 'Sadece cesareti olanlar için. 50 Can, 150 Stamina, 1.25x ceza hasarı ve 1.5x devasa Öz ödülü.',
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
