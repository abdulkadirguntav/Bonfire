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

  static List<Reflection> saveReflection(
    List<Reflection> current, {
    required Map<String, String> answers,
    DateTime? now,
    List<String>? questions,
  }) {
    final date = now ?? DateTime.now();
    final newRef = createReflection(date: date, answers: answers);
    final list = current.where((r) => !r.isSameDay(date)).toList();
    list.add(newRef);
    return list;
  }

  static Reflection? getTodayReflection(List<Reflection> list, {DateTime? now}) {
    final target = now ?? DateTime.now();
    return getReflectionForDate(list, target);
  }

  static Reflection? getReflectionForDate(List<Reflection> list, DateTime target) {
    for (final r in list) {
      if (r.isSameDay(target)) return r;
    }
    return null;
  }

  static bool hasReflectedToday(List<Reflection> list, {DateTime? now}) {
    return getTodayReflection(list, now: now) != null;
  }
}
