import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Translucent, rounded surface used for every card in the application.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius,
    this.color,
    this.onTap,
    this.onLongPress,
    this.onHighlightChanged,
    this.borderColor,
    this.shadow,
  });

  /// Card content.
  final Widget child;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  /// Optional corner radius override.
  final double? radius;

  /// Optional surface colour override.
  final Color? color;

  /// Optional tap handler (turns the card into a tappable surface).
  final VoidCallback? onTap;

  /// Optional long-press handler.
  final VoidCallback? onLongPress;

  /// Reports highlight (press) state changes.
  final ValueChanged<bool>? onHighlightChanged;

  /// Optional border colour override.
  final Color? borderColor;

  /// Optional shadow override.
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final borderRadius = BorderRadius.circular(radius ?? AppTheme.cardRadius);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor ?? colors.palette.border.withValues(alpha: 0.9),
        ),
        boxShadow: shadow ?? colors.cardShadow,
      ),
      child: Material(
        color: color ?? colors.card,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          onHighlightChanged: onHighlightChanged,
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Uppercase section label used to group settings and dashboard sections.
class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.only(left: 4, bottom: 10),
  });

  /// Label text.
  final String text;

  /// Padding around the label.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: padding,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}

/// Small rounded badge used for counts and statuses.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.showDot = false,
  });

  /// Badge text.
  final String label;

  /// Accent colour.
  final Color color;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether a small dot is rendered before the label.
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showDot) ...<Widget>[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...<Widget>[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded, translucent message banner (errors / success notices).
class AppMessageBanner extends StatelessWidget {
  const AppMessageBanner({
    super.key,
    required this.message,
    required this.color,
    this.icon = Icons.error_outline_rounded,
  });

  /// Message text.
  final String message;

  /// Accent / border colour.
  final Color color;

  /// Leading icon.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
