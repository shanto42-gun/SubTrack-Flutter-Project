import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/core/constants/supabase_constants.dart';
import 'package:flutter_application_1/core/theme/app_palette.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/core/theme/theme_controller.dart';
import 'package:flutter_application_1/models/user_profile.dart';
import 'package:flutter_application_1/screens/settings/settings_screen.dart';
import 'package:flutter_application_1/services/profile_service.dart';

class _FakeProfileService extends ProfileService {
  _FakeProfileService() : super();

  @override
  Future<UserProfile?> getProfile([String? userId]) async => UserProfile(
    id: 'test-user',
    email: 'test@example.com',
    fullName: 'Test User',
  );

  @override
  Future<UserProfile> upsertProfile(UserProfile profile) async => profile;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      publishableKey: SupabaseConstants.supabasePublishableKey,
    );
  });

  group('Theme palettes', () {
    test('Blue Gradient is the default theme for new installations', () {
      expect(AppThemeId.fromStorageKey(null), AppThemeId.blue);
      expect(AppPalettes.byId(AppThemeId.blue).name, 'Blue Gradient');
      expect(
        AppPalettes.byId(AppThemeId.blue).primary,
        const Color(0xFF0798D5),
      );
    });

    test('all six themes are available', () {
      expect(AppPalettes.all.length, 6);
      expect(AppThemeId.values.map((e) => e.storageKey).toSet(), <String>{
        'blue',
        'purple',
        'green',
        'pink',
        'orange',
        'dark',
      });
    });

    test('an unknown stored key falls back to Blue Gradient', () {
      expect(AppThemeId.fromStorageKey('not-a-theme'), AppThemeId.blue);
    });

    test('every theme builds a consistent ThemeData', () {
      for (final palette in AppPalettes.all) {
        final theme = AppTheme.build(palette);
        expect(theme.colorScheme.primary, palette.primary);
        expect(
          theme.brightness,
          palette.isDark ? Brightness.dark : Brightness.light,
        );
        expect(theme.extension<AppThemeColors>()!.palette.id, palette.id);
        expect(theme.scaffoldBackgroundColor, palette.background);
      }
    });
  });

  group('ThemeController', () {
    test('starts on Blue Gradient when nothing has been saved', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = ThemeController();
      await controller.init();
      expect(controller.themeId, AppThemeId.blue);
    });

    test('saves the selected theme and restores it after a restart', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = ThemeController();
      await controller.init();

      await controller.setTheme(AppThemeId.purple);
      expect(controller.themeId, AppThemeId.purple);
      expect(controller.palette.id, AppThemeId.purple);

      // A fresh controller behaves like a restarted application.
      final restarted = ThemeController();
      await restarted.init();
      expect(restarted.themeId, AppThemeId.purple);
    });

    test('keeps the renewal reminder preference', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = ThemeController();
      await controller.init();
      expect(controller.notificationsEnabled, isTrue);

      await controller.setNotificationsEnabled(false);
      expect(controller.notificationsEnabled, isFalse);

      final restarted = ThemeController();
      await restarted.init();
      expect(restarted.notificationsEnabled, isFalse);
    });
  });

  group('Settings screen appearance section', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await themeController.init();
    });

    testWidgets('lists every theme and switches when one is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        _ThemedApp(
          builder: (context) =>
              SettingsScreen(profileService: _FakeProfileService()),
        ),
      );
      await tester.pumpAndSettle();

      for (final palette in AppPalettes.all) {
        expect(find.text(palette.name), findsWidgets);
      }

      await tester.ensureVisible(find.text('Elegant Dark'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Elegant Dark'));
      await tester.pumpAndSettle();

      expect(themeController.themeId, AppThemeId.dark);
      expect(
        Theme.of(tester.element(find.text('Elegant Dark'))).brightness,
        Brightness.dark,
      );
    });

    testWidgets('applies a theme change across the whole application', (
      tester,
    ) async {
      await tester.pumpWidget(
        _ThemedApp(
          builder: (context) =>
              SettingsScreen(profileService: _FakeProfileService()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Green'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Green'));
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Green'));
      final colors = Theme.of(context).extension<AppThemeColors>()!;
      expect(colors.palette.primary, AppPalettes.green.primary);
      expect(Theme.of(context).colorScheme.primary, AppPalettes.green.primary);
    });
  });
}

/// Mirrors the wiring in `main.dart`: the whole app rebuilds when the
/// selected theme changes.
class _ThemedApp extends StatelessWidget {
  const _ThemedApp({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MaterialApp(
          theme: themeController.theme,
          home: Builder(builder: builder),
        );
      },
    );
  }
}
