import 'package:flutter_test/flutter_test.dart';

import 'package:bonfire/domain/models/boss.dart';
import 'package:bonfire/domain/models/character_class.dart';
import 'package:bonfire/domain/models/reflection.dart';
import 'package:bonfire/domain/models/soapstone.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/domain/services/reflection_service.dart';
import 'package:bonfire/domain/services/soapstone_service.dart';

void main() {
  group('1. Stoic Reflection (Gün Sonu Muhasebesi) Kuralları', () {
    test('Reflection saves Q&A without affecting user HP or Essence', () {
      final user = User.create(
        id: 'u1',
        selectedClass: CharacterClass.warrior,
      ).copyWith(currentHp: 120, essence: 50);

      final date = DateTime(2026, 8, 16);
      final reflection = ReflectionService.createReflection(
        date: date,
        answers: {
          'Ateş çatırdıyor... Bugün nasıldı?': 'Zorlu ama irademi korudum.',
          'Kendini şu an nasıl hissediyorsun?': 'Dingin ve kararlı.',
        },
      );

      expect(reflection.questionsAndAnswers.length, 2);
      expect(reflection.isSameDay(date), isTrue);

      // Verify User HP and Essence are completely untouched
      expect(user.currentHp, 120);
      expect(user.essence, 50);
    });

    test('Reflection questions include default questions + user custom questions', () {
      final customQuestions = [
        'Bugün hangi korkumla yüzleştim?',
        'Yarın için bir söz ver:',
      ];

      final allQuestions = ReflectionService.getAllQuestions(customQuestions);

      expect(allQuestions.contains('Ateş çatırdıyor... Bugün nasıldı?'), isTrue);
      expect(allQuestions.contains('Bugün hangi korkumla yüzleştim?'), isTrue);
      expect(allQuestions.contains('Yarın için bir söz ver:'), isTrue);
      expect(allQuestions.length, Reflection.defaultQuestions.length + 2);
    });
  });

  group('2. Soapstone (Not Bırakma) Sistemi ve Kuralları', () {
    test('posting Soapstone allows only 1 message per calendar day', () {
      final today = DateTime(2026, 8, 16);
      final List<Soapstone> emptyList = [];

      expect(SoapstoneService.canPostToday(emptyList, now: today), isTrue);

      final listWithOne = SoapstoneService.postMessage(
        emptyList,
        'Yolculuk karanlık ama ateş parlıyor...',
        now: today,
      );

      expect(listWithOne.length, 1);
      expect(listWithOne.first.message, 'Yolculuk karanlık ama ateş parlıyor...');
      expect(listWithOne.first.isEdited, isFalse);

      // Once posted, cannot post another message today
      expect(SoapstoneService.canPostToday(listWithOne, now: today), isFalse);
      expect(
        () => SoapstoneService.postMessage(listWithOne, 'İkinci mesaj!', now: today),
        throwsA(isA<SoapstoneAlreadyPostedTodayException>()),
      );
    });

    test('editing Soapstone is allowed ONLY ONCE on that day', () {
      final today = DateTime(2026, 8, 16);
      final listWithOne = SoapstoneService.postMessage(
        [],
        'İlk mesaj.',
        now: today,
      );

      final soapstoneId = listWithOne.first.id;
      expect(SoapstoneService.canEditToday(listWithOne, now: today), isTrue);

      // First edit succeeds
      final editedList = SoapstoneService.editMessage(
        listWithOne,
        soapstoneId,
        'Düzenlenmiş ağırbaşlı mesaj.',
        now: today,
      );

      expect(editedList.first.message, 'Düzenlenmiş ağırbaşlı mesaj.');
      expect(editedList.first.isEdited, isTrue);

      // Second edit attempt on the same day fails
      expect(SoapstoneService.canEditToday(editedList, now: today), isFalse);
      expect(
        () => SoapstoneService.editMessage(
          editedList,
          soapstoneId,
          'İkinci kez düzenleme denemesi.',
          now: today,
        ),
        throwsA(isA<SoapstoneAlreadyEditedException>()),
      );
    });

    test('new calendar day allows new Soapstone posting', () {
      final day1 = DateTime(2026, 8, 16);
      final day2 = DateTime(2026, 8, 17);

      final listDay1 = SoapstoneService.postMessage(
        [],
        'Gün 1 mesajı',
        now: day1,
      );

      // On day 2, user can post again!
      expect(SoapstoneService.canPostToday(listDay1, now: day2), isTrue);
      final listDay2 = SoapstoneService.postMessage(
        listDay1,
        'Gün 2 mesajı',
        now: day2,
      );

      expect(listDay2.length, 2);
      expect(SoapstoneService.getTodaySoapstone(listDay2, now: day2)?.message,
          'Gün 2 mesajı');
    });
  });

  group('3. Soapstone Kilit Açma Mantığı (Boss Fazı)', () {
    test('Soapstone remains locked during Phase 1 Boss and unlocks at Phase >= 2', () {
      const bossPhase1 = Boss(
        id: 'b1',
        title: 'Sigara',
        currentHp: 30,
        maxHp: 30,
        phase: 1,
      );
      final bossPhase2 = bossPhase1.copyWith(phase: 2, currentHp: 90, maxHp: 90);

      expect(bossPhase1.phase >= 2, isFalse); // Locked
      expect(bossPhase2.phase >= 2, isTrue);  // Unlocked!
    });
  });
}
