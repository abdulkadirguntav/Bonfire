import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/data/repositories/soapstone_repository.dart';
import 'package:bonfire/domain/models/soapstone.dart';

final soapstoneRepositoryProvider = Provider<SoapstoneRepository>((ref) {
  throw UnimplementedError('A soapstone repository instance must be provided');
});

final soapstonesProvider =
    NotifierProvider<SoapstoneController, List<Soapstone>>(SoapstoneController.new);

class SoapstoneController extends Notifier<List<Soapstone>> {
  SoapstoneRepository get _repository => ref.read(soapstoneRepositoryProvider);

  @override
  List<Soapstone> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final items = await _repository.loadSoapstones();
    state = items;
  }

  Future<void> addSoapstone(Soapstone soapstone) async {
    final items = [...state, soapstone];
    await _repository.saveSoapstones(items);
    state = items;
  }

  Future<void> updateSoapstone(Soapstone soapstone) async {
    final items = state.map((item) {
      if (item.id == soapstone.id) {
        return soapstone;
      }
      return item;
    }).toList();

    await _repository.saveSoapstones(items);
    state = items;
  }

  Soapstone? forDate(DateTime date) {
    return state.where((item) {
      return item.date.year == date.year &&
          item.date.month == date.month &&
          item.date.day == date.day;
    }).firstOrNull;
  }
}

extension on Iterable<Soapstone> {
  Soapstone? get firstOrNull => isEmpty ? null : first;
}
