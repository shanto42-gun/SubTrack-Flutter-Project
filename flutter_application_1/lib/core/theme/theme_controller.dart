import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_palette.dart';
import 'app_theme.dart';

/// Central theme manager for the whole application.
///
/// The selected theme is stored locally with SharedPreferences so it survives
/// app restarts, sign-out / sign-in and navigation between screens.
class ThemeController extends ChangeNotifier {
  static const String _keyThemeId = 'app_theme_id';
  static const String _keyNotifications = 'app_notifications_enabled';

  AppThemeId _themeId = AppThemeId.blue;
  bool _notificationsEnabled = true;

  /// The currently selected theme id.
  AppThemeId get themeId => _themeId;

  /// The palette backing the currently selected theme.
  AppPalette get palette => AppPalettes.byId(_themeId);

  /// The [ThemeData] for the currently selected theme.
  ThemeData get theme => AppTheme.build(palette);

  /// Whether renewal reminders are enabled (persisted setting).
  bool get notificationsEnabled => _notificationsEnabled;

  /// All available palettes, in display order.
  static List<AppPalette> get palettes => AppPalettes.all;

  /// Loads the persisted preferences. Falls back to the Blue Gradient theme.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _themeId = AppThemeId.fromStorageKey(prefs.getString(_keyThemeId));
    _notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
    notifyListeners();
  }

  /// Selects a theme, refreshes the app and persists the choice.
  Future<void> setTheme(AppThemeId id) async {
    if (_themeId == id) return;
    _themeId = id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeId, id.storageKey);
  }

  /// Selects a theme by palette.
  Future<void> setPalette(AppPalette palette) => setTheme(palette.id);

  /// Enables or disables renewal reminders (persisted setting).
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) return;
    _notificationsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, enabled);
  }
}

/// Application-wide theme controller instance.
final ThemeController themeController = ThemeController();
