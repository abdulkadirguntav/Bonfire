import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/data/repositories/task_repository.dart';
import 'package:bonfire/domain/models/task.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  throw UnimplementedError('A repository instance must be provided');
});

final tasksProvider = NotifierProvider<TaskController, List<Task>>(TaskController.new);

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

  Future<void> addTask(Task task) async {
    final hasBossTask = state.any((item) {
      if (!item.isBoss || !task.isBoss) {
        return false;
      }

      final overlap = item.scheduledDays.intersection(task.scheduledDays);
      return overlap.isNotEmpty ||
          (item.scheduledDays.isEmpty && task.scheduledDays.isEmpty &&
              item.createdAt.year == task.createdAt.year &&
              item.createdAt.month == task.createdAt.month &&
              item.createdAt.day == task.createdAt.day);
    });

    if (task.isBoss && hasBossTask) {
      throw Exception('Bir günde sadece bir boss görevi olabilir.');
    }

    final tasks = [...state, task];
    await _repository.saveTasks(tasks);
    state = tasks;
  }

  Future<void> removeTask(String taskId) async {
    final tasks = state.where((task) => task.id != taskId).toList();
    await _repository.saveTasks(tasks);
    state = tasks;
  }

  Future<void> toggleComplete(String taskId, {required bool isCompleted}) async {
    final tasks = state.map((task) {
      if (task.id == taskId) {
        return task.copyWith(isCompleted: isCompleted);
      }
      return task;
    }).toList();

    await _repository.saveTasks(tasks);
    state = tasks;
  }

  List<Task> tasksForToday() {
    final now = DateTime.now();
    return state.where((task) => task.matchesDate(now)).toList();
  }
}
