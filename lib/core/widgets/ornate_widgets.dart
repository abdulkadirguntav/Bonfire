import 'package:flutter/material.dart';

import 'package:bonfire/core/theme/gothic_theme.dart';

class OrnateFrame extends StatelessWidget {
  const OrnateFrame({
    super.key,
    required this.child,
    this.padding,
    this.radius = 14,
    this.innerRadius,
    this.outerGradient,
    this.panelGradient,
    this.glow = false,
    this.borderWidth = 0.8,
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
    final outer = outerGradient ?? GothicPalette.goldFrameGradient;
    final panel = panelGradient ?? GothicPalette.obsidianPanel;
    final innerR = innerRadius ?? (radius - borderWidth);
    final shadows = glow
        ? [
            ...GothicPalette.emberGlow,
            ...GothicPalette.goldGlow,
          ]
        : const <BoxShadow>[];

    return Container(
      decoration: BoxDecoration(
        gradient: outer,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows,
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(borderWidth),
        child: Container(
          decoration: BoxDecoration(
            gradient: panel,
            borderRadius: BorderRadius.circular(innerR),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class IronInsetFrame extends StatelessWidget {
  const IronInsetFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 12,
    this.borderWidth = 0.8,
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2418),
            Color(0xFF141414),
            Color(0xFF1A1610),
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: activeEmber
              ? GothicPalette.ember.withValues(alpha: 0.5)
              : GothicPalette.goldDeep.withValues(alpha: 0.45),
          width: borderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 4,
            offset: Offset(2, 3),
          ),
          BoxShadow(
            color: Color(0x12FFD700),
            blurRadius: 4,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}

class DetailedHpBar extends StatelessWidget {
  const DetailedHpBar({
    super.key,
    required this.value,
    required this.label,
    this.height = 18,
    this.fillGradient = GothicPalette.emberCore,
  });

  final double value;
  final String label;
  final double height;
  final LinearGradient fillGradient;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return SizedBox(
      height: height + 6,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF3A2B10),
                    Color(0xFF1A1208),
                  ],
                ),
                borderRadius: BorderRadius.circular(height / 2 + 2),
                border: Border.all(color: GothicPalette.goldDeep, width: 0.8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x88000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(2.5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(height / 2),
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF141414),
                            Color(0xFF0A0A0A),
                          ],
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: clamped,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: fillGradient,
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: clamped,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x55FFDCA0),
                              Color(0x00FF6A1A),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (clamped > 0)
                      Positioned(
                        right: 4,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 0.8,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x00FFD700),
                                Color(0xFFFFD700),
                                Color(0x00FFD700),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    color: GothicPalette.parchmentLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.9),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.label, {super.key, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 18,
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x00000000), GothicPalette.goldBright],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: GothicPalette.goldBright,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            shadows: [
              Shadow(
                color: GothicPalette.ember.withValues(alpha: 0.5),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GothicPalette.goldBright,
                  Color(0x00DAA520),
                ],
              ),
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

class OrnamentalDivider extends StatelessWidget {
  const OrnamentalDivider({super.key, this.symbol = '✦', this.height = 24});

  final String symbol;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x00000000),
                    GothicPalette.goldDeep,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              symbol,
              style: TextStyle(
                color: GothicPalette.goldBright,
                fontSize: 12,
                shadows: [
                  Shadow(
                    color: GothicPalette.ember.withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GothicPalette.goldDeep,
                    Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
