import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  }

  Future<void> removeTask(String taskId) async {
    final tasks = state.where((task) => task.id != taskId).toList();
    await _repository.saveTasks(tasks);
    state = tasks;
  }

  /// Applies stamina cost and Essence only when the task becomes completed.
  Future<void> toggleComplete(
    String taskId, {
    required bool isCompleted,
    DateTime? date,
  }) async {
    final user = ref.read(userControllerProvider);
    if (user == null) return;

    final completionDate = date ?? DateTime.now();
    final task = state.where((item) => item.id == taskId).firstOrNull;
    if (task == null || task.isCompletedOn(completionDate) == isCompleted) return;

    final completionKey = Task.dateKey(completionDate);
    final completedKeys = {...task.completedDateKeys};
    if (isCompleted) {
      completedKeys.add(completionKey);
    } else {
      completedKeys.remove(completionKey);
    }

    final tasks = state
        .map((item) => item.id == taskId
            ? item.copyWith(completedDateKeys: completedKeys)
            : item)
        .toList();
    await _repository.saveTasks(tasks);
    state = tasks;

    final reward = TaskEconomyService.rewardFor(task.category);
    final updatedUser = isCompleted
        ? StaminaService.spendForCompletion(user, task.category, now: completionDate)
            .copyWith(essence: user.essence + reward)
        : StaminaService.refundCompletion(user, task.category).copyWith(
            essence: (user.essence - reward).clamp(0, 1 << 31).toInt(),
          );
    await ref.read(userControllerProvider.notifier).saveUser(updatedUser);
  }

  /// Call once at the end of [date]. It is idempotent through
  /// `lastDailyResolutionAt`, so it is safe to invoke at app start too.
  Future<void> resolveDay(DateTime date) async {
    final user = ref.read(userControllerProvider);
    if (user == null || DayResolutionService.wasResolvedFor(user, date)) return;

    final resolution = DayResolutionService.resolve(user, state, date: date);
    await ref.read(userControllerProvider.notifier).saveUser(resolution.user);
    await ref.read(userControllerProvider.notifier).resolveDeathIfNeeded(now: date);
    await ref.read(userControllerProvider.notifier).reclaimAshMarkIfEligible();
  }

  List<Task> tasksForToday() =>
      state.where((task) => task.matchesDate(DateTime.now())).toList();
}
