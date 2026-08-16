import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/data/repositories/soapstone_repository.dart';
import 'package:bonfire/domain/models/soapstone.dart';
import 'package:bonfire/domain/services/soapstone_service.dart';

final soapstoneRepositoryProvider = Provider<SoapstoneRepository>((ref) {
  throw UnimplementedError('A repository instance must be provided');
});

/// Soapstone is now accessible from Day 1.
final isSoapstoneUnlockedProvider = Provider<bool>((ref) {
  return true;
});

final soapstoneControllerProvider =
    NotifierProvider<SoapstoneController, List<Soapstone>>(
        SoapstoneController.new);

class SoapstoneController extends Notifier<List<Soapstone>> {
  SoapstoneRepository get _repository => ref.read(soapstoneRepositoryProvider);

  @override
  List<Soapstone> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    state = await _repository.loadSoapstones();
  }

  Future<void> postMessage(String message, {DateTime? now}) async {
    final updated = SoapstoneService.postMessage(state, message, now: now);
    await _repository.saveSoapstones(updated);
    state = updated;
  }

  Future<void> editMessage(
    String soapstoneId,
    String newMessage, {
    DateTime? now,
  }) async {
    final updated = SoapstoneService.editMessage(
      state,
      soapstoneId,
      newMessage,
      now: now,
    );
    await _repository.saveSoapstones(updated);
    state = updated;
  }

  Soapstone? getTodaySoapstone({DateTime? now}) =>
      SoapstoneService.getTodaySoapstone(state, now: now);

  bool canPostToday({DateTime? now}) =>
      SoapstoneService.canPostToday(state, now: now);

  bool canEditToday({DateTime? now}) =>
      SoapstoneService.canEditToday(state, now: now);

  Future<void> clearAll() async {
    await _repository.clearSoapstones();
    state = const [];
  }
}
