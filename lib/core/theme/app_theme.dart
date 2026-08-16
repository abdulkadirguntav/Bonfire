import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Apple x Dark Souls Minimalist Color Palette
class AppPalette {
  const AppPalette._();

  /// Scaffold background: Dark ash gray (NEVER pure black #000000)
  static const Color scaffoldBackground = Color(0xFF0E1013);

  /// Card / Surface: Slightly elevated translucent dark gray
  static const Color surface = Color(0xFF1A1C23);
  static const Color surfaceElevated = Color(0xFF222530);

  /// Primary / Accent: Pale antique gold (used sparingly for icons and active accents)
  static const Color primaryGold = Color(0xFFC8A97E);
  static const Color primaryGoldBright = Color(0xFFDFC095);
  static const Color goldMuted = Color(0xFF8C7353);

  /// Health / Error / Danger: Matte blood crimson
  static const Color bloodCrimson = Color(0xFF8B2C24);
  static const Color bloodBright = Color(0xFFA8362D);

  /// Stamina: Ashen tranquil blue
  static const Color staminaBlue = Color(0xFF4A7298);
  static const Color staminaBlueBright = Color(0xFF6B94BC);

  /// Text colors
  static const Color textBoneWhite = Color(0xFFE1DCD3);
  static const Color textAshGray = Color(0xFF868A93);
  static const Color textDim = Color(0xFF5E626C);

  /// Subtle hairline borders and dividers (opacity ~0.1 - 0.15)
  static const Color borderSubtle = Color(0x1F868A93);
  static const Color dividerLine = Color(0x1A868A93);
}

/// AppTheme definition configuring ThemeData with Cinzel headings and Inter body
class AppTheme {
  const AppTheme._();

  static ThemeData build() {
    final baseTextTheme = Typography.material2021().white;

    final textTheme = baseTextTheme.copyWith(
      // Headings: Cinzel (Baroque & Ancient Dark Souls tone)
      displayLarge: GoogleFonts.cinzel(
        color: AppPalette.textBoneWhite,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
      ),
      displayMedium: GoogleFonts.cinzel(
        color: AppPalette.textBoneWhite,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
      ),
      displaySmall: GoogleFonts.cinzel(
        color: AppPalette.textBoneWhite,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
      headlineMedium: GoogleFonts.cinzel(
        color: AppPalette.textBoneWhite,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
      headlineSmall: GoogleFonts.cinzel(
        color: AppPalette.textBoneWhite,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
      titleLarge: GoogleFonts.cinzel(
        color: AppPalette.textBoneWhite,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
      titleMedium: GoogleFonts.cinzel(
        color: AppPalette.textBoneWhite,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
      titleSmall: GoogleFonts.cinzel(
        color: AppPalette.textAshGray,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),

      // Body & UI: Inter (Clean Apple readability)
      bodyLarge: GoogleFonts.inter(
        color: AppPalette.textBoneWhite,
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      bodyMedium: GoogleFonts.inter(
        color: AppPalette.textBoneWhite,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.35,
      ),
      bodySmall: GoogleFonts.inter(
        color: AppPalette.textAshGray,
        fontSize: 11.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
      labelLarge: GoogleFonts.inter(
        color: AppPalette.primaryGold,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
      labelMedium: GoogleFonts.inter(
        color: AppPalette.textAshGray,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
      labelSmall: GoogleFonts.inter(
        color: AppPalette.textAshGray,
        fontSize: 9.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppPalette.scaffoldBackground,
      canvasColor: AppPalette.scaffoldBackground,
      cardColor: AppPalette.surface,
      colorScheme: const ColorScheme.dark(
        primary: AppPalette.primaryGold,
        onPrimary: Color(0xFF141414),
        surface: AppPalette.surface,
        onSurface: AppPalette.textBoneWhite,
        error: AppPalette.bloodCrimson,
        onError: AppPalette.textBoneWhite,
      ),
      textTheme: textTheme,
      dividerTheme: const DividerThemeData(
        color: AppPalette.dividerLine,
        thickness: 1.0,
        space: 1.0,
      ),
      iconTheme: const IconThemeData(
        color: AppPalette.primaryGold,
        size: 20,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppPalette.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.headlineSmall,
        iconTheme: const IconThemeData(color: AppPalette.primaryGold),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppPalette.scaffoldBackground,
        indicatorColor: AppPalette.primaryGold.withValues(alpha: 0.12),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return GoogleFonts.cinzel(
            color: isSelected
                ? AppPalette.primaryGold
                : AppPalette.textAshGray,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 1.2,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected
                ? AppPalette.primaryGold
                : AppPalette.textAshGray,
            size: 21,
          );
        }),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.primaryGold,
          side: const BorderSide(color: AppPalette.primaryGold, width: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.surface,
        hintStyle: GoogleFonts.inter(
          color: AppPalette.textDim,
          fontSize: 13,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppPalette.textAshGray,
          fontSize: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.borderSubtle, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.primaryGold, width: 0.9),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.bloodCrimson, width: 0.8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppPalette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppPalette.borderSubtle, width: 0.8),
        ),
        titleTextStyle: GoogleFonts.cinzel(
          color: AppPalette.primaryGold,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.inter(
          color: AppPalette.textBoneWhite,
          fontSize: 13,
          height: 1.4,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: AppPalette.textAshGray, width: 1.0),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppPalette.primaryGold;
          }
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Color(0xFF0E1013)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppPalette.surfaceElevated,
        contentTextStyle: GoogleFonts.inter(
          color: AppPalette.textBoneWhite,
          fontSize: 12.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppPalette.borderSubtle, width: 0.8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
