import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/theme/app_theme.dart';
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
      backgroundColor: const Color(0xFF140D0E),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  'YOU DIED',
                  style: GoogleFonts.cinzel(
                    color: AppPalette.bloodCrimson,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppPalette.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppPalette.bloodCrimson.withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kaybedilen Öz (Essence):',
                            style: GoogleFonts.inter(
                              color: AppPalette.textAshGray,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '$lostEssence',
                            style: GoogleFonts.cinzel(
                              color: AppPalette.primaryGold,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hedef Gün Serisi:',
                            style: GoogleFonts.inter(
                              color: AppPalette.textAshGray,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Gün $targetStreak',
                            style: GoogleFonts.cinzel(
                              color: AppPalette.textBoneWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Küllerinden yeniden doğ!\n1. günden başlayıp aynı gün serisine ulaştığında kaybettiğin tüm Öz\'ü geri kazanacaksın.\nAncak hedefe ulaşamadan tekrar ölürsen eski izin sonsuza dek silinir.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: AppPalette.textAshGray,
                    fontSize: 12,
                    height: 1.5,
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
                      foregroundColor: AppPalette.primaryGold,
                      side: const BorderSide(
                          color: AppPalette.primaryGold, width: 0.9),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'ATEŞİN BAŞINDA UYAN',
                      style: GoogleFonts.cinzel(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
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
