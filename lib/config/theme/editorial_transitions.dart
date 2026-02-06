import 'package:flutter/material.dart';

/// Parisian Botanical Journal Motion Design
///
/// Gentle, organic transitions — upward fades, staggered card entries,
/// and smooth easing. Every animation respects reduced motion.
///
/// Page transitions:
/// - [botanicalFadeUpTransitionBuilder] — gentle upward fade (translateY 12→0, 500ms)
/// - [GlassPaneRoute] — glass slides up with blur ramp (modals)
///
/// Micro-interactions:
/// - [EditorialAnimations.pressInto] — subtle scale + shadow lift for card taps
/// - [EditorialAnimations.staggeredFadeUp] — list item entrance with 100ms delay
class EditorialTransitions {
  EditorialTransitions._();

  /// Standard page transition duration — gentle, unhurried
  static const Duration pageDuration = Duration(milliseconds: 500);

  /// Modal transition duration
  static const Duration modalDuration = Duration(milliseconds: 350);

  /// Interactive element transition duration
  static const Duration interactiveDuration = Duration(milliseconds: 300);

  /// Micro-interaction duration
  static const Duration microDuration = Duration(milliseconds: 100);

  /// Standard page curve — gentle ease-out for organic feel
  static const Curve pageCurve = Curves.easeOutQuart;

  /// Modal appear curve
  static const Curve modalAppearCurve = Curves.easeOutQuart;

  /// Modal dismiss curve
  static const Curve modalDismissCurve = Curves.easeInQuart;

  /// Interactive element curve (hover, press, color changes)
  static const Curve interactiveCurve = Curves.easeInOut;
}

/// Gentle upward fade page transition builder for go_router.
///
/// Translates from 12px below to 0 with a fade-in over 500ms.
/// Feels organic and unhurried, like turning a page in a botanical journal.
///
/// Usage with go_router:
/// ```dart
/// GoRoute(
///   path: '/detail',
///   pageBuilder: (context, state) => CustomTransitionPage(
///     key: state.pageKey,
///     child: DetailScreen(),
///     transitionsBuilder: botanicalFadeUpTransitionBuilder,
///     transitionDuration: EditorialTransitions.pageDuration,
///   ),
/// )
/// ```
Widget botanicalFadeUpTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  // Respect reduced motion
  if (MediaQuery.of(context).disableAnimations) {
    return FadeTransition(opacity: animation, child: child);
  }

  final slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0.03), // ~12px upward at typical screen height
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: animation, curve: EditorialTransitions.pageCurve));

  final fadeAnimation = CurvedAnimation(
    parent: animation,
    curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
  );

  return FadeTransition(
    opacity: fadeAnimation,
    child: SlideTransition(position: slideAnimation, child: child),
  );
}

/// Legacy alias for backward compatibility
Widget paperFlipTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) => botanicalFadeUpTransitionBuilder(context, animation, secondaryAnimation, child);

/// Glass pane modal transition — slides up with blur ramp.
///
/// Usage:
/// ```dart
/// Navigator.push(context, GlassPaneRoute(
///   builder: (context) => MyModal(),
/// ));
/// ```
class GlassPaneRoute<T> extends PageRoute<T> {
  GlassPaneRoute({required this.builder, super.settings});

  final WidgetBuilder builder;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  String? get barrierLabel => null;

  @override
  bool get barrierDismissible => true;

  @override
  bool get opaque => false;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => EditorialTransitions.modalDuration;

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.of(context).disableAnimations) {
      return FadeTransition(opacity: animation, child: child);
    }

    final slideAnimation = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: animation,
        curve: EditorialTransitions.modalAppearCurve,
        reverseCurve: EditorialTransitions.modalDismissCurve,
      ),
    );

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(position: slideAnimation, child: child),
    );
  }
}

/// Pre-built animation helpers for micro-interactions.
class EditorialAnimations {
  EditorialAnimations._();

  /// "Press into parchment" — subtle scale down on tap.
  /// Use with GestureDetector + AnimatedScale.
  ///
  /// ```dart
  /// AnimatedScale(
  ///   scale: isPressed ? EditorialAnimations.pressedScale : 1.0,
  ///   duration: EditorialAnimations.pressDuration,
  ///   curve: EditorialAnimations.pressCurve,
  ///   child: myCard,
  /// )
  /// ```
  static const double pressedScale = 0.97;
  static const Duration pressDuration = Duration(milliseconds: 100);
  static const Curve pressCurve = Curves.easeIn;

  /// Staggered fade-up delay per item in a list (100ms increments).
  static const Duration staggerDelay = Duration(milliseconds: 100);

  /// Staggered fade-up duration per item.
  static const Duration staggerDuration = Duration(milliseconds: 400);

  /// Staggered fade-up curve — gentle ease-out.
  static const Curve staggerCurve = Curves.easeOutQuart;

  /// Calculate stagger delay for a given index.
  static Duration staggerDelayFor(int index) => Duration(milliseconds: 100 * index);

  /// Ink bleed reveal duration.
  static const Duration inkBleedDuration = Duration(milliseconds: 500);

  /// Ink bleed reveal curve.
  static const Curve inkBleedCurve = Curves.easeOut;
}
