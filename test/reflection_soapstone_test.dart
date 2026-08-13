import 'package:flutter_test/flutter_test.dart';
import 'package:bonfire/domain/models/character_class.dart';
import 'package:bonfire/domain/models/soapstone.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/domain/services/soapstone_service.dart';

void main() {
  group('Soapstone unlock and daily rules', () {
    test('soapstone unlocks after first boss defeat', () {
      const user = User(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
        currentHp: 100,
        maxHp: 100,
        totalEssence: 0,
        currentStreak: 5,
        hasDefeatedFirstBoss: true,
      );

      expect(SoapstoneService.isUnlocked(user), isTrue);
    });

    test('same day only one soapstone can be created', () {
      final today = DateTime.now();
      final stones = [
        Soapstone(
          id: 's1',
          date: today,
          message: 'Remember the fire',
        ),
      ];

      expect(SoapstoneService.canCreateToday(stones, today), isFalse);
    });

    test('edited soapstone is locked for another edit', () {
      final today = DateTime.now();
      final stone = Soapstone(
        id: 's2',
        date: today,
        message: 'First message',
        isEdited: true,
      );

      expect(SoapstoneService.canEditToday(stone, today), isFalse);
    });
  });
}
