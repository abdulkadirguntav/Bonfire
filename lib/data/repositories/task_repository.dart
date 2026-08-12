import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:bonfire/domain/models/task.dart';

class TaskRepository {
  TaskRepository(this._prefs);

  static const _storageKey = 'bonfire_tasks';

  final SharedPreferences _prefs;

  Future<List<Task>> loadTasks() async {
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      await clearTasks();
      return const [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final encoded = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await _prefs.setString(_storageKey, encoded);
  }

  Future<void> addTask(Task task) async {
    final tasks = await loadTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }

  Future<void> removeTask(String taskId) async {
    final tasks = await loadTasks();
    tasks.removeWhere((task) => task.id == taskId);
    await saveTasks(tasks);
  }

  Future<void> updateTask(Task task) async {
    final tasks = await loadTasks();
    final index = tasks.indexWhere((item) => item.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
      await saveTasks(tasks);
    }
  }

  Future<void> clearTasks() async {
    await _prefs.remove(_storageKey);
  }
}
