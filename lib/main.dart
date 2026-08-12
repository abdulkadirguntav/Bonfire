import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bonfire/data/repositories/ash_mark_repository.dart';
import 'package:bonfire/data/repositories/reflection_repository.dart';
import 'package:bonfire/data/repositories/soapstone_repository.dart';
import 'package:bonfire/data/repositories/task_repository.dart';
import 'package:bonfire/data/repositories/user_repository.dart';
import 'package:bonfire/presentation/providers/ash_mark_provider.dart';
import 'package:bonfire/presentation/providers/reflection_provider.dart';
import 'package:bonfire/presentation/providers/soapstone_provider.dart';
import 'package:bonfire/presentation/providers/task_provider.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';
import 'package:bonfire/presentation/screens/death_screen.dart';
import 'package:bonfire/presentation/screens/home_screen.dart';
import 'package:bonfire/presentation/screens/onboarding_screen.dart';
import 'package:bonfire/presentation/screens/reflection_screen.dart';
import 'package:bonfire/presentation/screens/shop_screen.dart';
import 'package:bonfire/presentation/screens/soapstone_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        userRepositoryProvider.overrideWithValue(UserRepository(prefs)),
        taskRepositoryProvider.overrideWithValue(TaskRepository(prefs)),
        ashMarkRepositoryProvider.overrideWithValue(AshMarkRepository(prefs)),
        reflectionRepositoryProvider.overrideWithValue(ReflectionRepository(prefs)),
        soapstoneRepositoryProvider.overrideWithValue(SoapstoneRepository(prefs)),
      ],
      child: const BonfireApp(),
    ),
  );
}

class BonfireApp extends ConsumerStatefulWidget {
  const BonfireApp({super.key});

  @override
  ConsumerState<BonfireApp> createState() => _BonfireAppState();
}

class _BonfireAppState extends ConsumerState<BonfireApp> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userControllerProvider);
    final ashMark = ref.watch(ashMarkControllerProvider);

    if (user == null) {
      return const MaterialApp(
        title: 'Bonfire',
        debugShowCheckedModeBanner: false,
        home: OnboardingScreen(),
      );
    }

    if (user.currentHp <= 0) {
      return MaterialApp(
        title: 'Bonfire',
        debugShowCheckedModeBanner: false,
        home: DeathScreen(
          lostEssence: ashMark?.lostEssence ?? user.totalEssence,
          targetStreak: ashMark?.targetStreak ?? 0,
        ),
      );
    }

    final unlockedSoapstone = user.hasDefeatedFirstBoss;
    final screens = <Widget>[
      const HomeScreen(),
      const ReflectionScreen(),
      const ShopScreen(),
      if (unlockedSoapstone) const SoapstoneScreen(),
    ];

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.auto_stories_outlined),
        selectedIcon: Icon(Icons.auto_stories_rounded),
        label: 'Reflection',
      ),
      const NavigationDestination(
        icon: Icon(Icons.storefront_outlined),
        selectedIcon: Icon(Icons.storefront_rounded),
        label: 'The Kiln',
      ),
      if (unlockedSoapstone)
        const NavigationDestination(
          icon: Icon(Icons.waves_outlined),
          selectedIcon: Icon(Icons.waves_rounded),
          label: 'Soapstone',
        ),
    ];

    return MaterialApp(
      title: 'Bonfire',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0D10),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB89B5B),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          destinations: destinations,
        ),
      ),
    );
  }
}
