import 'package:flutter/material.dart';

/// Identifiers for every theme shipped with SubTrack.
///
/// The [storageKey] is persisted locally and must remain stable so that a
/// user's choice survives app updates.
enum AppThemeId {
  blue('blue'),
  purple('purple'),
  green('green'),
  pink('pink'),
  orange('orange'),
  dark('dark');

  const AppThemeId(this.storageKey);

  /// Stable key used for local persistence (SharedPreferences).
  final String storageKey;

  /// Resolves a persisted key back into a theme id.
  ///
  /// Falls back to [AppThemeId.blue] which is the default theme for new
  /// installations and for users who never picked a theme.
  static AppThemeId fromStorageKey(String? key) {
    if (key == null) return AppThemeId.blue;
    for (final id in AppThemeId.values) {
      if (id.storageKey == key) return id;
    }
    return AppThemeId.blue;
  }
}

/// A complete, self-contained description of one SubTrack theme.
///
/// Every colour used anywhere in the application is derived from a palette so
/// that switching themes updates the whole app in one shot.
@immutable
class AppPalette {
  const AppPalette({
    required this.id,
    required this.name,
    required this.tagline,
    required this.primary,
    required this.secondary,
    required this.deep,
    required this.light,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.border,
    required this.gradientTop,
    required this.gradientMid,
    required this.gradientBottom,
    this.isDark = false,
  });

  /// Theme identity.
  final AppThemeId id;

  /// Human readable theme name shown in Settings.
  final String name;

  /// Short description shown under the theme name in Settings.
  final String tagline;

  /// Main accent colour (buttons, active icons, highlights).
  final Color primary;

  /// Lighter accent used for gradients and secondary highlights.
  final Color secondary;

  /// Darkest accent, used for shadows and pressed states.
  final Color deep;

  /// Very light tint of the accent.
  final Color light;

  /// Page background colour behind the gradient hero.
  final Color background;

  /// Base card / sheet surface colour.
  final Color surface;

  /// Primary text colour.
  final Color textPrimary;

  /// Secondary (muted) text colour.
  final Color textSecondary;

  /// Positive status colour.
  final Color success;

  /// Warning status colour.
  final Color warning;

  /// Destructive / overdue status colour.
  final Color danger;

  /// Border / divider colour.
  final Color border;

  /// Top stop of the screen gradient.
  final Color gradientTop;

  /// Middle stop of the screen gradient.
  final Color gradientMid;

  /// Bottom stop of the screen gradient.
  final Color gradientBottom;

  /// Whether this palette is a dark theme.
  final bool isDark;
}

/// Registry of all available themes.
class AppPalettes {
  AppPalettes._();

  /// Default theme — Blue Gradient.
  static const AppPalette blue = AppPalette(
    id: AppThemeId.blue,
    name: 'Blue Gradient',
    tagline: 'Sky to deep blue',
    primary: Color(0xFF0798D5),
    secondary: Color(0xFF36B8E9),
    deep: Color(0xFF087FBD),
    light: Color(0xFFDDF4FC),
    background: Color(0xFFEAF8FD),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF172B3A),
    textSecondary: Color(0xFF7B8994),
    success: Color(0xFF36A66B),
    warning: Color(0xFFFF8548),
    danger: Color(0xFFE5484D),
    border: Color(0xFFE2EDF2),
    gradientTop: Color(0xFFDFF5FC),
    gradientMid: Color(0xFFA8E2F5),
    gradientBottom: Color(0xFF0798D5),
  );

  /// Purple theme.
  static const AppPalette purple = AppPalette(
    id: AppThemeId.purple,
    name: 'Purple',
    tagline: 'Calm violet tones',
    primary: Color(0xFF6C4BD8),
    secondary: Color(0xFFA78BFA),
    deep: Color(0xFF5534C0),
    light: Color(0xFFEDE7FE),
    background: Color(0xFFF5F2FF),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1E1832),
    textSecondary: Color(0xFF7A7290),
    success: Color(0xFF36A66B),
    warning: Color(0xFFFF8548),
    danger: Color(0xFFE5484D),
    border: Color(0xFFE7E1F8),
    gradientTop: Color(0xFFEFEAFE),
    gradientMid: Color(0xFFC9B8FA),
    gradientBottom: Color(0xFF6C4BD8),
  );

  /// Green theme.
  static const AppPalette green = AppPalette(
    id: AppThemeId.green,
    name: 'Green',
    tagline: 'Fresh and balanced',
    primary: Color(0xFF1B9C74),
    secondary: Color(0xFF4FD1A5),
    deep: Color(0xFF12775A),
    light: Color(0xFFDFF6EE),
    background: Color(0xFFF0FAF6),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF102A22),
    textSecondary: Color(0xFF6F8880),
    success: Color(0xFF2FA36E),
    warning: Color(0xFFFF8548),
    danger: Color(0xFFE5484D),
    border: Color(0xFFD9EEE6),
    gradientTop: Color(0xFFE0F7EF),
    gradientMid: Color(0xFFA6E3CE),
    gradientBottom: Color(0xFF1B9C74),
  );

  /// Pink theme.
  static const AppPalette pink = AppPalette(
    id: AppThemeId.pink,
    name: 'Pink',
    tagline: 'Soft and vibrant',
    primary: Color(0xFFDB3C77),
    secondary: Color(0xFFF98BB3),
    deep: Color(0xFFB32A5E),
    light: Color(0xFFFFE5EF),
    background: Color(0xFFFFF4F8),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF2C1420),
    textSecondary: Color(0xFF8A6C7A),
    success: Color(0xFF36A66B),
    warning: Color(0xFFFF8548),
    danger: Color(0xFFE5484D),
    border: Color(0xFFF7DCE7),
    gradientTop: Color(0xFFFFE8F1),
    gradientMid: Color(0xFFFBBBD4),
    gradientBottom: Color(0xFFDB3C77),
  );

  /// Orange theme.
  static const AppPalette orange = AppPalette(
    id: AppThemeId.orange,
    name: 'Orange',
    tagline: 'Warm and energetic',
    primary: Color(0xFFEF7528),
    secondary: Color(0xFFFFA96B),
    deep: Color(0xFFCC5A15),
    light: Color(0xFFFFEEDF),
    background: Color(0xFFFFF7F1),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF2E1A0E),
    textSecondary: Color(0xFF8A7566),
    success: Color(0xFF36A66B),
    warning: Color(0xFFFF8548),
    danger: Color(0xFFE5484D),
    border: Color(0xFFF7E3D4),
    gradientTop: Color(0xFFFFEFE3),
    gradientMid: Color(0xFFFFCBA4),
    gradientBottom: Color(0xFFEF7528),
  );

  /// Elegant dark theme.
  static const AppPalette dark = AppPalette(
    id: AppThemeId.dark,
    name: 'Elegant Dark',
    tagline: 'Refined midnight',
    primary: Color(0xFF4EA8FF),
    secondary: Color(0xFF86C7FF),
    deep: Color(0xFF2A7FD1),
    light: Color(0xFF1B2A3D),
    background: Color(0xFF0C141E),
    surface: Color(0xFF16202C),
    textPrimary: Color(0xFFE9F1F9),
    textSecondary: Color(0xFF8FA3B8),
    success: Color(0xFF3FCB8E),
    warning: Color(0xFFFF9E64),
    danger: Color(0xFFFF6B6B),
    border: Color(0xFF22303F),
    gradientTop: Color(0xFF12243D),
    gradientMid: Color(0xFF17395F),
    gradientBottom: Color(0xFF0A1420),
    isDark: true,
  );

  /// All themes in display order.
  static const List<AppPalette> all = <AppPalette>[
    blue,
    purple,
    green,
    pink,
    orange,
    dark,
  ];

  /// Looks up the palette for a theme id, defaulting to [blue].
  static AppPalette byId(AppThemeId id) {
    for (final palette in all) {
      if (palette.id == id) return palette;
    }
    return blue;
  }
}
