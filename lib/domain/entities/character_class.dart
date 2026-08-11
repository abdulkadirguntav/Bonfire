class CharacterClass {
  final String id;
  final String name;
  final int maxHp;
  final int essencePerTask; // X: essence rewarded per standard task
  final int hpPenaltyPerMiss; // Y: HP penalty when a task is missed
  final int estusHealAmount; // amount healed by one Estus for this class

  const CharacterClass({
    required this.id,
    required this.name,
    required this.maxHp,
    required this.essencePerTask,
    required this.hpPenaltyPerMiss,
    required this.estusHealAmount,
  });

  static const CharacterClass warrior = CharacterClass(
    id: 'warrior',
    name: 'Warrior',
    maxHp: 8,
    essencePerTask: 1,
    hpPenaltyPerMiss: 1,
    estusHealAmount: 3,
  );

  static const CharacterClass wizard = CharacterClass(
    id: 'wizard',
    name: 'Wizard',
    maxHp: 6,
    essencePerTask: 2,
    hpPenaltyPerMiss: 1,
    estusHealAmount: 2,
  );

  static const CharacterClass prisoner = CharacterClass(
    id: 'prisoner',
    name: 'Prisoner',
    maxHp: 5,
    essencePerTask: 1,
    hpPenaltyPerMiss: 2,
    estusHealAmount: 2,
  );

  static const List<CharacterClass> presets = [
    warrior,
    wizard,
    prisoner,
  ];

  static CharacterClass? fromId(String id) {
    try {
      return presets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
