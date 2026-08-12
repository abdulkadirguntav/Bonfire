import 'package:bonfire/domain/models/soapstone.dart';
import 'package:bonfire/domain/models/user.dart';

class SoapstoneService {
  const SoapstoneService();

  static bool isUnlocked(User user) => user.hasDefeatedFirstBoss;

  static bool canCreateToday(List<Soapstone> soapstones, DateTime today) {
    if (soapstones.isEmpty) {
      return true;
    }

    return !soapstones.any((stone) {
      final sameDay = stone.date.year == today.year &&
          stone.date.month == today.month &&
          stone.date.day == today.day;
      return sameDay;
    });
  }

  static bool canEditToday(Soapstone soapstone, DateTime today) {
    if (soapstone.isEdited) {
      return false;
    }

    final sameDay = soapstone.date.year == today.year &&
        soapstone.date.month == today.month &&
        soapstone.date.day == today.day;

    return sameDay;
  }

  static Soapstone createSoapstone({
    required String message,
    required DateTime date,
    String? id,
  }) {
    return Soapstone(
      id: id ?? 'soapstone_${date.year}_${date.month}_${date.day}',
      date: date,
      message: message,
      isEdited: false,
    );
  }
}
