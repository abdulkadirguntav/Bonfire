import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/data/repositories/reflection_repository.dart';
import 'package:bonfire/domain/models/reflection.dart';
import 'package:bonfire/domain/services/reflection_service.dart';

final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  throw UnimplementedError('A repository instance must be provided');
});

final customQuestionsProvider =
    NotifierProvider<CustomQuestionsController, List<String>>(
        CustomQuestionsController.new);

class CustomQuestionsController extends Notifier<List<String>> {
  ReflectionRepository get _repository => ref.read(reflectionRepositoryProvider);

  @override
  List<String> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    state = await _repository.loadCustomQuestions();
  }

  Future<void> addQuestion(String question) async {
    final text = question.trim();
    if (text.isEmpty || state.contains(text)) return;
    final updated = [...state, text];
    await _repository.saveCustomQuestions(updated);
    state = updated;
  }

  Future<void> removeQuestion(String question) async {
    final updated = state.where((q) => q != question).toList();
    await _repository.saveCustomQuestions(updated);
    state = updated;
  }
}

final reflectionControllerProvider =
    NotifierProvider<ReflectionController, List<Reflection>>(
        ReflectionController.new);

class ReflectionController extends Notifier<List<Reflection>> {
  ReflectionRepository get _repository => ref.read(reflectionRepositoryProvider);

  @override
  List<Reflection> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    state = await _repository.loadReflections();
  }

  Future<void> saveReflection({
    required DateTime date,
    required Map<String, String> answers,
  }) async {
    final newEntry = ReflectionService.createReflection(
      date: date,
      answers: answers,
    );

    // Replace if an entry for today already existed or prepend
    final filtered = state.where((r) => !r.isSameDay(date)).toList();
    final updated = [newEntry, ...filtered];
    await _repository.saveReflections(updated);
    state = updated;
  }

  Reflection? getReflectionFor(DateTime date) {
    return state.where((r) => r.isSameDay(date)).firstOrNull;
  }
}
