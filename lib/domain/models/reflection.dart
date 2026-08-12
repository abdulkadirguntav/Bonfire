class Reflection {
  const Reflection({
    required this.id,
    required this.date,
    required this.questionsAndAnswers,
  });

  final String id;
  final DateTime date;
  final Map<String, String> questionsAndAnswers;

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
    return Reflection(
      id: json['id'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      questionsAndAnswers: Map<String, String>.from(
        (json['questionsAndAnswers'] as Map? ?? {})
            .map((key, value) => MapEntry(key.toString(), value.toString())),
      ),
    );
  }
}
