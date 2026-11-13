import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// How the theme gradient is painted behind the content.
enum AppGradientStyle {
  /// Full bleed gradient covering the whole screen (auth screens, splash).
  full,

  /// Gradient hero at the top that fades into the page background.
  hero,
}

/// Paints the themed gradient background used across the application.
class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({
    super.key,
    required this.child,
    this.style = AppGradientStyle.hero,
  });

  /// Content painted on top of the gradient.
  final Widget child;

  /// Gradient treatment to apply.
  final AppGradientStyle style;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final gradient = switch (style) {
      AppGradientStyle.full => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          palette.gradientTop,
          palette.gradientMid,
          palette.gradientBottom,
        ],
        stops: const <double>[0.0, 0.42, 1.0],
      ),
      AppGradientStyle.hero => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          palette.gradientTop,
          palette.gradientMid,
          palette.gradientBottom,
          Color.lerp(palette.gradientBottom, palette.background, 0.35)!,
          Color.lerp(palette.gradientBottom, palette.background, 0.70)!,
          palette.background,
        ],
        stops: const <double>[0.0, 0.08, 0.20, 0.29, 0.40, 0.54],
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}

/// Adds a soft radial glow of the accent colour (used behind hero headers).
class AppGlow extends StatelessWidget {
  const AppGlow({
    super.key,
    required this.child,
    this.alignment = const Alignment(-0.7, -0.9),
    this.radius = 0.9,
    this.opacity = 0.35,
  });

  /// Content painted on top of the glow.
  final Widget child;

  /// Where the glow is centred.
  final Alignment alignment;

  /// Relative radius of the glow.
  final double radius;

  /// Peak opacity of the glow.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: alignment,
                radius: radius,
                colors: <Color>[
                  Colors.white.withValues(
                    alpha: palette.isDark ? opacity * 0.35 : opacity,
                  ),
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
