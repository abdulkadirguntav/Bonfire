import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';

class StaminaService {
  const StaminaService._();

  static int maxStaminaFor(User user) => user.selectedClass.maxStamina;

  static User refreshIfNeeded(User user, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    if (_isSameDay(user.staminaUpdatedAt, currentTime)) {
      return user;
    }
    final maxStam = maxStaminaFor(user);

    return user.copyWith(
      currentStamina: maxStam,
      staminaUpdatedAt: currentTime,
    );
  }

  static User spendForCompletion(User user, TaskCategory category,
      {DateTime? now}) {
    final refreshedUser = refreshIfNeeded(user, now: now);
    final maxStam = maxStaminaFor(refreshedUser);
    return refreshedUser.copyWith(
      currentStamina: (refreshedUser.currentStamina - category.staminaCost)
          .clamp(0, maxStam)
          .toInt(),
      staminaUpdatedAt: now ?? DateTime.now(),
    );
  }

  static bool isExhausted(User user, {DateTime? now}) =>
      refreshIfNeeded(user, now: now).currentStamina == 0;

  static bool _isSameDay(DateTime? first, DateTime second) {
    if (first == null) {
      return false;
    }

    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
