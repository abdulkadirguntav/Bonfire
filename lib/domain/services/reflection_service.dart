import 'package:bonfire/domain/models/reflection.dart';

class ReflectionService {
  const ReflectionService._();

  static List<String> getAllQuestions(List<String> customQuestions) {
    return [
      ...Reflection.defaultQuestions,
      ...customQuestions,
    ];
  }

  static Reflection createReflection({
    required DateTime date,
    required Map<String, String> answers,
    String? id,
  }) {
    return Reflection(
      id: id ?? 'ref_${date.millisecondsSinceEpoch}',
      date: date,
      questionsAndAnswers: answers,
    );
  }
}
