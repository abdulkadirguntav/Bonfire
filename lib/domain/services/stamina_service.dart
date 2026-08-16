import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';

/// Phase 1 stamina rules. Stamina always has a capacity of 100 and resets on
/// the first read after local midnight.
class StaminaService {
  const StaminaService._();

  static User refreshIfNeeded(User user, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    if (_isSameCalendarDay(user.staminaUpdatedAt, currentTime)) return user;

    return user.copyWith(
      currentStamina: User.maxStamina,
      staminaUpdatedAt: currentTime,
    );
  }

  static User spendForCompletion(
    User user,
    TaskCategory category, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final refreshed = refreshIfNeeded(user, now: currentTime);
    return refreshed.copyWith(
      currentStamina:
          (refreshed.currentStamina - category.staminaCost).clamp(0, 100).toInt(),
      staminaUpdatedAt: currentTime,
    );
  }

  static User refundCompletion(User user, TaskCategory category) => user.copyWith(
        currentStamina:
            (user.currentStamina + category.staminaCost).clamp(0, 100).toInt(),
      );

  static bool isExhausted(User user, {DateTime? now}) =>
      refreshIfNeeded(user, now: now).currentStamina == 0;

  static bool _isSameCalendarDay(DateTime? first, DateTime second) {
    return first != null &&
        first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
