import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';

/// Phase 2 stamina rules. Stamina capacity is defined by user.maxStamina
/// and resets on the first read after local midnight.
class StaminaService {
  const StaminaService._();

  static User refreshIfNeeded(User user, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    if (_isSameCalendarDay(user.staminaUpdatedAt, currentTime)) return user;

    return user.copyWith(
      currentStamina: user.maxStamina,
      staminaUpdatedAt: currentTime,
    );
  }

  /// Deducts stamina when a task is completed.
  /// If stamina would fall below 0, it stays capped at exactly 0.
  static User spendForCompletion(
    User user,
    TaskCategory category, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final refreshed = refreshIfNeeded(user, now: currentTime);
    final nextStamina = (refreshed.currentStamina - category.staminaCost)
        .clamp(0, user.maxStamina);

    return refreshed.copyWith(
      currentStamina: nextStamina,
      staminaUpdatedAt: currentTime,
    );
  }

  static User consumeForTask(
    User user,
    TaskCategory category, {
    DateTime? now,
  }) =>
      spendForCompletion(user, category, now: now);

  /// Refunds stamina when a task completion is undone or a completed task is deleted.
  /// The resulting stamina never exceeds user.maxStamina.
  static User refundCompletion(
    User user,
    TaskCategory category, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final refreshed = refreshIfNeeded(user, now: currentTime);
    final nextStamina = (refreshed.currentStamina + category.staminaCost)
        .clamp(0, user.maxStamina);

    return refreshed.copyWith(
      currentStamina: nextStamina,
      staminaUpdatedAt: currentTime,
    );
  }

  static bool isExhausted(User user, {DateTime? now}) =>
      refreshIfNeeded(user, now: now).currentStamina == 0;

  static bool _isSameCalendarDay(DateTime? first, DateTime second) {
    return first != null &&
        first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
