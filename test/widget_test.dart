import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bonfire/data/repositories/user_repository.dart';
import 'package:bonfire/main.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts on onboarding when no saved user exists', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(UserRepository(prefs)),
        ],
        child: const BonfireApp(),
      ),
    );

    expect(find.text('Choose your path'), findsOneWidget);
    expect(find.text('Yolculuğa Başla'), findsOneWidget);
  });
}
