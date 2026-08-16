import 'package:flutter_test/flutter_test.dart';
import 'package:bonfire/domain/models/character_class.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/domain/services/stamina_service.dart';
import 'package:bonfire/domain/services/task_economy_service.dart';

void main() {
  group('TaskEconomyService', () {
    test('rewards essence based on category and class multiplier', () {
      final warrior = User.create(id: 'u1', selectedClass: CharacterClass.warrior);
      final prisoner = User.create(id: 'u2', selectedClass: CharacterClass.prisoner);

      expect(TaskEconomyService.rewardFor(TaskCategory.physical, user: warrior), 8); // 8 * 1.0
      expect(TaskEconomyService.rewardFor(TaskCategory.physical, user: prisoner), 12); // 8 * 1.5 = 12
      expect(TaskEconomyService.rewardFor(TaskCategory.mental, user: prisoner), 12); // 8 * 1.5 = 12
      expect(TaskEconomyService.rewardFor(TaskCategory.spiritual, user: prisoner), 8); // 5 * 1.5 = 7.5 -> 8
      expect(TaskEconomyService.rewardFor(TaskCategory.routine, user: prisoner), 5); // 3 * 1.5 = 4.5 -> 5
    });

    test('penalties calculate 1.5x damage when accepted while exhausted with class multiplier', () {
      final warrior = User.create(id: 'u1', selectedClass: CharacterClass.warrior); // 1.0x damage
      final mage = User.create(id: 'u2', selectedClass: CharacterClass.mage); // 0.75x damage
      final prisoner = User.create(id: 'u3', selectedClass: CharacterClass.prisoner); // 1.25x damage

      final normalTask = Task(
        id: 'task-1',
        title: 'Study',
        category: TaskCategory.mental,
        healthDamage: 20,
        createdAt: DateTime.now(),
        acceptedWhileExhausted: false,
      );

      final exhaustedTask = Task(
        id: 'task-2',
        title: 'Late Study',
        category: TaskCategory.mental,
        healthDamage: 20,
        createdAt: DateTime.now(),
        acceptedWhileExhausted: true,
      );

      // Warrior (1.0x): normal = 20 * 1.0 = 20, exhausted = 20 * 1.5 * 1.0 = 30
      expect(TaskEconomyService.penaltyFor(normalTask, user: warrior), 20);
      expect(TaskEconomyService.penaltyFor(exhaustedTask, user: warrior), 30);

      // Mage (0.75x): normal = 20 * 0.75 = 15, exhausted = 20 * 1.5 * 0.75 = 22.5 -> 23
      expect(TaskEconomyService.penaltyFor(normalTask, user: mage), 15);
      expect(TaskEconomyService.penaltyFor(exhaustedTask, user: mage), 23);

      // Prisoner (1.25x): normal = 20 * 1.25 = 25, exhausted = 20 * 1.5 * 1.25 = 37.5 -> 38
      expect(TaskEconomyService.penaltyFor(normalTask, user: prisoner), 25);
      expect(TaskEconomyService.penaltyFor(exhaustedTask, user: prisoner), 38);
    });
  });

  group('Task Model & Date Matching', () {
    test('scheduled tasks appear only on matching weekdays', () {
      final today = DateTime.now();
      final task = Task(
        id: 'task-3',
        title: 'Workout',
        category: TaskCategory.physical,
        description: 'Gym routine',
        createdAt: today,
        scheduledDays: {today.weekday},
      );

      expect(task.matchesDate(today), isTrue);
      expect(task.matchesDate(today.add(const Duration(days: 1))), isFalse);
    });

    test('one-off tasks match creation date', () {
      final today = DateTime.now();
      final task = Task(
        id: 'task-4',
        title: 'Read a Book',
        category: TaskCategory.mental,
        createdAt: today,
      );

      expect(task.matchesDate(today), isTrue);
      expect(task.matchesDate(today.add(const Duration(days: 1))), isFalse);
    });

    test('spending and refunding stamina works correctly with maxStamina cap', () {
      final user = User.create(id: 'u1', selectedClass: CharacterClass.warrior); // maxStamina = 100
      final spent = StaminaService.consumeForTask(user, TaskCategory.physical);
      expect(spent.currentStamina, 65); // 100 - 35 = 65

      final refunded = StaminaService.refundCompletion(spent, TaskCategory.physical);
      expect(refunded.currentStamina, 100);

      // Never exceeds maxStamina
      final overRefund = StaminaService.refundCompletion(user, TaskCategory.physical);
      expect(overRefund.currentStamina, 100);
    });
  });
}
