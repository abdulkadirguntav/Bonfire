import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/domain/services/death_service.dart';
import 'package:bonfire/domain/services/task_economy_service.dart';

class DayResolution {
  const DayResolution({
    required this.user,
    required this.missedTasks,
    required this.hadDueTasks,
  });

  final User user;
  final List<Task> missedTasks;
  final bool hadDueTasks;
}

/// Pure daily rules for Bonfire habit resolutions and streak progression.
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
    final damage = missedTasks.fold<int>(0, (total, task) {
      return total + TaskEconomyService.penaltyFor(task, user: user);
    });
    final allCompleted = dueTasks.isNotEmpty && missedTasks.isEmpty;

    return DayResolution(
      missedTasks: missedTasks,
      hadDueTasks: dueTasks.isNotEmpty,
      user: user.copyWith(
        currentHp: user.currentHp - damage,
        currentStreak: dueTasks.isEmpty
            ? user.currentStreak
            : allCompleted
                ? user.currentStreak + 1
                : 1,
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
