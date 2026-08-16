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
      final mage = User.create(id: 'u2', selectedClass: CharacterClass.mage);

      expect(TaskEconomyService.rewardFor(TaskCategory.physical, user: warrior), 40); // 40 * 1.0
      expect(TaskEconomyService.rewardFor(TaskCategory.physical, user: mage), 48); // 40 * 1.2
      expect(TaskEconomyService.rewardFor(TaskCategory.mental, user: mage), 36); // 30 * 1.2
      expect(TaskEconomyService.rewardFor(TaskCategory.mindful, user: mage), 18); // 15 * 1.2
      expect(TaskEconomyService.rewardFor(TaskCategory.routine, user: mage), 12); // 10 * 1.2
    });

    test('penalties calculate 1.5x damage when accepted while exhausted with class multiplier', () {
      final warrior = User.create(id: 'u1', selectedClass: CharacterClass.warrior); // 0.8x damage
      final prisoner = User.create(id: 'u2', selectedClass: CharacterClass.prisoner); // 1.5x damage

      final normalTask = Task(
        id: 'task-1',
        title: 'Study',
        category: TaskCategory.mental,
        healthDamage: 10,
        createdAt: DateTime.now(),
        acceptedWhileExhausted: false,
      );

      final exhaustedTask = Task(
        id: 'task-2',
        title: 'Late Study',
        category: TaskCategory.mental,
        healthDamage: 10,
        createdAt: DateTime.now(),
        acceptedWhileExhausted: true,
      );

      // Warrior (0.8x): normal = 10 * 0.8 = 8, exhausted = 10 * 1.5 * 0.8 = 12
      expect(TaskEconomyService.penaltyFor(normalTask, user: warrior), 8);
      expect(TaskEconomyService.penaltyFor(exhaustedTask, user: warrior), 12);

      // Prisoner (1.5x): normal = 10 * 1.5 = 15, exhausted = 10 * 1.5 * 1.5 = 22.5 -> 23
      expect(TaskEconomyService.penaltyFor(normalTask, user: prisoner), 15);
      expect(TaskEconomyService.penaltyFor(exhaustedTask, user: prisoner), 23);
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
        scheduledDays: {today.weekday},
        createdAt: today,
      );

      expect(task.matchesDate(today), isTrue);
      expect(task.matchesDate(today.add(const Duration(days: 1))), isFalse);
    });

    test('one-off tasks match creation date', () {
      final today = DateTime.now();
      final task = Task(
        id: 'task-4',
        title: 'Dentist',
        category: TaskCategory.routine,
        scheduledDays: const {},
        createdAt: today,
      );

      expect(task.matchesDate(today), isTrue);
      expect(task.matchesDate(today.add(const Duration(days: 1))), isFalse);
    });
  });

  group('Stamina Consumption & Refund', () {
    test('spending and refunding stamina works correctly with maxStamina cap', () {
      final mage = User.create(id: 'u1', selectedClass: CharacterClass.mage); // maxStamina = 150

      final mageSpent = StaminaService.spendForCompletion(mage, TaskCategory.mental);
      expect(mageSpent.currentStamina, 120); // 150 - 30

      final mageRefunded = StaminaService.refundCompletion(mageSpent, TaskCategory.mental);
      expect(mageRefunded.currentStamina, 150); // 120 + 30 -> 150
    });
  });
}
