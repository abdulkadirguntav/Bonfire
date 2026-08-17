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
    this.vertical = false,
  });

  final double size;
  final bool showText;
  final double letterSpacing;
  final double fontSize;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final emblem = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: AppPalette.primaryGold.withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          'assets/images/bonfire_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.local_fire_department_rounded,
            color: AppPalette.primaryGold,
            size: size,
          ),
        ),
      ),
    );

    if (!showText) {
      return emblem;
    }

    final textColumn = Column(
      crossAxisAlignment:
          vertical ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
            fontSize: (fontSize * 0.42).clamp(7.0, 11.0),
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );

    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          emblem,
          const SizedBox(height: 10),
          textColumn,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        emblem,
        const SizedBox(width: 10),
        textColumn,
      ],
    );
  }
}
