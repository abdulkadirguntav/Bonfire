/// Data model for Soapstone (Not Bırakma) signs.
class Soapstone {
  const Soapstone({
    required this.id,
    required this.date,
    required this.message,
    this.isEdited = false,
  });

  final String id;
  final DateTime date;
  final String message;
  final bool isEdited;

  bool isSameDay(DateTime other) =>
      date.year == other.year &&
      date.month == other.month &&
      date.day == other.day;

  Soapstone copyWith({
    String? id,
    DateTime? date,
    String? message,
    bool? isEdited,
  }) {
    return Soapstone(
      id: id ?? this.id,
      date: date ?? this.date,
      message: message ?? this.message,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'message': message,
        'isEdited': isEdited,
      };

  factory Soapstone.fromJson(Map<String, dynamic> json) {
    return Soapstone(
      id: json['id'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      message: json['message'] as String? ?? '',
      isEdited: json['isEdited'] as bool? ?? false,
    );
  }
}
