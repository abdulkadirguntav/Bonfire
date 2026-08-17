import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/core/services/notification_service.dart';
import 'package:bonfire/data/repositories/task_repository.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/services/day_resolution_service.dart';
import 'package:bonfire/domain/services/stamina_service.dart';
import 'package:bonfire/domain/services/task_economy_service.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  throw UnimplementedError('A repository instance must be provided');
});

final tasksProvider =
    NotifierProvider<TaskController, List<Task>>(TaskController.new);

class ExhaustionWarningRequired implements Exception {
  const ExhaustionWarningRequired();

  @override
  String toString() =>
      'Stamina tükendi. Bu görevi kabul etmek için aşırı efor riskini onaylamalısın.';
}

class TaskController extends Notifier<List<Task>> {
  TaskRepository get _repository => ref.read(taskRepositoryProvider);

  @override
  List<Task> build() {
    _loadTasks();
    return const [];
  }

  Future<void> _loadTasks() async {
    state = await _repository.loadTasks();
    await _rescheduleNotifications();
    await checkAndResolvePastDays();
  }

  Future<void> _rescheduleNotifications() async {
    for (final task in state) {
      if (task.habitTime != null && task.habitTime!.contains(':')) {
        final parts = task.habitTime!.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour != null && minute != null) {
            await NotificationService.instance.scheduleHabitNotification(
              id: task.id.hashCode & 0x7FFFFFFF,
              taskTitle: task.title,
              hour: hour,
              minute: minute,
            );
          }
        }
      }
    }
  }

  /// Automatically catches up on all past un-resolved days on load.
  Future<void> checkAndResolvePastDays({DateTime? now}) async {
    final user = ref.read(userControllerProvider);
    if (user == null) return;
    final today = now ?? DateTime.now();

    final updatedUser = DayResolutionService.resolvePastDays(
      user: user,
      tasks: state,
      today: today,
    );

    if (updatedUser != user) {
      await ref.read(userControllerProvider.notifier).saveUser(updatedUser);
      await ref
          .read(userControllerProvider.notifier)
          .reclaimAshMarkIfEligible();
    }
  }

  /// A task accepted at zero stamina carries the 1.5x missed-task penalty.
  Future<void> addTask(
    Task task, {
    bool acceptedExhaustionWarning = false,
    DateTime? now,
  }) async {
    final user = ref.read(userControllerProvider);
    if (user == null) {
      throw StateError('Görev eklemek için önce yolculuğa başlamalısın.');
    }

    final exhausted = StaminaService.isExhausted(user, now: now);
    if (exhausted && !acceptedExhaustionWarning) {
      throw const ExhaustionWarningRequired();
    }

    final tasks = [
      ...state,
      task.copyWith(acceptedWhileExhausted: exhausted),
    ];
    await _repository.saveTasks(tasks);
    state = tasks;

    // Schedule local daily reminder if habitTime is specified
    if (task.habitTime != null && task.habitTime!.contains(':')) {
      final parts = task.habitTime!.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          await NotificationService.instance.scheduleHabitNotification(
            id: task.id.hashCode & 0x7FFFFFFF,
            taskTitle: task.title,
            hour: hour,
            minute: minute,
          );
        }
      }
    }
  }

  /// Strict mathematical rule on task deletion:
  /// - If task was NOT completed: Stamina is untouched.
  /// - If task WAS completed: Stamina and Essence are refunded, capped at maxStamina.
  Future<void> deleteTask(String taskId, {DateTime? date}) async {
    final user = ref.read(userControllerProvider);
    final targetDate = date ?? DateTime.now();
    final task = state.where((item) => item.id == taskId).firstOrNull;
    if (task == null) return;

    final isCompleted = task.isCompletedOn(targetDate);
    final remainingTasks = state.where((item) => item.id != taskId).toList();
    await _repository.saveTasks(remainingTasks);
    state = remainingTasks;

    // Cancel scheduled notification
    await NotificationService.instance
        .cancelHabitNotification(task.id.hashCode & 0x7FFFFFFF);

    if (user != null && isCompleted) {
      final reward = TaskEconomyService.rewardFor(task.category, user: user);
      final refundedUser = StaminaService.refundCompletion(
        user,
        task.category,
        now: targetDate,
      ).copyWith(
        essence: (user.essence - reward).clamp(0, 1 << 31).toInt(),
        enemiesDefeated: (user.enemiesDefeated - 1).clamp(0, 1 << 31).toInt(),
      );
      await ref.read(userControllerProvider.notifier).saveUser(refundedUser);
    }
  }

  /// Alias for deleteTask for backwards compatibility.
  Future<void> removeTask(String taskId, {DateTime? date}) =>
      deleteTask(taskId, date: date);

  /// Strict mathematical rule on toggle:
  /// - When completed: Stamina is deducted (stays at 0 if cost exceeds stamina, never negative). Essence awarded.
  /// - When unchecked: Stamina is refunded (capped at maxStamina). Essence deducted.
  Future<void> toggleComplete(
    String taskId, {
    required bool isCompleted,
    DateTime? date,
  }) async {
    final user = ref.read(userControllerProvider);
    if (user == null) return;

    final completionDate = date ?? DateTime.now();
    final task = state.where((item) => item.id == taskId).firstOrNull;
    if (task == null || task.isCompletedOn(completionDate) == isCompleted) {
      return;
    }

    final completionKey = Task.dateKey(completionDate);
    final completedKeys = {...task.completedDateKeys};
    if (isCompleted) {
      completedKeys.add(completionKey);
    } else {
      completedKeys.remove(completionKey);
    }

    final updatedTask = task.copyWith(completedDateKeys: completedKeys);
    final updatedTasks =
        state.map((item) => item.id == taskId ? updatedTask : item).toList();
    await _repository.saveTasks(updatedTasks);
    state = updatedTasks;

    if (isCompleted) {
      final reward = TaskEconomyService.rewardFor(task.category, user: user);
      final updatedUser = StaminaService.consumeForTask(
        user,
        task.category,
        now: completionDate,
      ).copyWith(
        essence: user.essence + reward,
        enemiesDefeated: user.enemiesDefeated + 1,
      );
      await ref.read(userControllerProvider.notifier).saveUser(updatedUser);
    } else {
      final reward = TaskEconomyService.rewardFor(task.category, user: user);
      final refundedUser = StaminaService.refundCompletion(
        user,
        task.category,
        now: completionDate,
      ).copyWith(
        essence: (user.essence - reward).clamp(0, 1 << 31).toInt(),
        enemiesDefeated: (user.enemiesDefeated - 1).clamp(0, 1 << 31).toInt(),
      );
      await ref.read(userControllerProvider.notifier).saveUser(refundedUser);
    }
  }
}
