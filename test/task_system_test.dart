import 'package:flutter_test/flutter_test.dart';
import 'package:bonfire/domain/models/character_class.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/domain/services/task_economy_service.dart';

void main() {
  group('TaskEconomyService', () {
    test('rewards essence using the class multiplier', () {
      const user = User(
        id: 'u1',
        selectedClass: CharacterClass.mage,
        currentHp: 120,
        maxHp: 120,
        totalEssence: 0,
        currentStreak: 0,
      );

      final reward = TaskEconomyService.calculateReward(user, 10);
      expect(reward, 13);
    });

    test('boss reward is tripled', () {
      const user = User(
        id: 'u1',
        selectedClass: CharacterClass.mage,
        currentHp: 120,
        maxHp: 120,
        totalEssence: 0,
        currentStreak: 0,
      );

      final reward = TaskEconomyService.calculateBossReward(user, 10);
      expect(reward, 38);
    });

    test('penalties use class damage multiplier', () {
      const user = User(
        id: 'u1',
        selectedClass: CharacterClass.prisoner,
        currentHp: 80,
        maxHp: 80,
        totalEssence: 0,
        currentStreak: 0,
      );

      final penalty = TaskEconomyService.calculatePenalty(user, 10);
      expect(penalty, 11); // 10 * 1.1 = 11.0
    });

    test('toggling a task off removes the essence reward', () {
      const user = User(
        id: 'u1',
        selectedClass: CharacterClass.mage,
        currentHp: 120,
        maxHp: 120,
        totalEssence: 0,
        currentStreak: 0,
      );

      final task = Task(
        id: 'task-1',
        title: 'Study',
        description: 'Read 20 pages',
        isBoss: false,
        isCompleted: true,
        rewardValue: 10,
        scheduledDays: {DateTime.monday},
        createdAt: DateTime.now(),
      );

      expect(TaskEconomyService.calculateCompletionDelta(user, task, isCompleted: false), -13);
    });
  });

  group('Task', () {
    test('boss task detection works', () {
      final task = Task(
        id: 'task-1',
        title: 'Boss Task',
        description: 'Defeat a boss',
        isBoss: true,
        isCompleted: false,
        rewardValue: 10,
        scheduledDays: const {},
        createdAt: DateTime.now(),
      );

      expect(task.isBoss, isTrue);
      expect(task.title, 'Boss Task');
    });

    test('scheduled tasks appear only on selected weekdays', () {
      final today = DateTime.now();
      final task = Task(
        id: 'task-2',
        title: 'Workout',
        description: 'Gym routine',
        isBoss: false,
        isCompleted: false,
        rewardValue: 10,
        scheduledDays: {today.weekday},
        createdAt: today,
      );

      expect(task.matchesDate(today), isTrue);
      expect(task.matchesDate(today.add(const Duration(days: 1))), isFalse);
    });
  });
}
