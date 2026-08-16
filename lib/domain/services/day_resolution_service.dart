import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';
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

/// Pure Phase 1 daily rules; persistence and UI stay outside this service.
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
      return total + TaskEconomyService.penaltyFor(task);
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
}
