import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/data/repositories/reflection_repository.dart';
import 'package:bonfire/domain/models/reflection.dart';
import 'package:bonfire/domain/services/reflection_service.dart';

final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  throw UnimplementedError('A repository instance must be provided');
});

final activeQuestionsProvider =
    NotifierProvider<ActiveQuestionsController, List<String>>(
        ActiveQuestionsController.new);

class ActiveQuestionsController extends Notifier<List<String>> {
  ReflectionRepository get _repository =>
      ref.read(reflectionRepositoryProvider);

  @override
  List<String> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    state = await _repository.loadActiveQuestions();
  }

  Future<void> addQuestion(String question) async {
    final text = question.trim();
    if (text.isEmpty || state.contains(text)) return;
    final updated = [...state, text];
    await _repository.saveActiveQuestions(updated);
    state = updated;
  }

  Future<void> removeQuestion(String question) async {
    final updated = state.where((q) => q != question).toList();
    await _repository.saveActiveQuestions(updated);
    state = updated;
  }

  Future<void> resetToDefaults() async {
    final defaults = List<String>.from(Reflection.defaultQuestions);
    await _repository.saveActiveQuestions(defaults);
    state = defaults;
  }
}

final reflectionControllerProvider =
    NotifierProvider<ReflectionController, List<Reflection>>(
        ReflectionController.new);

class ReflectionController extends Notifier<List<Reflection>> {
  ReflectionRepository get _repository =>
      ref.read(reflectionRepositoryProvider);

  @override
  List<Reflection> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    state = await _repository.loadReflections();
  }

  Future<void> saveReflection({
    required Map<String, String> answers,
    DateTime? date,
    List<String>? questions,
  }) async {
    final updated = ReflectionService.saveReflection(
      state,
      answers: answers,
      now: date,
      questions: questions,
    );
    await _repository.saveReflections(updated);
    state = updated;
  }

  Reflection? getTodayReflection({DateTime? now}) =>
      ReflectionService.getTodayReflection(state, now: now);

  Reflection? getReflectionFor(DateTime date) =>
      ReflectionService.getReflectionForDate(state, date);

  bool hasReflectedToday({DateTime? now}) =>
      ReflectionService.hasReflectedToday(state, now: now);

  Future<void> clearAll() async {
    await _repository.clearReflections();
    state = const [];
  }
}
