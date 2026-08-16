import 'package:flutter/material.dart';
import 'package:bonfire/core/theme/app_theme.dart';

export 'package:bonfire/core/theme/app_theme.dart';

/// GothicPalette aliasing and modernizing to AppPalette
class GothicPalette {
  const GothicPalette._();

  // Background & Surfaces (Apple x Dark Souls: No pure black)
  static const Color obsidian = AppPalette.scaffoldBackground; // #0E1013
  static const Color onyx = AppPalette.surface; // #1A1C23
  static const Color ironBlack = AppPalette.surface;
  static const Color charcoal = Color(0xFF222530);
  static const Color slate = Color(0xFF2D313F);

  // Text & Parchment (Bone white & Pale ash gray)
  static const Color parchmentLight = AppPalette.textBoneWhite; // #E1DCD3
  static const Color parchment = Color(0xFFD0CBC0);
  static const Color parchmentDim = AppPalette.textAshGray; // #868A93
  static const Color ashGray = AppPalette.textAshGray;
  static const Color smoke = AppPalette.textDim;

  // Gold & Accents (Pale antique gold #C8A97E)
  static const Color goldBright = AppPalette.primaryGold; // #C8A97E
  static const Color gold = AppPalette.primaryGold;
  static const Color goldDeep = AppPalette.goldMuted;
  static const Color brass = AppPalette.primaryGold;
  static const Color bronze = AppPalette.goldMuted;

  // Embers & Blood (Matte crimson #8B2C24)
  static const Color emberBright = Color(0xFFC85A32);
  static const Color ember = AppPalette.bloodCrimson;
  static const Color emberDeep = Color(0xFF6B1E18);
  static const Color blood = AppPalette.bloodCrimson;
  static const Color bloodBright = AppPalette.bloodCrimson;

  // Subtle 1px borders & dividers (0.1 opacity)
  static const Color borderHairline = AppPalette.borderSubtle;
  static const Color divider = AppPalette.dividerLine;

  // Minimalist soft gradients
  static const LinearGradient goldFrameGradient = LinearGradient(
    colors: [
      Color(0x2AC8A97E),
      Color(0x0AC8A97E),
    ],
  );

  static const LinearGradient goldFrameGradientSoft = LinearGradient(
    colors: [
      Color(0x1FC8A97E),
      Color(0x05C8A97E),
    ],
  );

  static const LinearGradient emberCore = LinearGradient(
    colors: [
      Color(0xFFC8A97E),
      Color(0xFF8B2C24),
    ],
  );

  static const LinearGradient healthCore = LinearGradient(
    colors: [
      Color(0xFFA8362D),
      Color(0xFF8B2C24),
    ],
  );

  static const LinearGradient staminaCore = LinearGradient(
    colors: [
      Color(0xFF6B94BC),
      Color(0xFF4A7298),
    ],
  );

  static const LinearGradient obsidianPanel = LinearGradient(
    colors: [
      Color(0xFF1A1C23),
      Color(0xFF16181F),
    ],
  );

  static const List<BoxShadow> emberGlow = [
    BoxShadow(
      color: Color(0x18C8A97E),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> goldGlow = [
    BoxShadow(
      color: Color(0x14C8A97E),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];
}

/// GothicTheme delegating to AppTheme
class GothicTheme {
  const GothicTheme._();

  static ThemeData build() => AppTheme.build();
}
