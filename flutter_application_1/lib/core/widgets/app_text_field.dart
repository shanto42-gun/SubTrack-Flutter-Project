import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Rounded, themed text field used by every form in the application.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.validator,
    this.autofocus = false,
    this.enabled = true,
    this.maxLines = 1,
    this.style,
    this.textCapitalization = TextCapitalization.none,
  });

  /// Optional controller.
  final TextEditingController? controller;

  /// Floating label.
  final String? label;

  /// Placeholder text.
  final String? hintText;

  /// Leading icon.
  final IconData? prefixIcon;

  /// Trailing widget (e.g. a password visibility toggle).
  final Widget? suffixIcon;

  /// Whether the value is obscured.
  final bool obscureText;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Keyboard action button.
  final TextInputAction? textInputAction;

  /// Called when the keyboard action is submitted.
  final ValueChanged<String>? onFieldSubmitted;

  /// Called on every change.
  final ValueChanged<String>? onChanged;

  /// Form validator.
  final FormFieldValidator<String>? validator;

  /// Whether the field grabs focus automatically.
  final bool autofocus;

  /// Whether the field is editable.
  final bool enabled;

  /// Number of lines.
  final int maxLines;

  /// Text style override.
  final TextStyle? style;

  /// Capitalisation of typed text.
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      validator: validator,
      autofocus: autofocus,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      textCapitalization: textCapitalization,
      style:
          style ??
          TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
        suffixIcon: suffixIcon,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}
