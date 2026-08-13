import 'package:flutter_test/flutter_test.dart';
import 'package:bonfire/domain/models/character_class.dart';
import 'package:bonfire/domain/models/user.dart';

void main() {
  group('CharacterClass', () {
    test('should have at least three classes with correct stats', () { 
      const values = CharacterClass.values;
      expect(values.length, greaterThanOrEqualTo(3));

      const warrior = CharacterClass.warrior;
      expect(warrior.className, 'Warrior');
      expect(warrior.baseHp, 100);
      expect(warrior.essenceMultiplier, 1.0);
      expect(warrior.damageMultiplier, 1.0);
      expect(warrior.description.isNotEmpty, isTrue);
    });
  });

  group('User', () {
    test('should initialize hp values from selected class', () {
      const selectedClass = CharacterClass.warrior;
      final user = User(
        id: 'user-1',
        selectedClass: selectedClass,
        currentHp: selectedClass.baseHp,
        maxHp: selectedClass.baseHp,
        totalEssence: 0,
        currentStreak: 0,
      );

      expect(user.currentHp, selectedClass.baseHp);
      expect(user.maxHp, selectedClass.baseHp);
      expect(user.selectedClass, selectedClass);
    });
  });
}
