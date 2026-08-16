import 'package:bonfire/domain/models/soapstone.dart';

class SoapstoneAlreadyPostedTodayException implements Exception {
  const SoapstoneAlreadyPostedTodayException();

  @override
  String toString() =>
      'Bugün zaten bir Soapstone mesajı bıraktınız. Günde sadece 1 kez mesaj yazılabilir.';
}

class SoapstoneAlreadyEditedException implements Exception {
  const SoapstoneAlreadyEditedException();

  @override
  String toString() =>
      'Bu mesajı zaten 1 kez düzenlediniz. Günde sadece 1 kez düzenleme hakkınız vardır.';
}

class SoapstoneService {
  const SoapstoneService._();

  static Soapstone? getTodaySoapstone(
    List<Soapstone> soapstones, {
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    return soapstones.where((s) => s.isSameDay(today)).firstOrNull;
  }

  static bool canPostToday(
    List<Soapstone> soapstones, {
    DateTime? now,
  }) {
    return getTodaySoapstone(soapstones, now: now) == null;
  }

  static bool canEditToday(
    List<Soapstone> soapstones, {
    DateTime? now,
  }) {
    final todaySoapstone = getTodaySoapstone(soapstones, now: now);
    return todaySoapstone != null && !todaySoapstone.isEdited;
  }

  static List<Soapstone> postMessage(
    List<Soapstone> currentList,
    String message, {
    DateTime? now,
    String? id,
  }) {
    final today = now ?? DateTime.now();
    if (!canPostToday(currentList, now: today)) {
      throw const SoapstoneAlreadyPostedTodayException();
    }

    final newSoapstone = Soapstone(
      id: id ?? 'soap_${today.millisecondsSinceEpoch}',
      date: today,
      message: message.trim(),
      isEdited: false,
    );

    return [newSoapstone, ...currentList];
  }

  static List<Soapstone> editMessage(
    List<Soapstone> currentList,
    String soapstoneId,
    String newMessage, {
    DateTime? now,
  }) {
    final target = currentList.where((s) => s.id == soapstoneId).firstOrNull;
    if (target == null || target.isEdited) {
      throw const SoapstoneAlreadyEditedException();
    }

    return currentList.map((s) {
      if (s.id == soapstoneId) {
        return s.copyWith(
          message: newMessage.trim(),
          isEdited: true,
        );
      }
      return s;
    }).toList();
  }
}
