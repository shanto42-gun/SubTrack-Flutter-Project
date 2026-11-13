import 'package:flutter/material.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';

/// The SubTrack brand mark: a rounded gradient tile with the app glyph.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({
    super.key,
    this.size = 48,
    this.iconSize,
    this.elevation = true,
  });

  /// Width and height of the logo tile.
  final double size;

  /// Optional override for the glyph size.
  final double? iconSize;

  /// Whether the tile casts a soft shadow.
  final bool elevation;

  @override
  Widget build(BuildContext context) {
    final palette =
        Theme.of(context).extension<AppThemeColors>()?.palette ??
        AppPalettes.blue;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.secondary, palette.primary, palette.deep],
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: elevation
            ? <BoxShadow>[
                BoxShadow(
                  color: palette.deep.withValues(alpha: 0.32),
                  blurRadius: size * 0.42,
                  offset: Offset(0, size * 0.16),
                ),
              ]
            : null,
      ),
      child: Icon(
        Icons.track_changes_rounded,
        size: iconSize ?? size * 0.52,
        color: Colors.white,
      ),
    );
  }
}

/// Logo mark plus the "SubTrack" wordmark.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 44,
    this.showWordmark = true,
    this.wordmarkColor,
    this.subtitle,
  });

  /// Size of the logo tile.
  final double size;

  /// Whether the wordmark is rendered next to the mark.
  final bool showWordmark;

  /// Optional colour override for the wordmark.
  final Color? wordmarkColor;

  /// Optional small subtitle rendered under the wordmark.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final palette =
        Theme.of(context).extension<AppThemeColors>()?.palette ??
        AppPalettes.blue;
    final mark = AppLogoMark(size: size);

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        mark,
        SizedBox(width: size * 0.26),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'SubTrack',
              style: TextStyle(
                fontSize: size * 0.46,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.9,
                height: 1.05,
                color: wordmarkColor ?? palette.textPrimary,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: size * 0.27,
                  fontWeight: FontWeight.w500,
                  color: palette.textSecondary,
                  height: 1.2,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
