import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/domain/services/death_service.dart';
import 'package:bonfire/domain/services/task_economy_service.dart';

class DayResolution {
  const DayResolution({
    required this.user,
    required this.missedTasks,
    required this.hadDueTasks,
    this.wasStasisApplied = false,
    this.purgedTaskCount = 0,
  });

  final User user;
  final List<Task> missedTasks;
  final bool hadDueTasks;
  final bool wasStasisApplied;
  final int purgedTaskCount;
}

/// Pure daily rules for Bonfire habit resolutions, Purging Stone, and Scroll of Stasis.
class DayResolutionService {
  const DayResolutionService._();

  static DayResolution resolve(
    User user,
    List<Task> tasks, {
    required DateTime date,
  }) {
    final dueTasks = tasks.where((task) => task.matchesDate(date)).toList();
    final missedTasks =
        dueTasks.where((task) => !task.isCompletedOn(date)).toList();

    // 1. Scroll of Stasis check: Freezes day (0 damage, streak untouched)
    if (user.isStasisActiveOn(date)) {
      return DayResolution(
        missedTasks: missedTasks,
        hadDueTasks: dueTasks.isNotEmpty,
        wasStasisApplied: true,
        purgedTaskCount: 0,
        user: user.copyWith(
          lastDailyResolutionAt: date,
        ),
      );
    }

    // 2. Purging Stone protection: blocks HP penalty damage for up to activePurgingStones tasks
    final protectedCount =
        user.activePurgingStones.clamp(0, missedTasks.length);
    final unprotectedMissed = missedTasks.skip(protectedCount).toList();

    final damage = unprotectedMissed.fold<int>(0, (total, task) {
      return total + TaskEconomyService.penaltyFor(task, user: user);
    });

    final allCompleted = dueTasks.isNotEmpty && missedTasks.isEmpty;

    return DayResolution(
      missedTasks: missedTasks,
      hadDueTasks: dueTasks.isNotEmpty,
      wasStasisApplied: false,
      purgedTaskCount: protectedCount,
      user: user.copyWith(
        currentHp: user.currentHp - damage,
        currentStreak: dueTasks.isEmpty
            ? user.currentStreak
            : allCompleted
                ? user.currentStreak + 1
                : 1,
        activePurgingStones: 0, // Reset active stones after day resolution
        lastDailyResolutionAt: date,
      ),
    );
  }

  static bool wasResolvedFor(User user, DateTime date) {
    final resolved = user.lastDailyResolutionAt;
    return resolved != null &&
        resolved.year == date.year &&
        resolved.month == date.month &&
        resolved.day == date.day;
  }

  /// Automatically catches up all past un-resolved days up to yesterday.
  static User resolvePastDays({
    required User user,
    required List<Task> tasks,
    required DateTime today,
  }) {
    var currentUser = user;
    final lastResolved = currentUser.lastDailyResolutionAt ??
        currentUser.staminaUpdatedAt ??
        today.subtract(const Duration(days: 1));

    final lastDate =
        DateTime(lastResolved.year, lastResolved.month, lastResolved.day);
    final todayDate = DateTime(today.year, today.month, today.day);

    var checkDate = lastDate;
    while (checkDate.isBefore(todayDate)) {
      if (!wasResolvedFor(currentUser, checkDate)) {
        final resolution = resolve(currentUser, tasks, date: checkDate);
        currentUser = resolution.user;
        if (DeathService.shouldDie(currentUser)) {
          currentUser = DeathService.applyDeath(currentUser, now: checkDate);
        }
      }
      checkDate = checkDate.add(const Duration(days: 1));
    }
    return currentUser;
  }
}
