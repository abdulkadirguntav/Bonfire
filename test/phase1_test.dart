import 'package:flutter_test/flutter_test.dart';
import 'package:bonfire/core/constants/daily_quotes.dart';
import 'package:bonfire/domain/models/ash_mark.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/domain/services/day_resolution_service.dart';
import 'package:bonfire/domain/services/death_service.dart';
import 'package:bonfire/domain/services/stamina_service.dart';
import 'package:bonfire/domain/services/task_economy_service.dart';

void main() {
  group('1. Felsefi Motivasyon Widget & Sözler', () {
    test('contains required initial quotes', () {
      expect(dailyQuotes.length, greaterThanOrEqualTo(2));
      expect(
        dailyQuotes,
        contains('Dünya senin acılarını umursamıyor. Kalk ve yürü.'),
      );
      expect(
        dailyQuotes,
        contains('Kusursuzluk bir yalan. Sadece dünden daha iyi ol.'),
      );
    });

    test('returns quote for date', () {
      final quote = quoteForDate(DateTime(2026, 8, 16));
      expect(quote.isNotEmpty, isTrue);
      expect(dailyQuotes, contains(quote));
    });
  });

  group('2. Stamina ve Kategori Sistemi', () {
    test('categories have exact Phase 1 stamina costs and essence rewards', () {
      expect(TaskCategory.physical.staminaCost, 40);
      expect(TaskCategory.physical.essenceReward, 40);

      expect(TaskCategory.mental.staminaCost, 30);
      expect(TaskCategory.mental.essenceReward, 30);

      expect(TaskCategory.mindful.staminaCost, 15);
      expect(TaskCategory.mindful.essenceReward, 15);

      expect(TaskCategory.routine.staminaCost, 10);
      expect(TaskCategory.routine.essenceReward, 10);
    });

    test('completing a task spends stamina and rewards essence', () {
      const initialUser = User(
        id: 'u1',
        currentHp: 100,
        maxHp: 100,
        essence: 0,
        currentStreak: 1,
        currentStamina: 100,
      );

      final userAfterPhysical = StaminaService.spendForCompletion(
        initialUser,
        TaskCategory.physical,
      ).copyWith(
        essence: initialUser.essence +
            TaskEconomyService.rewardFor(TaskCategory.physical),
      );

      expect(userAfterPhysical.currentStamina, 60); // 100 - 40
      expect(userAfterPhysical.essence, 40); // 0 + 40
    });

    test('stamina clamps at 0 and does not go negative', () {
      final today = DateTime.now();
      final lowStaminaUser = User(
        id: 'u1',
        currentHp: 100,
        maxHp: 100,
        essence: 0,
        currentStreak: 1,
        currentStamina: 20,
        staminaUpdatedAt: today,
      );

      final user = StaminaService.spendForCompletion(
        lowStaminaUser,
        TaskCategory.physical,
        now: today,
      );

      expect(user.currentStamina, 0);
      expect(StaminaService.isExhausted(user), isTrue);
    });

    test('stamina refreshes to 100 on a new day', () {
      final day1 = DateTime(2026, 8, 16, 22, 0);
      final day2 = DateTime(2026, 8, 17, 8, 0);

      final user = User(
        id: 'u1',
        currentHp: 100,
        maxHp: 100,
        essence: 50,
        currentStreak: 2,
        currentStamina: 15,
        staminaUpdatedAt: day1,
      );

      final refreshed = StaminaService.refreshIfNeeded(user, now: day2);
      expect(refreshed.currentStamina, 100);
    });

    test('over-exertion penalty: missed task accepted while exhausted deals 1.5x damage', () {
      final normalTask = Task(
        id: 't1',
        title: 'Normal Run',
        category: TaskCategory.physical,
        healthDamage: 10,
        createdAt: DateTime.now(),
        acceptedWhileExhausted: false,
      );

      final exhaustedTask = Task(
        id: 't2',
        title: 'Risky Run',
        category: TaskCategory.physical,
        healthDamage: 10,
        createdAt: DateTime.now(),
        acceptedWhileExhausted: true,
      );

      expect(TaskEconomyService.penaltyFor(normalTask), 10);
      expect(TaskEconomyService.penaltyFor(exhaustedTask), 15); // 10 * 1.5 = 15
    });
  });

  group('3. Gün Serisi (Streak), Gün Sonu, Ölüm ve Ash Mark', () {
    test('day resolution increments streak when all due tasks are completed', () {
      final date = DateTime(2026, 8, 16);
      final user = User(
        id: 'u1',
        currentHp: 100,
        maxHp: 100,
        essence: 20,
        currentStreak: 3,
        currentStamina: 50,
      );

      final completedTask = Task(
        id: 't1',
        title: 'Read Book',
        category: TaskCategory.mental,
        createdAt: date,
        completedDateKeys: {Task.dateKey(date)},
      );

      final resolution = DayResolutionService.resolve(
        user,
        [completedTask],
        date: date,
      );

      expect(resolution.missedTasks.isEmpty, isTrue);
      expect(resolution.user.currentStreak, 4); // 3 + 1
      expect(resolution.user.currentHp, 100);
    });

    test('day resolution applies penalty and resets streak to day 1 on missed task', () {
      final date = DateTime(2026, 8, 16);
      final user = User(
        id: 'u1',
        currentHp: 100,
        maxHp: 100,
        essence: 50,
        currentStreak: 5,
        currentStamina: 100,
      );

      final missedTask = Task(
        id: 't1',
        title: 'Exhausted Workout',
        category: TaskCategory.physical,
        healthDamage: 20,
        createdAt: date,
        acceptedWhileExhausted: true,
      );

      final resolution = DayResolutionService.resolve(
        user,
        [missedTask],
        date: date,
      );

      expect(resolution.missedTasks.length, 1);
      expect(resolution.user.currentHp, 70); // 100 - (20 * 1.5 = 30) = 70
      expect(resolution.user.currentStreak, 1); // Streak resets to 1. gün
    });

    test('death creates AshMark, resets essence to 0, resets streak to day 1, and refills HP', () {
      final user = User(
        id: 'u1',
        currentHp: 0,
        maxHp: 100,
        essence: 150,
        currentStreak: 9,
      );

      expect(DeathService.shouldDie(user), isTrue);

      final ashMark = DeathService.createAshMark(user);
      expect(ashMark.lostEssence, 150);
      expect(ashMark.targetStreak, 9);

      final revivedUser = DeathService.applyDeath(user);
      expect(revivedUser.currentHp, 100);
      expect(revivedUser.currentStamina, 100);
      expect(revivedUser.essence, 0);
      expect(revivedUser.currentStreak, 1); // 1. güne döner
    });

    test('reclaiming AshMark: grants lost essence when user reaches target streak', () {
      final ashMark = AshMark(
        id: 'ash-1',
        lostEssence: 150,
        targetStreak: 9,
        createdAt: DateTime.now(),
      );

      const userAtDay5 = User(
        id: 'u1',
        currentHp: 100,
        maxHp: 100,
        essence: 40,
        currentStreak: 5,
      );

      expect(DeathService.canReclaim(userAtDay5, ashMark), isFalse);
      expect(DeathService.reclaim(userAtDay5, ashMark).essence, 40);

      const userAtDay9 = User(
        id: 'u1',
        currentHp: 100,
        maxHp: 100,
        essence: 80,
        currentStreak: 9,
      );

      expect(DeathService.canReclaim(userAtDay9, ashMark), isTrue);
      final reclaimedUser = DeathService.reclaim(userAtDay9, ashMark);
      expect(reclaimedUser.essence, 230); // 80 + 150 = 230
    });
  });
}
