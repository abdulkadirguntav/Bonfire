import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/localization/app_localizations.dart';
import 'package:bonfire/core/theme/app_theme.dart';
import 'package:bonfire/core/widgets/ornate_widgets.dart';
import 'package:bonfire/presentation/providers/reflection_provider.dart';
import 'package:bonfire/presentation/screens/journey_screen.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key});

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
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
    final l10n = AppLocalizations.of(context);
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
          backgroundColor: AppPalette.surfaceElevated,
          content: Text(
            l10n.isTurkish
                ? '🔥 Düşüncelerin mühürlendi ve takvime kaydedildi.'
                : '🔥 Reflections sealed and saved to chronicle.',
            style: GoogleFonts.inter(color: AppPalette.primaryGold),
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
    final l10n = AppLocalizations.of(context);
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppPalette.borderSubtle, width: 0.8),
        ),
        title: Text(
          l10n.isTurkish ? 'Özel Muhasebe Sorusu Ekle' : 'Add Custom Question',
          style: GoogleFonts.cinzel(
            color: AppPalette.primaryGold,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.isTurkish
                  ? 'Kendine sormak istediğin stoacı bir soru ekle.'
                  : 'Enter a stoic question for evening reflection.',
              style: GoogleFonts.inter(
                color: AppPalette.textBoneWhite,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 2,
              style: GoogleFonts.inter(
                color: AppPalette.textBoneWhite,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: l10n.isTurkish
                    ? 'Örn: Bugün hangi engeli bir basamağa çevirdim?'
                    : 'e.g. How did I turn an obstacle into an advantage today?',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.inter(color: AppPalette.textAshGray),
            ),
          ),
          OutlinedButton(
            onPressed: () async {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                await ref
                    .read(activeQuestionsProvider.notifier)
                    .addQuestion(text);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppPalette.primaryGold,
              side: const BorderSide(color: AppPalette.primaryGold, width: 0.8),
            ),
            child: Text(l10n.isTurkish ? 'EKLE' : 'ADD'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final customQuestions = ref.watch(activeQuestionsProvider);
    final todayReflection = ref
        .watch(reflectionControllerProvider.notifier)
        .getReflectionFor(DateTime.now());

    return Scaffold(
      backgroundColor: AppPalette.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              Row(
                children: [
                  const Icon(
                    Icons.auto_stories_rounded,
                    color: AppPalette.primaryGold,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.reflectionTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cinzel(
                            color: AppPalette.primaryGold,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Text(
                          l10n.isTurkish
                              ? 'GÜN SONU İÇSEL MUHASEBE'
                              : 'EVENING STOIC INQUIRY',
                          style: GoogleFonts.inter(
                            color: AppPalette.textAshGray,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _showAddQuestionDialog,
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppPalette.primaryGold,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quote Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppPalette.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppPalette.borderSubtle,
                    width: 0.9,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.nights_stay_rounded,
                      color: AppPalette.primaryGold,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.isTurkish
                            ? '❝ Gözlerini kapatmadan önce günün her anını sorgula: Ne yaptın? Neyi yapmadın? ❞\n— Seneca'
                            : '❝ Before sleep closes your eyes, review the deeds of the day: What was done? What was left undone? ❞\n— Seneca',
                        style: GoogleFonts.cinzel(
                          color: AppPalette.textBoneWhite,
                          fontSize: 11,
                          height: 1.35,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              SectionTitle(
                  l10n.isTurkish ? 'Günün Soruları' : 'Daily Inquiries'),
              const SizedBox(height: 6),

              // Questions List
              Expanded(
                child: customQuestions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.isTurkish
                                  ? 'Tüm sorular kaldırıldı. Kendi sorularını ekleyebilirsin.'
                                  : 'All questions cleared. Add your own.',
                              style: GoogleFonts.inter(
                                color: AppPalette.textAshGray,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: _showAddQuestionDialog,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppPalette.primaryGold,
                                side: const BorderSide(
                                    color: AppPalette.primaryGold, width: 0.8),
                              ),
                              icon: const Icon(Icons.add, size: 16),
                              label: Text(l10n.isTurkish
                                  ? 'SORU EKLE'
                                  : 'ADD QUESTION'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: customQuestions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final question = customQuestions[index];
                          final initialAnswer =
                              todayReflection?.answers[question] ?? '';
                          final controller =
                              _getControllerFor(question, initialAnswer);

                          return Container(
                            decoration: BoxDecoration(
                              color: AppPalette.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppPalette.borderSubtle,
                                width: 0.8,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          question,
                                          style: GoogleFonts.inter(
                                            color: AppPalette.textBoneWhite,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          color: AppPalette.textDim,
                                          size: 16,
                                        ),
                                        onPressed: () => ref
                                            .read(activeQuestionsProvider
                                                .notifier)
                                            .removeQuestion(question),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: controller,
                                    maxLines: 2,
                                    style: GoogleFonts.inter(
                                      color: AppPalette.textBoneWhite,
                                      fontSize: 12.5,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: l10n.isTurkish
                                          ? 'Cevabını buraya yaz...'
                                          : 'Write your reflection here...',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      _saveAnswersAndOpenChronicle(customQuestions),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppPalette.primaryGold,
                    side: const BorderSide(
                        color: AppPalette.primaryGold, width: 0.9),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.sealAndRest,
                    style: GoogleFonts.cinzel(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
