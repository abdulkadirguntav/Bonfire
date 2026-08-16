import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/core/theme/gothic_theme.dart';
import 'package:bonfire/core/widgets/ornate_widgets.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: GothicPalette.obsidian,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                Icons.local_fire_department_rounded,
                color: GothicPalette.emberBright,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'BONFIRE',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: GothicPalette.goldBright,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Karanlığın ortasında yanan son kıvılcım.\nKüllerinden doğ, yeminlerini tut ve ateşini canlı tut.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: GothicPalette.parchment,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              OrnateFrame(
                radius: 12,
                glow: true,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _RuleRow(
                        icon: Icons.bolt_rounded,
                        color: GothicPalette.goldBright,
                        title: 'Stamina (Dayanıklılık)',
                        desc: 'Her gün 100 Stamina ile başlarsın. Tamamlanan görevler enerjini tüketir ve Öz kazandırır.',
                      ),
                      SizedBox(height: 12),
                      _RuleRow(
                        icon: Icons.warning_amber_rounded,
                        color: GothicPalette.emberBright,
                        title: 'Tükenmişlik Riski',
                        desc: 'Stamina 0 iken görev eklemek risklidir. İhmal edilen görevler 1.5x HP hasarı verir.',
                      ),
                      SizedBox(height: 12),
                      _RuleRow(
                        icon: Icons.replay_rounded,
                        color: GothicPalette.bloodBright,
                        title: 'Ölüm ve Kül İzi',
                        desc: 'Canın biterse ölürsün. Özlerin sıfırlanır; aynı gün serisine ulaştığında kayıp özlerini geri kazanırsın.',
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(userControllerProvider.notifier)
                        .beginJourney();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GothicPalette.goldBright,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(
                      color: GothicPalette.brass,
                      width: 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ATEŞİ YAK / YOLCULUĞA BAŞLA',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  color: GothicPalette.parchmentLight,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
