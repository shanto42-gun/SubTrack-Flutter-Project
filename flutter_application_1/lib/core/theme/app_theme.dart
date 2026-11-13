import 'package:flutter/material.dart';
import 'app_palette.dart';

/// Semantic colours that are not part of Material's [ColorScheme].
///
/// Exposed through `Theme.of(context).extension<AppThemeColors>()` and the
/// [AppThemeContext] helper so every widget draws from one source of truth.
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({required this.palette});

  /// The palette backing this theme.
  final AppPalette palette;

  bool get isDark => palette.isDark;

  /// Translucent white (or frosted dark) card surface.
  Color get card => palette.isDark
      ? palette.surface.withValues(alpha: 0.92)
      : Colors.white.withValues(alpha: 0.93);

  /// Opaque card surface, used where translucency would hurt legibility.
  Color get cardSolid => palette.surface;

  /// Slightly tinted surface used for icon tiles and inner panels.
  Color get mutedSurface => palette.isDark
      ? const Color(0xFF1C2836)
      : palette.light.withValues(alpha: 0.55);

  /// Hairline separator colour.
  Color get divider => palette.isDark
      ? palette.border.withValues(alpha: 0.8)
      : const Color(0xFFEDF3F7);

  /// Muted text colour.
  Color get textSecondary => palette.textSecondary;

  /// Primary text colour.
  Color get textPrimary => palette.textPrimary;

  /// Positive status colour.
  Color get success => palette.success;

  /// Warning status colour.
  Color get warning => palette.warning;

  /// Destructive status colour.
  Color get danger => palette.danger;

  /// Soft, coloured shadow used by floating surfaces.
  List<BoxShadow> get cardShadow => <BoxShadow>[
    BoxShadow(
      color: palette.deep.withValues(alpha: palette.isDark ? 0.40 : 0.13),
      blurRadius: 26,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: palette.deep.withValues(alpha: palette.isDark ? 0.22 : 0.06),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  /// Shadow used by small elevated chips / badges.
  List<BoxShadow> get softShadow => <BoxShadow>[
    BoxShadow(
      color: palette.deep.withValues(alpha: palette.isDark ? 0.32 : 0.10),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  @override
  AppThemeColors copyWith({AppPalette? palette}) {
    return AppThemeColors(palette: palette ?? this.palette);
  }

  @override
  AppThemeColors lerp(covariant AppThemeColors? other, double t) {
    if (other == null) return this;
    return t < 0.5 ? this : other;
  }
}

/// Convenience accessors for themed colours.
extension AppThemeContext on BuildContext {
  /// Semantic theme colours for the active palette.
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ??
      const AppThemeColors(palette: AppPalettes.blue);

  /// The active palette.
  AppPalette get palette => appColors.palette;
}

/// Builds Material [ThemeData] instances from an [AppPalette].
class AppTheme {
  AppTheme._();

  /// Corner radius used by cards.
  static const double cardRadius = 22;

  /// Corner radius used by inputs and buttons.
  static const double controlRadius = 16;

  /// Builds the full theme for the given palette.
  static ThemeData build(AppPalette p) {
    final brightness = p.isDark ? Brightness.dark : Brightness.light;

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: p.primary,
          brightness: brightness,
        ).copyWith(
          primary: p.primary,
          onPrimary: p.isDark ? const Color(0xFF06121F) : Colors.white,
          secondary: p.secondary,
          onSecondary: p.isDark ? const Color(0xFF06121F) : Colors.white,
          surface: p.surface,
          onSurface: p.textPrimary,
          error: p.danger,
          onError: Colors.white,
          outline: p.border,
          outlineVariant: p.border,
        );

    final inputFill = p.isDark ? const Color(0xFF1B2836) : Colors.white;
    final inputBorder = p.isDark ? p.border : const Color(0xFFDCE7EE);

    // Platform typography is used as the base so every style keeps the
    // platform font family (Roboto on Android and web).
    final base = Typography.material2021().black;
    final textTheme = _textTheme(p, base);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      extensions: <ThemeExtension<dynamic>>[AppThemeColors(palette: p)],
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: p.isDark
            ? p.border.withValues(alpha: 0.8)
            : const Color(0xFFEDF3F7),
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: p.textSecondary, size: 22),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: base.bodyMedium!.copyWith(
          color: p.textSecondary.withValues(alpha: 0.85),
          fontSize: 14,
        ),
        labelStyle: base.bodyMedium!.copyWith(
          color: p.textSecondary,
          fontSize: 14,
        ),
        floatingLabelStyle: base.bodyMedium!.copyWith(
          color: p.primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: p.textSecondary,
        suffixIconColor: p.textSecondary,
        errorStyle: base.bodySmall!.copyWith(
          color: p.danger,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: p.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: p.danger.withValues(alpha: 0.8)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: p.danger, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.isDark ? const Color(0xFF06121F) : Colors.white,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          textStyle: base.labelLarge!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.isDark ? const Color(0xFF06121F) : Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          textStyle: base.labelLarge!.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.textPrimary,
          minimumSize: const Size.fromHeight(50),
          side: BorderSide(color: inputBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          textStyle: base.labelLarge!.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          textStyle: base.labelLarge!.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: p.textPrimary,
        centerTitle: false,
        titleTextStyle: base.titleLarge!.copyWith(
          color: p.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.isDark ? p.surface : Colors.white,
        elevation: 0,
        height: 68,
        indicatorColor: p.primary.withValues(alpha: p.isDark ? 0.24 : 0.14),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return base.labelMedium!.copyWith(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? p.primary : p.textSecondary,
            letterSpacing: -0.1,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: isSelected ? p.primary : p.textSecondary,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: base.titleLarge!.copyWith(
          color: p.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        contentTextStyle: base.bodyMedium!.copyWith(
          color: p.textSecondary,
          fontSize: 14,
          height: 1.45,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: p.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: base.bodyMedium!.copyWith(
          color: p.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.isDark
            ? const Color(0xFF223244)
            : const Color(0xFF172B3A),
        contentTextStyle: base.bodyMedium!.copyWith(
          color: Colors.white,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        insetPadding: const EdgeInsets.all(16),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return p.isDark ? const Color(0xFF8FA3B8) : const Color(0xFFCBD8E0);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.primary;
          return p.isDark ? const Color(0xFF2A3A4C) : const Color(0xFFE3ECF1);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return inputBorder;
        }),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.textSecondary,
        titleTextStyle: base.bodyLarge!.copyWith(
          color: p.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: base.bodySmall!.copyWith(
          color: p.textSecondary,
          fontSize: 12,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.isDark ? const Color(0xFF223244) : const Color(0xFF172B3A),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: base.bodySmall!.copyWith(color: Colors.white, fontSize: 12),
      ),
    );
  }

  static TextTheme _textTheme(AppPalette p, TextTheme base) {
    TextStyle style(
      TextStyle? from,
      double size,
      FontWeight weight,
      Color color, {
      double letterSpacing = 0,
      double? height,
    }) {
      return (from ?? const TextStyle()).copyWith(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        color: color,
        height: height,
      );
    }

    return base.copyWith(
      displaySmall: style(
        base.displaySmall,
        36,
        FontWeight.w800,
        p.textPrimary,
        letterSpacing: -1.2,
        height: 1.1,
      ),
      headlineMedium: style(
        base.headlineMedium,
        27,
        FontWeight.w800,
        p.textPrimary,
        letterSpacing: -0.7,
        height: 1.2,
      ),
      headlineSmall: style(
        base.headlineSmall,
        22,
        FontWeight.w700,
        p.textPrimary,
        letterSpacing: -0.5,
      ),
      titleLarge: style(
        base.titleLarge,
        19,
        FontWeight.w700,
        p.textPrimary,
        letterSpacing: -0.4,
      ),
      titleMedium: style(
        base.titleMedium,
        16,
        FontWeight.w700,
        p.textPrimary,
        letterSpacing: -0.2,
      ),
      titleSmall: style(base.titleSmall, 14, FontWeight.w600, p.textPrimary),
      bodyLarge: style(
        base.bodyLarge,
        15,
        FontWeight.w400,
        p.textPrimary,
        height: 1.45,
      ),
      bodyMedium: style(
        base.bodyMedium,
        13.5,
        FontWeight.w400,
        p.textSecondary,
        height: 1.45,
      ),
      bodySmall: style(
        base.bodySmall,
        12,
        FontWeight.w400,
        p.textSecondary,
        height: 1.4,
      ),
      labelLarge: style(base.labelLarge, 14, FontWeight.w600, p.textPrimary),
      labelMedium: style(
        base.labelMedium,
        12,
        FontWeight.w600,
        p.textSecondary,
      ),
      labelSmall: style(
        base.labelSmall,
        11,
        FontWeight.w700,
        p.textSecondary,
        letterSpacing: 0.9,
      ),
    );
  }
}
