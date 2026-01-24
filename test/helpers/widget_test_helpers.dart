import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps a widget with necessary providers and material app for testing.
///
/// Example:
/// ```dart
/// await tester.pumpWidget(
///   wrapWithProviders(
///     const MyWidget(),
///     overrides: [someProvider.overrideWithValue(mockValue)],
///   ),
/// );
/// ```
Widget wrapWithProviders(
  Widget child, {
  List<Override> overrides = const [],
  NavigatorObserver? navigatorObserver,
  ThemeData? theme,
  Locale? locale,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
      theme: theme ?? ThemeData.light(),
      locale: locale,
      navigatorObservers: [
        if (navigatorObserver != null) navigatorObserver,
      ],
    ),
  );
}

/// Wraps a widget with a Scaffold for testing widgets that require one.
Widget wrapWithScaffold(
  Widget child, {
  List<Override> overrides = const [],
  ThemeData? theme,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
      theme: theme ?? ThemeData.light(),
    ),
  );
}

/// Wraps a widget for testing in a constrained box.
Widget wrapWithConstraints(
  Widget child, {
  List<Override> overrides = const [],
  double width = 400,
  double height = 800,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            height: height,
            child: child,
          ),
        ),
      ),
    ),
  );
}

/// Extension methods for WidgetTester to simplify common operations.
extension WidgetTesterExtensions on WidgetTester {
  /// Pumps the widget and waits for animations to settle.
  Future<void> pumpAndSettle2({
    Duration duration = const Duration(milliseconds: 100),
  }) async {
    await pumpAndSettle(duration);
  }

  /// Enters text into a TextField and pumps.
  Future<void> enterTextAndPump(Finder finder, String text) async {
    await enterText(finder, text);
    await pump();
  }

  /// Taps a widget and pumps.
  Future<void> tapAndPump(Finder finder) async {
    await tap(finder);
    await pump();
  }

  /// Taps a widget and waits for animations.
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  /// Scrolls until a widget is visible.
  Future<void> scrollUntilVisible(
    Finder finder, {
    Finder? scrollable,
    double delta = 100.0,
  }) async {
    final scrollableFinder = scrollable ?? find.byType(Scrollable).first;
    while (!any(finder)) {
      await drag(scrollableFinder, Offset(0, -delta));
      await pump();
    }
  }

  /// Finds a widget by key string.
  Finder findByKeyString(String key) {
    return find.byKey(Key(key));
  }
}

/// Common finder helpers for testing.
class TestFinders {
  /// Finds all buttons with the given text.
  static Finder buttonWithText(String text) {
    return find.widgetWithText(ElevatedButton, text);
  }

  /// Finds all TextButtons with the given text.
  static Finder textButtonWithText(String text) {
    return find.widgetWithText(TextButton, text);
  }

  /// Finds all text fields.
  static Finder textFields() {
    return find.byType(TextField);
  }

  /// Finds text field by hint text.
  static Finder textFieldWithHint(String hint) {
    return find.widgetWithText(TextField, hint);
  }

  /// Finds all icons.
  static Finder icon(IconData icon) {
    return find.byIcon(icon);
  }

  /// Finds all circular progress indicators.
  static Finder loadingIndicator() {
    return find.byType(CircularProgressIndicator);
  }

  /// Finds snackbar with text.
  static Finder snackBarWithText(String text) {
    return find.descendant(
      of: find.byType(SnackBar),
      matching: find.text(text),
    );
  }

  /// Finds dialogs.
  static Finder dialog() {
    return find.byType(AlertDialog);
  }

  /// Finds list tiles.
  static Finder listTiles() {
    return find.byType(ListTile);
  }

  /// Finds list tile with title.
  static Finder listTileWithTitle(String title) {
    return find.widgetWithText(ListTile, title);
  }
}

/// A fake navigator observer for testing navigation.
class TestNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  final List<Route<dynamic>> poppedRoutes = [];
  final List<Route<dynamic>> replacedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) replacedRoutes.add(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void clear() {
    pushedRoutes.clear();
    poppedRoutes.clear();
    replacedRoutes.clear();
  }
}

/// Matcher for testing widget properties.
class WidgetMatchers {
  /// Matches if a widget is enabled.
  static Matcher isEnabled() {
    return const _IsEnabledMatcher(true);
  }

  /// Matches if a widget is disabled.
  static Matcher isDisabled() {
    return const _IsEnabledMatcher(false);
  }

  /// Matches if a Text widget has the expected style.
  static Matcher hasTextStyle({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return _HasTextStyleMatcher(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }
}

class _IsEnabledMatcher extends Matcher {
  final bool expectedEnabled;

  const _IsEnabledMatcher(this.expectedEnabled);

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is ElevatedButton) {
      return (item.onPressed != null) == expectedEnabled;
    }
    if (item is TextButton) {
      return (item.onPressed != null) == expectedEnabled;
    }
    if (item is IconButton) {
      return (item.onPressed != null) == expectedEnabled;
    }
    return false;
  }

  @override
  Description describe(Description description) {
    return description.add(expectedEnabled ? 'is enabled' : 'is disabled');
  }
}

class _HasTextStyleMatcher extends Matcher {
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  const _HasTextStyleMatcher({
    this.color,
    this.fontSize,
    this.fontWeight,
  });

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is Text) {
      final style = item.style;
      if (style == null) return false;
      if (color != null && style.color != color) return false;
      if (fontSize != null && style.fontSize != fontSize) return false;
      if (fontWeight != null && style.fontWeight != fontWeight) return false;
      return true;
    }
    return false;
  }

  @override
  Description describe(Description description) {
    final parts = <String>[];
    if (color != null) parts.add('color: $color');
    if (fontSize != null) parts.add('fontSize: $fontSize');
    if (fontWeight != null) parts.add('fontWeight: $fontWeight');
    return description.add('has text style with ${parts.join(', ')}');
  }
}

/// Helper for testing async operations with timeouts.
Future<T> expectAsync<T>(
  Future<T> future, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  return await future.timeout(timeout);
}

/// Creates a mock callback that can be used to verify calls.
class MockCallback<T> {
  final List<T> calls = [];
  int get callCount => calls.length;

  void call([T? value]) {
    if (value != null) {
      calls.add(value);
    }
  }

  void reset() {
    calls.clear();
  }

  bool get wasCalled => calls.isNotEmpty;
  bool get wasNotCalled => calls.isEmpty;
  bool calledWith(T value) => calls.contains(value);
}

/// Creates a mock VoidCallback for testing.
class MockVoidCallback {
  int _callCount = 0;
  int get callCount => _callCount;

  void call() {
    _callCount++;
  }

  void reset() {
    _callCount = 0;
  }

  bool get wasCalled => _callCount > 0;
  bool get wasNotCalled => _callCount == 0;
}
