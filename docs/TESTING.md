# Testing Guide

Comprehensive testing documentation for the AYP Tour Guide application.

## Table of Contents

- [Overview](#overview)
- [Running Tests](#running-tests)
- [Test Structure](#test-structure)
- [Test Categories](#test-categories)
- [Mocking Strategy](#mocking-strategy)
- [Writing Tests](#writing-tests)
- [Coverage](#coverage)
- [Best Practices](#best-practices)

---

## Overview

The AYP Tour Guide application includes a comprehensive test suite with **504 tests** covering unit tests, widget tests, and integration tests. The testing strategy prioritizes:

1. **Services** - Core business logic and external integrations
2. **Providers** - State management with Riverpod
3. **Models** - Data serialization and validation
4. **Widgets** - UI component behavior
5. **Integration** - End-to-end user flows

### Current Coverage

| Category | Coverage |
|----------|----------|
| Services | 40-100% |
| Models | 73-96% |
| Widgets | 84-87% |
| **Overall** | **31.5%** |

---

## Running Tests

### All Tests

```bash
# Run all tests
flutter test

# Run with verbose output
flutter test --reporter expanded
```

### With Coverage

```bash
# Generate coverage report
flutter test --coverage

# View coverage summary (requires lcov)
lcov --summary coverage/lcov.info

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Specific Tests

```bash
# Run single test file
flutter test test/unit/services/geofence_service_test.dart

# Run tests matching pattern
flutter test --name "AudioService"

# Run specific directory
flutter test test/integration/
```

### Watch Mode

```bash
# Re-run tests on file changes
flutter test --watch
```

---

## Test Structure

```
test/
├── helpers/
│   ├── test_helpers.dart         # Mock annotations, factories
│   ├── test_helpers.mocks.dart   # Generated mocks
│   ├── mock_services.dart        # Fake service implementations
│   └── widget_test_helpers.dart  # Widget testing utilities
│
├── unit/
│   ├── models/                   # Model serialization tests
│   │   ├── tour_model_test.dart
│   │   ├── user_model_test.dart
│   │   ├── stop_model_test.dart
│   │   └── ...
│   ├── services/                 # Service unit tests
│   │   ├── audio_service_test.dart
│   │   ├── location_service_test.dart
│   │   ├── geofence_service_test.dart
│   │   └── ...
│   └── providers/                # Riverpod provider tests
│       ├── auth_provider_test.dart
│       ├── playback_provider_test.dart
│       └── ...
│
├── widgets/                      # Widget tests
│   ├── audio/
│   │   └── audio_player_widget_test.dart
│   ├── tour/
│   │   └── tour_card_test.dart
│   └── common/
│       └── ...
│
├── screens/                      # Screen tests
│   ├── auth/
│   │   ├── login_screen_test.dart
│   │   └── register_screen_test.dart
│   ├── user/
│   │   ├── home_screen_test.dart
│   │   └── tour_playback_screen_test.dart
│   ├── creator/
│   │   └── tour_editor_screen_test.dart
│   └── admin/
│       └── review_queue_screen_test.dart
│
└── integration/                  # End-to-end flow tests
    ├── tour_playback_flow_test.dart
    ├── offline_playback_flow_test.dart
    ├── tour_creation_flow_test.dart
    └── admin_review_flow_test.dart
```

---

## Test Categories

### Unit Tests

Test individual functions and classes in isolation.

**Services:**
- `AudioService` - Audio playback, state management
- `LocationService` - GPS tracking, permissions
- `GeofenceService` - Geofence monitoring, triggers
- `DownloadManager` - Tour downloads, progress tracking
- `OfflineStorageService` - Hive caching, expiration
- `ProgressService` - Tour progress, completion tracking
- `AdminService` - Admin operations, audit logging

**Models:**
- JSON serialization/deserialization
- Firestore conversion (GeoPoint, Timestamp)
- Computed properties
- Validation logic

**Providers:**
- State transitions
- Async operations
- Error handling
- Stream subscriptions

### Widget Tests

Test UI components with mocked dependencies.

```dart
testWidgets('TourCard displays tour information', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: TourCard(
        tour: testTour,
        onTap: () {},
      ),
    ),
  );

  expect(find.text('Downtown Walking Tour'), findsOneWidget);
  expect(find.byIcon(Icons.star), findsOneWidget);
});
```

### Integration Tests

Test complete user flows across multiple components.

**Tour Playback Flow:**
1. Discover tour → View details → Start tour
2. Enter geofence → Audio plays automatically
3. Complete stops → Tour completion

**Offline Playback Flow:**
1. Download tour → Go offline
2. Play from cache → Complete stops
3. Reconnect → Sync progress

**Tour Creation Flow:**
1. Create tour → Add metadata
2. Add stops → Record/upload audio
3. Submit for review

**Admin Review Flow:**
1. View review queue → Select tour
2. Review content → Approve/reject
3. Verify audit log

---

## Mocking Strategy

### Generated Mocks (Mockito)

Use `@GenerateMocks` annotation in `test/helpers/test_helpers.dart`:

```dart
@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  FirebaseStorage,
  AudioPlayer,
  // Add services to mock
])
void main() {}
```

Generate mocks:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Fake Implementations

For complex services, create fake implementations in `test/helpers/mock_services.dart`:

```dart
class FakeAudioService {
  final _stateController = StreamController<PlaybackState>.broadcast();
  PlaybackState _state = PlaybackState.initial();

  Stream<PlaybackState> get stateStream => _stateController.stream;
  PlaybackState get state => _state;

  Future<void> play() async {
    _state = _state.copyWith(isPlaying: true);
    _stateController.add(_state);
  }

  // Simulate state changes for testing
  void simulateStateChange(PlaybackState newState) {
    _state = newState;
    _stateController.add(_state);
  }
}
```

### Provider Overrides

Override providers in tests using `ProviderScope`:

```dart
testWidgets('test with overridden provider', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) => FakeAuthNotifier()),
        tourRepositoryProvider.overrideWithValue(fakeTourRepo),
      ],
      child: const MyApp(),
    ),
  );
});
```

---

## Writing Tests

### Test File Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/test_helpers.mocks.dart';

void main() {
  late MockDependency mockDep;
  late ServiceUnderTest service;

  setUp(() {
    mockDep = MockDependency();
    service = ServiceUnderTest(mockDep);
  });

  tearDown(() {
    // Clean up resources
  });

  group('ServiceUnderTest', () {
    group('methodName', () {
      test('should do something when condition', () async {
        // Arrange
        when(mockDep.someMethod()).thenReturn(expectedValue);

        // Act
        final result = await service.methodName();

        // Assert
        expect(result, expectedValue);
        verify(mockDep.someMethod()).called(1);
      });

      test('should throw when error occurs', () {
        // Arrange
        when(mockDep.someMethod()).thenThrow(Exception());

        // Act & Assert
        expect(
          () => service.methodName(),
          throwsException,
        );
      });
    });
  });
}
```

### Test Data Factories

Use factory methods in `test/helpers/test_helpers.dart`:

```dart
TourModel createTestTour({
  String? id,
  String? title,
  TourStatus? status,
}) {
  return TourModel(
    id: id ?? 'tour-${DateTime.now().millisecondsSinceEpoch}',
    title: title ?? 'Test Tour',
    status: status ?? TourStatus.approved,
    // ... other required fields
  );
}

StopModel createTestStop({
  int? order,
  String? title,
  double? latitude,
  double? longitude,
}) {
  return StopModel(
    id: 'stop-$order',
    tourId: 'tour-1',
    order: order ?? 0,
    title: title ?? 'Test Stop',
    location: GeoPoint(latitude ?? 40.7128, longitude ?? -74.0060),
    // ... other required fields
  );
}
```

### Async Testing

```dart
test('handles async operations', () async {
  // Use async/await for Future-based tests
  final result = await service.asyncMethod();
  expect(result, isNotNull);
});

test('handles streams', () async {
  // Use expectLater for stream assertions
  expectLater(
    service.stateStream,
    emitsInOrder([
      predicate<State>((s) => s.isLoading),
      predicate<State>((s) => s.isLoaded),
    ]),
  );

  await service.loadData();
});
```

---

## Coverage

### Coverage by File (Top Files)

| File | Lines | Covered | % |
|------|-------|---------|---|
| `progress_service.dart` | 89 | 89 | 100% |
| `geofence_service.dart` | 108 | 100 | 92.6% |
| `tour_card.dart` | 54 | 47 | 87.0% |
| `audio_player_widget.dart` | 158 | 133 | 84.2% |
| `tour_model.dart` | 93 | 89 | 95.7% |
| `user_model.dart` | 47 | 35 | 74.5% |

### Uncovered Areas

Files with 0% coverage that need tests:
- `admin_service.dart`
- `storage_service.dart`
- `connectivity_service.dart`
- Various screen files

### Improving Coverage

1. **Focus on critical paths** - Services handling core functionality
2. **Test error cases** - Exception handling, edge cases
3. **Add widget tests** - UI components with user interaction
4. **Integration tests** - End-to-end user flows

---

## Best Practices

### Do

- **Use descriptive test names** - `should return user when credentials are valid`
- **Follow AAA pattern** - Arrange, Act, Assert
- **Test one thing per test** - Single assertion focus
- **Use setUp/tearDown** - Consistent test state
- **Mock external dependencies** - Isolate unit under test
- **Test edge cases** - Null values, empty collections, boundaries

### Don't

- **Don't test implementation details** - Test behavior, not internals
- **Don't use real Firebase** - Always mock in unit tests
- **Don't share state between tests** - Each test should be independent
- **Don't ignore failing tests** - Fix or remove, never skip indefinitely

### Testing Async Code

```dart
// Good - explicit async handling
test('loads data asynchronously', () async {
  when(mockRepo.getData()).thenAnswer((_) async => testData);

  final result = await service.loadData();

  expect(result, testData);
});

// Good - testing streams
test('emits states in order', () async {
  expectLater(
    service.stateStream,
    emitsInOrder([loading, loaded]),
  );

  await service.initialize();
});
```

### Testing Riverpod Providers

```dart
test('provider notifies listeners on state change', () async {
  final container = ProviderContainer(
    overrides: [
      // Override dependencies
    ],
  );
  addTearDown(container.dispose);

  final notifier = container.read(myProvider.notifier);

  expect(container.read(myProvider), initialState);

  await notifier.updateState(newValue);

  expect(container.read(myProvider), expectedState);
});
```

---

## Troubleshooting

### Common Issues

**Tests timing out:**
```dart
// Increase timeout for slow tests
test('slow operation', () async {
  // ...
}, timeout: Timeout(Duration(seconds: 30)));
```

**Mocks not working:**
```bash
# Regenerate mocks after adding new annotations
dart run build_runner build --delete-conflicting-outputs
```

**Widget tests failing:**
```dart
// Ensure widget tree is fully built
await tester.pumpAndSettle();

// Or pump specific number of frames
await tester.pump(Duration(milliseconds: 100));
```

**Firestore timestamp issues:**
```dart
// Use Timestamp.now() in tests, not DateTime
final timestamp = Timestamp.now();
```

### Running Specific Test Patterns

```bash
# Run tests containing "geofence" in name
flutter test --name "geofence"

# Run tests in specific file matching pattern
flutter test test/unit/services/*_test.dart

# Run with specific tags
flutter test --tags integration
```
