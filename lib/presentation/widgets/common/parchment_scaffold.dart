import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';

/// A scaffold wrapper that applies the parchment texture background.
///
/// Use this instead of plain Scaffold to get the ivory cream parchment
/// ground layer (Z-Level 0) of the Parisian Botanical Journal design system.
///
/// Falls back to a solid cream wash color if no texture asset is available.
///
/// Usage:
/// ```dart
/// ParchmentScaffold(
///   appBar: AppBar(title: Text('My Screen')),
///   body: MyContent(),
/// )
/// ```
class ParchmentScaffold extends StatelessWidget {
  const ParchmentScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.drawer,
    this.endDrawer,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.useTexture = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  /// Whether to apply the parchment texture. Set to false for
  /// screens that need a plain background (e.g., map screens).
  final bool useTexture;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      drawer: drawer,
      endDrawer: endDrawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body:
          useTexture
              ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors:
                        isDark
                            ? [AppColors.backgroundDark, AppColors.surfaceDark]
                            : [AppColors.background, AppColors.surfaceAlt.withOpacity(0.5)],
                  ),
                ),
                child: body,
              )
              : body,
    );
  }
}
