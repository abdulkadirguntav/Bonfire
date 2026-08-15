import 'package:flutter/material.dart';

import 'package:bonfire/core/constants/daily_quotes.dart';
import 'package:bonfire/core/theme/gothic_theme.dart';
import 'package:bonfire/core/widgets/ornate_widgets.dart';

/// UI counterpart of the Phase 1 philosophical home-screen widget.
/// Native launcher registration is platform-specific and can consume the same
/// [dailyQuotes] source when an Android/iOS widget extension is added.
class PhilosophicalMotivationWidget extends StatelessWidget {
  const PhilosophicalMotivationWidget({super.key, this.date});
  final DateTime? date;

  @override
  Widget build(BuildContext context) => OrnateFrame(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '“${quoteForDate(date ?? DateTime.now())}”',
            style: const TextStyle(
                color: GothicPalette.parchmentLight,
                height: 1.45,
                fontStyle: FontStyle.italic),
          ),
        ),
      );
}
