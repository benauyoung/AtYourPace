import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Creates a test ProviderContainer with optional overrides.
///
/// Use this to test providers in isolation with mocked dependencies.
///
/// Example:
/// ```dart
/// final container = createTestContainer(
///   overrides: [
///     firebaseAuthProvider.overrideWithValue(mockAuth),
///     firestoreProvider.overrideWithValue(mockFirestore),
///   ],
/// );
///
/// final result = await container.read(someProvider.future);
/// ```
ProviderContainer createTestContainer({
  List<Override> overrides = const [],
  ProviderContainer? parent,
  List<ProviderObserver>? observers,
}) {
  return ProviderContainer(
    overrides: overrides,
    parent: parent,
    observers: observers,
  );
}

/// A simple ProviderObserver for testing that tracks provider changes.
///
/// Useful for verifying that providers are being updated correctly.
///
/// Example:
/// ```dart
/// final observer = TestProviderObserver();
/// final container = createTestContainer(observers: [observer]);
///
/// // ... perform actions
///
/// expect(observer.updates, contains(someProvider));
/// ```
class TestProviderObserver extends ProviderObserver {
  final List<ProviderBase> updates = [];
  final List<ProviderBase> disposes = [];
  final List<({ProviderBase provider, Object error, StackTrace stackTrace})> errors = [];

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    updates.add(provider);
  }

  @override
  void didDisposeProvider(ProviderBase provider, ProviderContainer container) {
    disposes.add(provider);
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    errors.add((provider: provider, error: error, stackTrace: stackTrace));
  }

  /// Clears all tracked events.
  void clear() {
    updates.clear();
    disposes.clear();
    errors.clear();
  }

  /// Returns true if the given provider was updated.
  bool wasUpdated(ProviderBase provider) => updates.contains(provider);

  /// Returns true if the given provider was disposed.
  bool wasDisposed(ProviderBase provider) => disposes.contains(provider);

  /// Returns true if the given provider failed with an error.
  bool didFail(ProviderBase provider) => errors.any((e) => e.provider == provider);
}

/// Helper to wait for a provider to complete and return its value.
///
/// Throws if the provider fails or times out.
///
/// Example:
/// ```dart
/// final result = await waitForProvider(container, myFutureProvider);
/// expect(result, equals(expectedValue));
/// ```
Future<T> waitForProvider<T>(
  ProviderContainer container,
  ProviderListenable<AsyncValue<T>> provider, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final completer = Completer<T>();

  final subscription = container.listen<AsyncValue<T>>(
    provider,
    (previous, next) {
      next.when(
        data: (value) {
          if (!completer.isCompleted) {
            completer.complete(value);
          }
        },
        loading: () {},
        error: (error, stack) {
          if (!completer.isCompleted) {
            completer.completeError(error, stack);
          }
        },
      );
    },
  );

  try {
    return await completer.future.timeout(timeout);
  } finally {
    subscription.close();
  }
}

/// Helper to read a provider synchronously and throw on error.
///
/// Example:
/// ```dart
/// final value = readProvider(container, myProvider);
/// ```
T readProvider<T>(ProviderContainer container, ProviderListenable<T> provider) {
  return container.read(provider);
}

/// Helper to read an AsyncValue provider and return the data or throw.
///
/// Example:
/// ```dart
/// final data = readAsyncProvider(container, myAsyncProvider);
/// ```
T readAsyncProvider<T>(
  ProviderContainer container,
  ProviderListenable<AsyncValue<T>> provider,
) {
  final asyncValue = container.read(provider);
  return asyncValue.when(
    data: (value) => value,
    loading: () => throw StateError('Provider is still loading'),
    error: (error, stack) => throw error,
  );
}
