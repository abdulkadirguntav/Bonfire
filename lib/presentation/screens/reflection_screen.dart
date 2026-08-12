import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/domain/models/reflection.dart';
import 'package:bonfire/domain/services/reflection_journal_service.dart';
import 'package:bonfire/presentation/providers/reflection_provider.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key});

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final List<String> _customQuestions = ['Kendi sorunu ekle'];

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _ensureQuestions(String dateKey) {
    final defaultQuestions = ReflectionJournalService.defaultQuestions;
    for (final question in defaultQuestions) {
      if (!_controllers.containsKey(question)) {
        _controllers[question] = TextEditingController();
      }
    }
    if (_customQuestions.isNotEmpty && !_controllers.containsKey(_customQuestions.first)) {
      _controllers[_customQuestions.first] = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userControllerProvider);
    final today = DateTime.now();
    final reflection = ref.watch(reflectionsProvider).where((item) {
      return item.date.year == today.year &&
          item.date.month == today.month &&
          item.date.day == today.day;
    }).firstOrNull;

    _ensureQuestions(today.toIso8601String());

    final questions = <String>[...ReflectionJournalService.defaultQuestions];
    final answers = reflection?.questionsAndAnswers ?? const <String, String>{};

    for (final question in questions) {
      final controller = _controllers[question] ??= TextEditingController();
      final stored = answers[question] ?? '';
      if (controller.text.isEmpty && stored.isNotEmpty) {
        controller.text = stored;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B09),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFB89B5B),
                  size: 42,
                ),
                const SizedBox(height: 16),
                Text(
                  '${today.day}/${today.month}/${today.year}',
                  style: const TextStyle(
                    color: Color(0xFFCFD3D9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),
                ...questions.map((question) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question,
                          style: const TextStyle(
                            color: Color(0xFFEDE7DC),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controllers[question],
                          maxLines: 4,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.5,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '... ',
                            hintStyle: TextStyle(color: Color(0xFF7C7A76)),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 14),
                if (user != null)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final answers = <String, String>{};
                        for (final question in questions) {
                          answers[question] = _controllers[question]?.text.trim() ?? '';
                        }

                        final dailyReflection = Reflection(
                          id: 'reflection_${today.year}_${today.month}_${today.day}',
                          date: today,
                          questionsAndAnswers: answers,
                        );

                        await ref
                            .read(reflectionsProvider.notifier)
                            .saveReflection(dailyReflection);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFB89B5B),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save reflection'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
