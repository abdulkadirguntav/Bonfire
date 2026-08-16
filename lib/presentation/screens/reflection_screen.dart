import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/theme/gothic_theme.dart';
import 'package:bonfire/presentation/providers/reflection_provider.dart';
import 'package:bonfire/presentation/screens/journey_screen.dart';

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

  Future<void> _saveAnswersAndOpenChronicle(List<String> questions) async {
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
            '🔥 Düşüncelerin mühürlendi ve takvime kaydedildi.',
            style: GoogleFonts.cinzel(color: GothicPalette.goldBright),
          ),
        ),
      );

      // Navigate to JourneyScreen (Takvim / Chronicle) to see reflections & timeline
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const JourneyScreen(),
        ),
      );
    }
  }

  void _showAddQuestionDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GothicPalette.onyx,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: GothicPalette.bronze, width: 0.8),
        ),
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
                    .read(activeQuestionsProvider.notifier)
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
    final questions = ref.watch(activeQuestionsProvider);
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
                  const Icon(
                    Icons.nightlight_round,
                    color: GothicPalette.goldBright,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'STOIC REFLECTION',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cinzel(
                        color: GothicPalette.goldBright,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _showAddQuestionDialog,
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: GothicPalette.goldBright, size: 22),
                    tooltip: 'Yeni Soru Ekle',
                  ),
                  if (questions.isEmpty)
                    IconButton(
                      onPressed: () => ref
                          .read(activeQuestionsProvider.notifier)
                          .resetToDefaults(),
                      icon: const Icon(Icons.refresh_rounded,
                          color: GothicPalette.parchmentDim, size: 20),
                      tooltip: 'Varsayılan Soruları Yükle',
                    ),
                ],
              ),
            ),
            // Glowing Bonfire Animation
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: AnimatedBuilder(
                animation: _fireGlowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: GothicPalette.ember.withValues(
                              alpha: _fireGlowAnimation.value * 0.45),
                          blurRadius: 26 * _fireGlowAnimation.value,
                          spreadRadius: 3,
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
                        size: 42,
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
            const SizedBox(height: 10),
            // Questions & frameless text fields
            Expanded(
              child: questions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Tüm sorular kaldırıldı.',
                            style: TextStyle(
                              color: GothicPalette.parchmentDim,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _showAddQuestionDialog,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('KENDİ SORUNU EKLE'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: GothicPalette.goldBright,
                              side: const BorderSide(
                                  color: GothicPalette.goldDeep),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => ref
                                .read(activeQuestionsProvider.notifier)
                                .resetToDefaults(),
                            child: const Text(
                              'Varsayılan Soruları Geri Getir',
                              style: TextStyle(
                                color: GothicPalette.parchmentDim,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      itemCount: questions.length,
                      separatorBuilder: (_, __) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(
                          color: Color(0xFF1E1E1E),
                          thickness: 0.6,
                        ),
                      ),
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        final initialAnswer =
                            todayReflection?.questionsAndAnswers[question] ??
                                '';
                        final controller =
                            _getControllerFor(question, initialAnswer);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    question,
                                    style: GoogleFonts.cinzel(
                                      color: GothicPalette.goldBright,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.close_rounded,
                                      size: 17,
                                      color: GothicPalette.parchmentDim),
                                  tooltip: 'Bu Soruyu Kaldır',
                                  onPressed: () => ref
                                      .read(activeQuestionsProvider.notifier)
                                      .removeQuestion(question),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Completely borderless, void-like TextField
                            TextField(
                              controller: controller,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              style: const TextStyle(
                                color: GothicPalette.parchmentLight,
                                fontSize: 13.5,
                                height: 1.5,
                              ),
                              cursorColor: GothicPalette.goldBright,
                              decoration: InputDecoration(
                                hintText: 'Düşüncelerini buraya yaz...',
                                hintStyle: TextStyle(
                                  color: GothicPalette.parchmentDim
                                      .withValues(alpha: 0.5),
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12.5,
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
                  onPressed: () => _saveAnswersAndOpenChronicle(questions),
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
