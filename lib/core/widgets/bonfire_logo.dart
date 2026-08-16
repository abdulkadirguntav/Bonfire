import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/theme/app_theme.dart';

class BonfireLogo extends StatelessWidget {
  const BonfireLogo({
    super.key,
    this.size = 32,
    this.showText = true,
    this.letterSpacing = 3.0,
    this.fontSize = 18,
  });

  final double size;
  final bool showText;
  final double letterSpacing;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size + 8,
              height: size + 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppPalette.primaryGold.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.local_fire_department_rounded,
              color: AppPalette.primaryGold,
              size: size,
            ),
          ],
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'BONFIRE',
                style: GoogleFonts.cinzel(
                  color: AppPalette.primaryGold,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: letterSpacing,
                ),
              ),
              Text(
                'KÜL VE İRADE',
                style: GoogleFonts.inter(
                  color: AppPalette.textDim,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
