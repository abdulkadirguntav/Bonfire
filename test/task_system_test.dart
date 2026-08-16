import 'package:flutter_test/flutter_test.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/domain/services/stamina_service.dart';
import 'package:bonfire/domain/services/task_economy_service.dart';

void main() {
  group('TaskEconomyService', () {
    test('rewards essence based on category', () {
      expect(TaskEconomyService.rewardFor(TaskCategory.physical), 40);
      expect(TaskEconomyService.rewardFor(TaskCategory.mental), 30);
      expect(TaskEconomyService.rewardFor(TaskCategory.mindful), 15);
      expect(TaskEconomyService.rewardFor(TaskCategory.routine), 10);
    });

    test('penalties calculate 1.5x damage when accepted while exhausted', () {
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

      expect(TaskEconomyService.penaltyFor(normalTask), 10);
      expect(TaskEconomyService.penaltyFor(exhaustedTask), 15);
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
    test('spending and refunding stamina works correctly', () {
      const user = User(
        id: 'u1',
        currentHp: 100,
        maxHp: 100,
        essence: 0,
        currentStreak: 1,
        currentStamina: 100,
      );

      final userSpent = StaminaService.spendForCompletion(user, TaskCategory.mental);
      expect(userSpent.currentStamina, 70); // 100 - 30

      final userRefunded = StaminaService.refundCompletion(userSpent, TaskCategory.mental);
      expect(userRefunded.currentStamina, 100);
    });
  });
}
