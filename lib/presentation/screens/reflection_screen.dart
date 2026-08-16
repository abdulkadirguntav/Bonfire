import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/theme/gothic_theme.dart';
import 'package:bonfire/domain/models/reflection.dart';
import 'package:bonfire/domain/services/reflection_service.dart';
import 'package:bonfire/presentation/providers/reflection_provider.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key});

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen>
    with SingleTickerProviderStateMixin {
  final Map<String, TextEditingController> _controllers = {};
  late AnimationController _fireAnimationController;
  late Animation<double> _fireGlowAnimation;

  @override
  void initState() {
    super.initState();
    _fireAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fireGlowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _fireAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _fireAnimationController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getControllerFor(
      String question, String initialAnswer) {
    if (!_controllers.containsKey(question)) {
      _controllers[question] = TextEditingController(text: initialAnswer);
    }
    return _controllers[question]!;
  }

  Future<void> _saveAnswers(List<String> questions) async {
    final Map<String, String> answers = {};
    for (final q in questions) {
      final text = _controllers[q]?.text.trim() ?? '';
      if (text.isNotEmpty) {
        answers[q] = text;
      }
    }

    await ref
        .read(reflectionControllerProvider.notifier)
        .saveReflection(date: DateTime.now(), answers: answers);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: GothicPalette.onyx,
          content: Text(
            '🔥 Düşüncelerin küllere emanet edildi. Dinlen, savaşçı.',
            style: GoogleFonts.cinzel(color: GothicPalette.goldBright),
          ),
        ),
      );
    }
  }

  void _showAddCustomQuestionDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GothicPalette.onyx,
        title: Text(
          'Özel Muhasebe Sorusu Ekle',
          style: GoogleFonts.cinzel(
            color: GothicPalette.goldBright,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: GothicPalette.parchmentLight),
          decoration: const InputDecoration(
            hintText: 'Örn: Bugün irademi ne sınadı?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal',
                style: TextStyle(color: GothicPalette.parchmentDim)),
          ),
          OutlinedButton(
            onPressed: () async {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                await ref
                    .read(customQuestionsProvider.notifier)
                    .addQuestion(text);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: GothicPalette.goldBright,
              side: const BorderSide(color: GothicPalette.brass),
            ),
            child: const Text('EKLE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customQuestions = ref.watch(customQuestionsProvider);
    final allQuestions = ReflectionService.getAllQuestions(customQuestions);

    final todayReflection = ref
        .watch(reflectionControllerProvider.notifier)
        .getReflectionFor(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: GothicPalette.parchmentDim, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    'STOIC REFLECTION',
                    style: GoogleFonts.cinzel(
                      color: GothicPalette.goldBright,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _showAddCustomQuestionDialog,
                    icon: const Icon(Icons.add_comment_outlined,
                        color: GothicPalette.goldBright, size: 22),
                    tooltip: 'Özel Soru Ekle',
                  ),
                ],
              ),
            ),
            // Glowing Bonfire Animation / Icon
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: AnimatedBuilder(
                animation: _fireGlowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: GothicPalette.ember
                              .withValues(alpha: _fireGlowAnimation.value * 0.45),
                          blurRadius: 28 * _fireGlowAnimation.value,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        color: Color.lerp(
                          GothicPalette.ember,
                          GothicPalette.goldBright,
                          _fireGlowAnimation.value,
                        ),
                        size: 46,
                      ),
                    ),
                  );
                },
              ),
            ),
            Text(
              'Ateş çatırdıyor... Zihnini boşluğa dök.',
              style: TextStyle(
                color: GothicPalette.parchmentDim,
                fontSize: 12,
                fontFamily: GoogleFonts.cinzel().fontFamily,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 14),
            // Frameless, dark, void-like writing area
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: allQuestions.length,
                separatorBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Divider(
                    color: Color(0xFF1E1E1E),
                    thickness: 0.6,
                  ),
                ),
                itemBuilder: (context, index) {
                  final question = allQuestions[index];
                  final initialAnswer =
                      todayReflection?.questionsAndAnswers[question] ?? '';
                  final controller =
                      _getControllerFor(question, initialAnswer);
                  final isCustom = Reflection.defaultQuestions.contains(question) == false;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              question,
                              style: GoogleFonts.cinzel(
                                color: GothicPalette.goldBright,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                              ),
                            ),
                          ),
                          if (isCustom)
                            IconButton(
                              icon: const Icon(Icons.close,
                                  size: 16, color: GothicPalette.parchmentDim),
                              onPressed: () => ref
                                  .read(customQuestionsProvider.notifier)
                                  .removeQuestion(question),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Completely borderless, void-like TextField
                      TextField(
                        controller: controller,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(
                          color: GothicPalette.parchmentLight,
                          fontSize: 14,
                          height: 1.6,
                        ),
                        cursorColor: GothicPalette.goldBright,
                        decoration: InputDecoration(
                          hintText: 'Düşüncelerini buraya yaz...',
                          hintStyle: TextStyle(
                            color: GothicPalette.parchmentDim.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Bottom Action
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _saveAnswers(allQuestions),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GothicPalette.goldBright,
                    side: const BorderSide(
                        color: GothicPalette.bronze, width: 0.8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.fireplace_rounded,
                      size: 18, color: GothicPalette.emberBright),
                  label: Text(
                    'MÜHÜRLE VE DİNLEN',
                    style: GoogleFonts.cinzel(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
