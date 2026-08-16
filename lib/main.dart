import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bonfire/core/constants/daily_quotes.dart';
import 'package:bonfire/core/theme/gothic_theme.dart';
import 'package:bonfire/data/repositories/ash_mark_repository.dart';
import 'package:bonfire/data/repositories/boss_repository.dart';
import 'package:bonfire/data/repositories/reflection_repository.dart';
import 'package:bonfire/data/repositories/soapstone_repository.dart';
import 'package:bonfire/data/repositories/task_repository.dart';
import 'package:bonfire/data/repositories/user_repository.dart';
import 'package:bonfire/home_widget/daily_quote_widget.dart';
import 'package:bonfire/presentation/providers/ash_mark_provider.dart';
import 'package:bonfire/presentation/providers/boss_provider.dart';
import 'package:bonfire/presentation/providers/reflection_provider.dart';
import 'package:bonfire/presentation/providers/soapstone_provider.dart';
import 'package:bonfire/presentation/providers/task_provider.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';
import 'package:bonfire/presentation/screens/death_screen.dart';
import 'package:bonfire/presentation/screens/home_screen.dart';
import 'package:bonfire/presentation/screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  try {
    await saveDailyQuoteToWidget(quoteForDate(DateTime.now()));
  } catch (_) {
    // If widget communication fails, the app still launches normally.
  }

  runApp(
    ProviderScope(
      overrides: [
        userRepositoryProvider.overrideWithValue(UserRepository(prefs)),
        taskRepositoryProvider.overrideWithValue(TaskRepository(prefs)),
        ashMarkRepositoryProvider.overrideWithValue(AshMarkRepository(prefs)),
        bossRepositoryProvider.overrideWithValue(BossRepository(prefs)),
        reflectionRepositoryProvider
            .overrideWithValue(ReflectionRepository(prefs)),
        soapstoneRepositoryProvider
            .overrideWithValue(SoapstoneRepository(prefs)),
      ],
      child: const BonfireApp(),
    ),
  );
}

class BonfireApp extends ConsumerWidget {
  const BonfireApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final ashMark = ref.watch(ashMarkControllerProvider);
    final theme = GothicTheme.build();

    if (user == null) {
      return MaterialApp(
        title: 'Bonfire',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const OnboardingScreen(),
      );
    }

    if (user.currentHp <= 0) {
      return MaterialApp(
        title: 'Bonfire',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: DeathScreen(
          lostEssence: ashMark?.lostEssence ?? user.essence,
          targetStreak: ashMark?.targetStreak ?? user.currentStreak,
        ),
      );
    }

    return MaterialApp(
      title: 'Bonfire',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const HomeScreen(),
    );
  }
}
