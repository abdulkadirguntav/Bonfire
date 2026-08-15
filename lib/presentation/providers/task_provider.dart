import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/data/repositories/task_repository.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/services/stamina_service.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  throw UnimplementedError('A repository instance must be provided');
});

final tasksProvider =
    NotifierProvider<TaskController, List<Task>>(TaskController.new);

class TaskController extends Notifier<List<Task>> {
  TaskRepository get _repository => ref.read(taskRepositoryProvider);

  @override
  List<Task> build() {
    _loadTasks();
    return const [];
  }

  Future<void> _loadTasks() async {
    final tasks = await _repository.loadTasks();
    state = tasks;
  }

  Future<void> addTask(Task task,
      {required bool acceptedExhaustionWarning}) async {
    final user = ref.read(userControllerProvider);
    if (user == null) {
      throw StateError('Görev eklemek için bir karakter seçmelisin.');
    }
    final exhausted = StaminaService.isExhausted(user);
    if (exhausted && !acceptedExhaustionWarning) {
      throw StateError(
          'Stamina tükendi. Bu yemini eklemek için riski onaylamalısın.');
    }
    final tasks = [...state, task.copyWith(acceptedWhileExhausted: exhausted)];
    await _repository.saveTasks(tasks);
    state = tasks;
    if (exhausted) {
      final updatedUser = user.copyWith(
        totalEssence: user.totalEssence + task.category.essenceReward,
      );
      await ref.read(userControllerProvider.notifier).saveUser(updatedUser);
    }
  }

  Future<void> removeTask(String taskId) async {
    final tasks = state.where((task) => task.id != taskId).toList();
    await _repository.saveTasks(tasks);
    state = tasks;
  }

  Future<void> toggleComplete(String taskId,
      {required bool isCompleted, DateTime? date}) async {
    final user = ref.read(userControllerProvider);
    if (user == null) return;
    final now = date ?? DateTime.now();
    Task? task;
    for (final item in state) {
      if (item.id == taskId) {
        task = item;
        break;
      }
    }
    final previouslyCompleted = task?.isCompletedOn(now) ?? false;
    if (task == null || previouslyCompleted == isCompleted) return;
    final tasks = state
        .map((item) => item.id == taskId
            ? item.copyWith(
                completedOn: isCompleted ? now : null,
                clearCompletedOn: !isCompleted)
            : item)
        .toList();

    await _repository.saveTasks(tasks);
    state = tasks;
    final updatedUser = isCompleted
        ? StaminaService.spendForCompletion(user, task.category, now: now)
            .copyWith(
            totalEssence: user.totalEssence + task.category.essenceReward,
          )
        : user.copyWith(
            currentStamina:
                (user.currentStamina + task.category.staminaCost)
                    .clamp(0, StaminaService.maxStaminaFor(user))
                    .toInt(),
            totalEssence: (user.totalEssence - task.category.essenceReward)
                .clamp(0, 1 << 31)
                .toInt(),
          );
    await ref.read(userControllerProvider.notifier).saveUser(updatedUser);
  }

  List<Task> tasksForToday() {
    final now = DateTime.now();
    return state.where((task) => task.matchesDate(now)).toList();
  }
}
