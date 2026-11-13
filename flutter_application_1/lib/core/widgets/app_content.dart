import 'package:flutter/material.dart';

/// Constrains page content to a comfortable reading width and centres it.
///
/// On phones this is a no-op; on tablets and wide web windows it keeps
/// cards from stretching across the whole viewport.
class AppContent extends StatelessWidget {
  const AppContent({
    super.key,
    required this.child,
    this.maxWidth = 680,
    this.heightFactor,
  });

  /// The content to constrain.
  final Widget child;

  /// Maximum width of the content column.
  final double maxWidth;

  /// Optional height factor. Use `1` when the widget must not expand
  /// vertically (for example inside `Scaffold.bottomNavigationBar`).
  final double? heightFactor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      heightFactor: heightFactor,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
