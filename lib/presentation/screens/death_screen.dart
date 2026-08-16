import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/core/theme/gothic_theme.dart';
import 'package:bonfire/core/widgets/ornate_widgets.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';

class DeathScreen extends ConsumerWidget {
  const DeathScreen({
    super.key,
    required this.lostEssence,
    required this.targetStreak,
  });

  final int lostEssence;
  final int targetStreak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF120909),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text(
                  'YOU DIED',
                  style: TextStyle(
                    color: GothicPalette.bloodBright,
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 24),
                OrnateFrame(
                  radius: 12,
                  outerGradient: const LinearGradient(
                    colors: [
                      Color(0xFF5A1E1E),
                      Color(0xFF8E2A2A),
                      Color(0xFF3A1212),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Kaybedilen Öz (Essence):',
                              style: TextStyle(
                                color: GothicPalette.parchment,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '$lostEssence',
                              style: const TextStyle(
                                color: GothicPalette.goldBright,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Hedef Gün Serisi:',
                              style: TextStyle(
                                color: GothicPalette.parchment,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Gün $targetStreak',
                              style: const TextStyle(
                                color: GothicPalette.parchmentLight,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Küllerinden yeniden doğ!\n1. günden başlayıp aynı gün serisine ulaştığında kaybettiğin tüm Öz\'ü geri kazanacaksın.\nAncak hedefe ulaşamadan tekrar ölürsen eski izin sonsuza dek silinir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: GothicPalette.ashGray,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await ref
                          .read(userControllerProvider.notifier)
                          .resolveDeathIfNeeded();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GothicPalette.emberBright,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(
                        color: GothicPalette.bloodBright,
                        width: 1.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'KÜLLERDEN YENİDEN DOĞ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
