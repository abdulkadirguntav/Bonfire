/// Data model for Stoic Reflection (Gün Sonu Muhasebesi).
class Reflection {
  const Reflection({
    required this.id,
    required this.date,
    required this.questionsAndAnswers,
  });

  final String id;
  final DateTime date;
  final Map<String, String> questionsAndAnswers;

  static const List<String> defaultQuestions = [
    'Ateş çatırdıyor... Bugün nasıldı?',
    'Bugün seni en çok ne zorladı ve nasıl karşıladın?',
    'Kendini şu an nasıl hissediyorsun?',
  ];

  bool isSameDay(DateTime other) =>
      date.year == other.year &&
      date.month == other.month &&
      date.day == other.day;

  Reflection copyWith({
    String? id,
    DateTime? date,
    Map<String, String>? questionsAndAnswers,
  }) {
    return Reflection(
      id: id ?? this.id,
      date: date ?? this.date,
      questionsAndAnswers: questionsAndAnswers ?? this.questionsAndAnswers,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'questionsAndAnswers': questionsAndAnswers,
      };

  factory Reflection.fromJson(Map<String, dynamic> json) {
    final rawQA = json['questionsAndAnswers'];
    final Map<String, String> qa = {};
    if (rawQA is Map) {
      rawQA.forEach((key, value) {
        qa[key.toString()] = value.toString();
      });
    }

    return Reflection(
      id: json['id'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      questionsAndAnswers: qa,
    );
  }
}
