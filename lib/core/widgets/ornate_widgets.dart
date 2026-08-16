import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/theme/app_theme.dart';
import 'package:bonfire/core/theme/gothic_theme.dart';

/// Minimalist container with max 10px-12px radius, subtle 1px border and soft ambient glow
class OrnateFrame extends StatelessWidget {
  const OrnateFrame({
    super.key,
    required this.child,
    this.padding,
    this.radius = 10,
    this.innerRadius,
    this.outerGradient,
    this.panelGradient,
    this.glow = false,
    this.borderWidth = 1.0,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double? innerRadius;
  final LinearGradient? outerGradient;
  final LinearGradient? panelGradient;
  final bool glow;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: glow
              ? AppPalette.primaryGold.withValues(alpha: 0.25)
              : AppPalette.borderSubtle,
          width: borderWidth,
        ),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppPalette.primaryGold.withValues(alpha: 0.05),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}

/// Minimalist Inset Frame
class IronInsetFrame extends StatelessWidget {
  const IronInsetFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 10,
    this.borderWidth = 1.0,
    this.activeEmber = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double borderWidth;
  final bool activeEmber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: activeEmber
              ? AppPalette.bloodCrimson.withValues(alpha: 0.4)
              : AppPalette.borderSubtle,
          width: borderWidth,
        ),
      ),
      child: child,
    );
  }
}

/// 2.5px Minimalist HP/Stamina Progress Line with modern typography
class DetailedHpBar extends StatelessWidget {
  const DetailedHpBar({
    super.key,
    required this.value,
    required this.label,
    this.height = 2.5,
    this.fillGradient,
    this.activeColor,
  });

  final double value;
  final String label;
  final double height;
  final Gradient? fillGradient;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final color = activeColor ??
        (label.contains('HP') || label.contains('CAN')
            ? AppPalette.bloodCrimson
            : label.contains('STAMINA')
                ? AppPalette.staminaBlue
                : AppPalette.primaryGold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label row: Clean bone white typography
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppPalette.textBoneWhite,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        // Minimal 2.5px Progress Line
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF222530),
            borderRadius: BorderRadius.circular(1.5),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: clamped,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1.5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Minimalist Section Title with subtle 1px divider
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.icon});

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppPalette.primaryGold, size: 15),
                const SizedBox(width: 6),
              ],
              Text(
                title.toUpperCase(),
                style: GoogleFonts.cinzel(
                  color: AppPalette.textBoneWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppPalette.dividerLine,
          ),
        ],
      ),
    );
  }
}

/// Minimalist Stat Value Component
class MinimalStatBadge extends StatelessWidget {
  const MinimalStatBadge({
    super.key,
    required this.label,
    required this.value,
    this.isGold = false,
  });

  final String label;
  final String value;
  final bool isGold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            color: AppPalette.textAshGray,
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.cinzel(
            color: isGold ? AppPalette.primaryGold : AppPalette.textBoneWhite,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
