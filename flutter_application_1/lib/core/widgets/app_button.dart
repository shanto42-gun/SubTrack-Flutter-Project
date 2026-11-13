import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Primary call-to-action button with a themed gradient fill.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 54,
    this.expand = true,
  });

  /// Button label.
  final String label;

  /// Tap handler. `null` disables the button.
  final VoidCallback? onPressed;

  /// Whether a loading spinner is shown instead of the label.
  final bool isLoading;

  /// Optional leading icon.
  final IconData? icon;

  /// Button height.
  final double height;

  /// Whether the button fills the available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDisabled = onPressed == null || isLoading;
    final foreground = palette.isDark ? const Color(0xFF06121F) : Colors.white;

    final content = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 19),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          );

    final button = Opacity(
      opacity: isDisabled ? 0.7 : 1,
      child: Container(
        height: height,
        width: expand ? double.infinity : null,
        padding: expand
            ? null
            : const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[palette.secondary, palette.primary, palette.deep],
          ),
          borderRadius: BorderRadius.circular(AppTheme.controlRadius),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: palette.primary.withValues(alpha: 0.36),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: foreground, size: 20),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: foreground),
            child: content,
          ),
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.controlRadius),
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(AppTheme.controlRadius),
        child: button,
      ),
    );
  }
}

/// Secondary outlined button used for less prominent actions.
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.height = 52,
    this.expand = true,
    this.foregroundColor,
  });

  /// Button label.
  final String label;

  /// Tap handler.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;

  /// Button height.
  final double height;

  /// Whether the button fills the available width.
  final bool expand;

  /// Optional foreground colour override.
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = foregroundColor ?? colors.textPrimary;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: foreground,
          ),
        ),
      ],
    );

    return SizedBox(
      height: height,
      width: expand ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          padding: EdgeInsets.symmetric(
            horizontal: expand ? 16 : 22,
            vertical: 14,
          ),
          side: BorderSide(
            color: foregroundColor != null
                ? foregroundColor!.withValues(alpha: 0.4)
                : colors.palette.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.controlRadius),
          ),
        ),
        child: content,
      ),
    );
  }
}

/// Small circular icon button used in headers.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 42,
    this.iconSize = 20,
    this.backgroundColor,
    this.foregroundColor,
    this.bordered = true,
  });

  /// Icon to render.
  final IconData icon;

  /// Tap handler.
  final VoidCallback? onPressed;

  /// Optional tooltip.
  final String? tooltip;

  /// Diameter of the button.
  final double size;

  /// Size of the icon.
  final double iconSize;

  /// Optional background override.
  final Color? backgroundColor;

  /// Optional foreground override.
  final Color? foregroundColor;

  /// Whether a subtle border is drawn.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = foregroundColor ?? colors.textPrimary;

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: backgroundColor ?? colors.card,
        shape: CircleBorder(
          side: bordered
              ? BorderSide(color: colors.palette.border.withValues(alpha: 0.8))
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: iconSize, color: foreground),
          ),
        ),
      ),
    );
  }
}
