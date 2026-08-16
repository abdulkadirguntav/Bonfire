import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GothicPalette {
  const GothicPalette._();

  static const Color obsidian = Color(0xFF0D0D0D);
  static const Color onyx = Color(0xFF141414);
  static const Color ironBlack = Color(0xFF1A1A1A);
  static const Color charcoal = Color(0xFF222222);
  static const Color slate = Color(0xFF2A2A2A);

  static const Color parchmentLight = Color(0xFFEDE0C8);
  static const Color parchment = Color(0xFFCFC4A8);
  static const Color parchmentDim = Color(0xFF8C8474);
  static const Color ashGray = Color(0xFFB2BAC7);
  static const Color smoke = Color(0xFF6E6E6E);

  static const Color goldBright = Color(0xFFFFD700);
  static const Color gold = Color(0xFFDAA520);
  static const Color goldDeep = Color(0xFF8B6914);
  static const Color brass = Color(0xFFB89B5B);
  static const Color bronze = Color(0xFF6E4A1C);

  static const Color emberBright = Color(0xFFFF6A1A);
  static const Color ember = Color(0xFFE25822);
  static const Color emberDeep = Color(0xFF7A1F0A);
  static const Color blood = Color(0xFF8E2A2A);
  static const Color bloodBright = Color(0xFFB02020);

  static const LinearGradient goldFrameGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6E5A32),
      Color(0xFF9D8650),
      Color(0xFFB89B5B),
      Color(0xFF74603A),
      Color(0xFF3F321D),
    ],
    stops: [0.0, 0.35, 0.5, 0.7, 1.0],
  );

  static const LinearGradient goldFrameGradientSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF493819),
      Color(0xFF756035),
      Color(0xFFA3884B),
      Color(0xFF695631),
      Color(0xFF3B2E1B),
    ],
    stops: [0.0, 0.3, 0.55, 0.8, 1.0],
  );

  static const LinearGradient emberCore = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFD700),
      Color(0xFFFF6A1A),
      Color(0xFFE25822),
      Color(0xFF7A1F0A),
    ],
    stops: [0.0, 0.3, 0.65, 1.0],
  );

  static const LinearGradient healthCore = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFF5A5F),
      Color(0xFFD92532),
      Color(0xFF8D101C),
    ],
  );

  static const LinearGradient staminaCore = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF5EBBFF),
      Color(0xFF1976D2),
      Color(0xFF0B3E7A),
    ],
  );

  static const LinearGradient obsidianPanel = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1F1812),
      Color(0xFF141414),
      Color(0xFF0D0D0D),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient parchmentScroll = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2A2418),
      Color(0xFF1F1B14),
    ],
  );

  static const List<BoxShadow> emberGlow = [
    BoxShadow(
      color: Color(0x1AE25822),
      blurRadius: 6,
      offset: Offset(0, 3),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> goldGlow = [
    BoxShadow(
      color: Color(0x1ADAA520),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> ironInset = [
    BoxShadow(
      color: Color(0x55000000),
      blurRadius: 4,
      offset: Offset(2, 2),
    ),
    BoxShadow(
      color: Color(0x22FFFFFF),
      blurRadius: 1,
      offset: Offset(-1, -1),
    ),
  ];
}

class GothicTheme {
  const GothicTheme._();

  static ThemeData build() {
    final baseText =
        GoogleFonts.cinzelTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: GothicPalette.parchmentLight,
      displayColor: GothicPalette.parchmentLight,
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: GothicPalette.obsidian,
      canvasColor: GothicPalette.obsidian,
      colorScheme: const ColorScheme.dark(
        primary: GothicPalette.goldBright,
        onPrimary: GothicPalette.obsidian,
        secondary: GothicPalette.ember,
        onSecondary: GothicPalette.obsidian,
        surface: GothicPalette.onyx,
        onSurface: GothicPalette.parchmentLight,
        error: GothicPalette.bloodBright,
        onError: GothicPalette.parchmentLight,
      ),
      primaryColor: GothicPalette.goldBright,
      fontFamily: GoogleFonts.cinzel().fontFamily,
      textTheme: baseText,
      primaryTextTheme: baseText,
      iconTheme: const IconThemeData(
        color: GothicPalette.goldBright,
        size: 22,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.cinzel(
          color: GothicPalette.goldBright,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.5,
        ),
        iconTheme: const IconThemeData(color: GothicPalette.goldBright),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: GothicPalette.onyx,
        indicatorColor: GothicPalette.ember.withValues(alpha: 0.25),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.cinzel(
            color: selected ? GothicPalette.goldBright : GothicPalette.ashGray,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 1.2,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? GothicPalette.goldBright : GothicPalette.ashGray,
            size: 24,
          );
        }),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GothicPalette.gold,
          backgroundColor: GothicPalette.onyx,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          side: const BorderSide(color: GothicPalette.bronze, width: 0.8),
          textStyle: GoogleFonts.cinzel(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GothicPalette.ironBlack,
        hintStyle: GoogleFonts.cinzel(
          color: GothicPalette.parchmentDim,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
        labelStyle: GoogleFonts.cinzel(
          color: GothicPalette.goldBright,
          fontSize: 13,
          letterSpacing: 1.5,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: const GothicInputBorder(),
        enabledBorder: const GothicInputBorder(),
        focusedBorder: const GothicInputBorder(active: true),
        errorBorder: const GothicInputBorder(error: true),
        focusedErrorBorder: const GothicInputBorder(error: true, active: true),
      ),
      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(color: GothicPalette.goldDeep, width: 0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GothicPalette.goldBright;
          }
          return GothicPalette.parchmentDim;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GothicPalette.ember.withValues(alpha: 0.6);
          }
          return GothicPalette.slate;
        }),
        trackOutlineColor: WidgetStateProperty.all(
            GothicPalette.goldDeep.withValues(alpha: 0.6)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: GothicPalette.ironBlack,
        selectedColor: GothicPalette.ember,
        side: const BorderSide(color: GothicPalette.goldDeep),
        labelStyle: GoogleFonts.cinzel(
          color: GothicPalette.parchmentLight,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
        secondaryLabelStyle: GoogleFonts.cinzel(
          color: GothicPalette.obsidian,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: GothicPalette.ironBlack,
        contentTextStyle: GoogleFonts.cinzel(
          color: GothicPalette.parchmentLight,
          fontSize: 14,
        ),
        actionTextColor: GothicPalette.goldBright,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: GothicPalette.goldDeep, width: 0.8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: GothicPalette.ember,
        foregroundColor: GothicPalette.obsidian,
        elevation: 6,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: GothicPalette.onyx,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: GothicPalette.goldDeep, width: 0.8),
        ),
        titleTextStyle: GoogleFonts.cinzel(
          color: GothicPalette.goldBright,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
        contentTextStyle: GoogleFonts.cinzel(
          color: GothicPalette.parchmentLight,
          fontSize: 14,
        ),
      ),
    );
  }
}

class GothicInputBorder extends InputBorder {
  const GothicInputBorder({
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.active = false,
    this.error = false,
    BorderSide borderSide = BorderSide.none,
  }) : _borderSide = borderSide;

  final BorderSide _borderSide;

  @override
  BorderSide get borderSide => _borderSide;

  final BorderRadius borderRadius;
  final bool active;
  final bool error;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(6);

  @override
  ShapeBorder scale(double t) => GothicInputBorder(
      borderRadius: borderRadius, active: active, error: error);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final radius = borderRadius.topLeft.x;
    return Path()
      ..addRRect(
          RRect.fromRectAndRadius(rect.deflate(1), Radius.circular(radius)));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final radius = borderRadius.topLeft.x;
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
  }

  @override
  bool get isOutline => false;

  @override
  void paint(Canvas canvas, Rect rect,
      {double? gapStart,
      double? gapExtent,
      double? gapPercentage,
      TextDirection? textDirection}) {
    final outer = Paint()
      ..shader = active
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFB89B5B),
                Color(0xFFD09A42),
                Color(0xFF8B6914),
                Color(0xFF4A3818),
              ],
            ).createShader(rect)
          : GothicPalette.goldFrameGradientSoft.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 0.9 : 0.6;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, borderRadius.topLeft),
      outer,
    );
  }

  @override
  GothicInputBorder copyWith(
          {BorderSide? borderSide,
          BorderRadius? borderRadius,
          bool? active,
          bool? error}) =>
      GothicInputBorder(
        borderRadius: borderRadius ?? this.borderRadius,
        borderSide: borderSide ?? this.borderSide,
        active: active ?? this.active,
        error: error ?? this.error,
      );

  @override
  bool operator ==(Object other) =>
      other is GothicInputBorder &&
      other.borderRadius == borderRadius &&
      other.borderSide == borderSide &&
      other.active == active &&
      other.error == error;

  @override
  int get hashCode => Object.hash(borderRadius, borderSide, active, error);
}
