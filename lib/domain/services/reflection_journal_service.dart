import 'package:bonfire/domain/models/reflection.dart';

class ReflectionJournalService {
  const ReflectionJournalService();

  static const List<String> defaultQuestions = [
    'Bugün nasıldı?',
    'Kendini nasıl hissediyorsun?',
    'Bugün en çok neyi öğrendin?',
  ];

  static Reflection buildDailyReflection({
    required DateTime date,
    required Map<String, String> answers,
    String? id,
  }) {
    return Reflection(
      id: id ?? 'reflection_${date.year}_${date.month}_${date.day}',
      date: date,
      questionsAndAnswers: answers,
    );
  }

  static bool hasAnswer(Reflection reflection, String question) {
    final answer = reflection.questionsAndAnswers[question];
    return answer != null && answer.trim().isNotEmpty;
  }
}
