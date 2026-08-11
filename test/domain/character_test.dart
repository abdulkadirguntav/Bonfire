import 'package:flutter_test/flutter_test.dart';
import 'package:bonfire/domain/entities/character_class.dart';
import 'package:bonfire/domain/entities/character.dart';

void main() {
  test('Character preset classes have expected values', () {
    final warrior = CharacterClass.warrior;
    expect(warrior.maxHp, 8);
    expect(warrior.essencePerTask, 1);

    final wizard = CharacterClass.wizard;
    expect(wizard.essencePerTask, 2);

    final prisoner = CharacterClass.prisoner;
    expect(prisoner.hpPenaltyPerMiss, 2);
  });

  test('Character takes damage and heals correctly', () {
    final char = Character(id: '1', name: 'Player', characterClass: CharacterClass.warrior);
    expect(char.currentHp, CharacterClass.warrior.maxHp);
    char.takeDamage(3);
    expect(char.currentHp, CharacterClass.warrior.maxHp - 3);
    char.heal(2);
    expect(char.currentHp, CharacterClass.warrior.maxHp - 1);
  });
}
