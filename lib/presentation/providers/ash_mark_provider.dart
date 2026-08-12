import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/data/repositories/ash_mark_repository.dart';
import 'package:bonfire/domain/models/ash_mark.dart';

final ashMarkRepositoryProvider = Provider<AshMarkRepository>((ref) {
  throw UnimplementedError('An ash mark repository instance must be provided');
});

final ashMarkControllerProvider =
    NotifierProvider<AshMarkController, AshMark?>(AshMarkController.new);

class AshMarkController extends Notifier<AshMark?> {
  AshMarkRepository get _repository => ref.read(ashMarkRepositoryProvider);

  @override
  AshMark? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final ashMark = await _repository.loadAshMark();
    state = ashMark;
  }

  Future<void> setAshMark(AshMark ashMark) async {
    await _repository.saveAshMark(ashMark);
    state = ashMark;
  }

  Future<void> clearAshMark() async {
    await _repository.clearAshMark();
    state = null;
  }
}
