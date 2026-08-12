import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/data/repositories/reflection_repository.dart';
import 'package:bonfire/domain/models/reflection.dart';

final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  throw UnimplementedError('A reflection repository instance must be provided');
});

final reflectionsProvider =
    NotifierProvider<ReflectionController, List<Reflection>>(ReflectionController.new);

class ReflectionController extends Notifier<List<Reflection>> {
  ReflectionRepository get _repository => ref.read(reflectionRepositoryProvider);

  @override
  List<Reflection> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final reflections = await _repository.loadReflections();
    state = reflections;
  }

  Future<void> saveReflection(Reflection reflection) async {
    final existing = state.where((item) => item.id != reflection.id).toList();
    final merged = [...existing, reflection];
    await _repository.saveReflections(merged);
    state = merged;
  }

  Reflection? forDate(DateTime date) {
    return state.where((item) {
      return item.date.year == date.year &&
          item.date.month == date.month &&
          item.date.day == date.day;
    }).firstOrNull;
  }
}

extension on Iterable<Reflection> {
  Reflection? get firstOrNull => isEmpty ? null : first;
}
