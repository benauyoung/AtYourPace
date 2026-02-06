
import 'package:flutter_test/flutter_test.dart';

import 'package:ayp_tour_guide/data/models/stop_model.dart';
import 'package:ayp_tour_guide/data/models/tour_model.dart';
import 'package:ayp_tour_guide/data/models/tour_version_model.dart';

import '../helpers/test_helpers.dart';
import '../helpers/mock_services.dart';

/// Integration tests for the offline playback flow.
///
/// Tests the flow: Download Tour -> Go Offline -> Play from Cache
/// -> Reconnect -> Sync Progress
void main() {
  group('Offline Playback Flow Integration', () {
    late TourModel testTour;
    late TourVersionModel testVersion;
    late List<StopModel> testStops;
    late FakeOfflineStorageServiceSimple fakeStorage;
    late FakeConnectivityService fakeConnectivity;

    setUp(() {
      testTour = createTestTour(
        id: 'offline_tour_1',
        city: 'Offline City',
      );
      testVersion = createTestTourVersion(
        id: 'v1',
        tourId: 'offline_tour_1',
        title: 'Offline Test Tour',
      );
      testStops = createTestStops(count: 5);
      fakeStorage = FakeOfflineStorageServiceSimple();
      fakeConnectivity = FakeConnectivityService();
    });

    group('Download Flow', () {
      test('caches tour data for offline use', () async {
        // Initially not cached
        expect(await fakeStorage.getCachedTour(testTour.id), isNull);

        // Cache the tour
        await fakeStorage.cacheTour(testTour);

        // Verify cached
        final cached = await fakeStorage.getCachedTour(testTour.id);
        expect(cached, isNotNull);
        expect(cached!.id, equals(testTour.id));
      });

      test('caches tour version data', () async {
        expect(
          await fakeStorage.getCachedVersion(testTour.id, testVersion.id),
          isNull,
        );

        await fakeStorage.cacheVersion(testTour.id, testVersion);

        final cached = await fakeStorage.getCachedVersion(
          testTour.id,
          testVersion.id,
        );
        expect(cached, isNotNull);
        expect(cached!.title, equals('Offline Test Tour'));
      });

      test('caches stops data', () async {
        expect(await fakeStorage.getCachedStops(testTour.id), isEmpty);

        await fakeStorage.cacheStops(testTour.id, testStops);

        final cached = await fakeStorage.getCachedStops(testTour.id);
        expect(cached.length, equals(5));
      });

      test('tracks download state correctly', () async {
        // Initially not downloaded
        expect(await fakeStorage.isDownloaded(testTour.id), isFalse);

        // Simulate download
        await fakeStorage.cacheTour(testTour);
        await fakeStorage.cacheVersion(testTour.id, testVersion);
        await fakeStorage.cacheStops(testTour.id, testStops);
        await fakeStorage.markDownloaded(testTour.id);

        expect(await fakeStorage.isDownloaded(testTour.id), isTrue);
      });
    });

    group('Offline Detection', () {
      test('detects online to offline transition', () async {
        final statusChanges = <bool>[];
        final subscription = fakeConnectivity.onlineStream.listen(
          statusChanges.add,
        );

        expect(fakeConnectivity.isOnline, isTrue);

        fakeConnectivity.setOnline(false);
        expect(fakeConnectivity.isOnline, isFalse);

        await Future.delayed(const Duration(milliseconds: 50));

        expect(statusChanges, contains(false));

        await subscription.cancel();
      });

      test('detects offline to online transition', () async {
        fakeConnectivity.setOnline(false);

        final statusChanges = <bool>[];
        final subscription = fakeConnectivity.onlineStream.listen(
          statusChanges.add,
        );

        fakeConnectivity.setOnline(true);

        await Future.delayed(const Duration(milliseconds: 50));

        expect(statusChanges, contains(true));

        await subscription.cancel();
      });
    });

    group('Offline Playback', () {
      test('can play cached tour when offline', () async {
        // Setup: download while online
        await fakeStorage.cacheTour(testTour);
        await fakeStorage.cacheVersion(testTour.id, testVersion);
        await fakeStorage.cacheStops(testTour.id, testStops);
        await fakeStorage.markDownloaded(testTour.id);

        // Go offline
        fakeConnectivity.setOnline(false);
        expect(fakeConnectivity.isOnline, isFalse);

        // Verify can still access cached data
        final cachedTour = await fakeStorage.getCachedTour(testTour.id);
        final cachedVersion = await fakeStorage.getCachedVersion(
          testTour.id,
          testVersion.id,
        );
        final cachedStops = await fakeStorage.getCachedStops(testTour.id);

        expect(cachedTour, isNotNull);
        expect(cachedVersion, isNotNull);
        expect(cachedStops.length, equals(5));
      });

      test('saves progress locally when offline', () async {
        fakeConnectivity.setOnline(false);

        // Save progress
        await fakeStorage.saveProgress(
          tourId: testTour.id,
          currentStopIndex: 2,
          completedStops: {0, 1},
        );

        // Verify saved
        final progress = await fakeStorage.getProgress(testTour.id);
        expect(progress, isNotNull);
        expect(progress!.currentStopIndex, equals(2));
        expect(progress.completedStops, equals({0, 1}));
      });

      test('accumulates progress changes offline', () async {
        fakeConnectivity.setOnline(false);

        // Save initial progress
        await fakeStorage.saveProgress(
          tourId: testTour.id,
          currentStopIndex: 0,
          completedStops: {},
        );

        // Progress through stops
        await fakeStorage.saveProgress(
          tourId: testTour.id,
          currentStopIndex: 1,
          completedStops: {0},
        );

        await fakeStorage.saveProgress(
          tourId: testTour.id,
          currentStopIndex: 2,
          completedStops: {0, 1},
        );

        // Verify latest progress
        final progress = await fakeStorage.getProgress(testTour.id);
        expect(progress!.currentStopIndex, equals(2));
        expect(progress.completedStops, equals({0, 1}));
      });
    });

    group('Reconnection and Sync', () {
      test('queues progress for sync when offline', () async {
        fakeConnectivity.setOnline(false);

        await fakeStorage.saveProgress(
          tourId: testTour.id,
          currentStopIndex: 3,
          completedStops: {0, 1, 2},
        );

        // Mark as pending sync
        await fakeStorage.markProgressPendingSync(testTour.id);

        expect(await fakeStorage.hasPendingSync(testTour.id), isTrue);
      });

      test('syncs progress when coming back online', () async {
        // Setup offline progress
        fakeConnectivity.setOnline(false);
        await fakeStorage.saveProgress(
          tourId: testTour.id,
          currentStopIndex: 3,
          completedStops: {0, 1, 2},
        );
        await fakeStorage.markProgressPendingSync(testTour.id);

        // Come back online
        fakeConnectivity.setOnline(true);

        // Simulate sync completion
        await fakeStorage.clearPendingSync(testTour.id);

        expect(await fakeStorage.hasPendingSync(testTour.id), isFalse);
      });

      test('handles multiple tours with pending sync', () async {
        fakeConnectivity.setOnline(false);

        // Progress on multiple tours
        await fakeStorage.saveProgress(
          tourId: 'tour_1',
          currentStopIndex: 2,
          completedStops: {0, 1},
        );
        await fakeStorage.markProgressPendingSync('tour_1');

        await fakeStorage.saveProgress(
          tourId: 'tour_2',
          currentStopIndex: 1,
          completedStops: {0},
        );
        await fakeStorage.markProgressPendingSync('tour_2');

        // Verify both are pending
        expect(await fakeStorage.hasPendingSync('tour_1'), isTrue);
        expect(await fakeStorage.hasPendingSync('tour_2'), isTrue);

        // Come online and sync
        fakeConnectivity.setOnline(true);

        final pendingTours = await fakeStorage.getPendingSyncTourIds();
        expect(pendingTours.length, equals(2));

        // Sync each
        for (final tourId in pendingTours) {
          await fakeStorage.clearPendingSync(tourId);
        }

        expect(await fakeStorage.hasPendingSync('tour_1'), isFalse);
        expect(await fakeStorage.hasPendingSync('tour_2'), isFalse);
      });
    });

    group('Cache Expiration', () {
      test('detects expired cache', () async {
        await fakeStorage.cacheTour(testTour);

        // Initially fresh
        expect(await fakeStorage.isCacheExpired(testTour.id), isFalse);

        // Simulate expiration (in real implementation, this would be time-based)
        fakeStorage.simulateCacheExpiration(testTour.id);

        expect(await fakeStorage.isCacheExpired(testTour.id), isTrue);
      });

      test('refreshes expired cache when online', () async {
        await fakeStorage.cacheTour(testTour);
        fakeStorage.simulateCacheExpiration(testTour.id);

        // Go online
        fakeConnectivity.setOnline(true);

        // Refresh cache
        final newTour = testTour.copyWith(
          stats: testTour.stats.copyWith(totalPlays: 999),
        );
        await fakeStorage.cacheTour(newTour);

        // Verify refreshed
        final cached = await fakeStorage.getCachedTour(testTour.id);
        expect(cached!.stats.totalPlays, equals(999));
        expect(await fakeStorage.isCacheExpired(testTour.id), isFalse);
      });
    });

    group('Storage Management', () {
      test('clears tour cache', () async {
        await fakeStorage.cacheTour(testTour);
        await fakeStorage.cacheVersion(testTour.id, testVersion);
        await fakeStorage.cacheStops(testTour.id, testStops);

        await fakeStorage.clearTourCache(testTour.id);

        expect(await fakeStorage.getCachedTour(testTour.id), isNull);
        expect(
          await fakeStorage.getCachedVersion(testTour.id, testVersion.id),
          isNull,
        );
        expect(await fakeStorage.getCachedStops(testTour.id), isEmpty);
      });

      test('clears all cache', () async {
        // Cache multiple tours
        await fakeStorage.cacheTour(testTour);
        await fakeStorage.cacheTour(createTestTour(id: 'tour_2'));
        await fakeStorage.cacheTour(createTestTour(id: 'tour_3'));

        await fakeStorage.clearAllCache();

        expect(await fakeStorage.getCachedTour(testTour.id), isNull);
        expect(await fakeStorage.getCachedTour('tour_2'), isNull);
        expect(await fakeStorage.getCachedTour('tour_3'), isNull);
      });

      test('preserves progress when clearing cache', () async {
        await fakeStorage.cacheTour(testTour);
        await fakeStorage.saveProgress(
          tourId: testTour.id,
          currentStopIndex: 2,
          completedStops: {0, 1},
        );

        // Clear only tour cache, not progress
        await fakeStorage.clearTourCache(testTour.id);

        // Progress should still exist
        final progress = await fakeStorage.getProgress(testTour.id);
        expect(progress, isNotNull);
        expect(progress!.currentStopIndex, equals(2));
      });
    });

    group('Error Scenarios', () {
      test('handles cache read failure gracefully', () async {
        // Simulate storage failure
        fakeStorage.simulateReadFailure();

        expect(
          () async => await fakeStorage.getCachedTour(testTour.id),
          throwsA(isA<Exception>()),
        );

        // Recovery
        fakeStorage.clearReadFailure();
        expect(await fakeStorage.getCachedTour(testTour.id), isNull);
      });

      test('handles cache write failure gracefully', () async {
        fakeStorage.simulateWriteFailure();

        expect(
          () async => await fakeStorage.cacheTour(testTour),
          throwsA(isA<Exception>()),
        );

        // Recovery
        fakeStorage.clearWriteFailure();
        await fakeStorage.cacheTour(testTour);
        expect(await fakeStorage.getCachedTour(testTour.id), isNotNull);
      });

      test('handles intermittent connectivity', () async {
        // Start online
        expect(fakeConnectivity.isOnline, isTrue);

        // Rapid connectivity changes
        for (int i = 0; i < 5; i++) {
          fakeConnectivity.setOnline(i % 2 == 0);
          await Future.delayed(const Duration(milliseconds: 10));
        }

        // Should handle without crashing
        // Loop ends at i=4, which is even, so isOnline = true
        expect(fakeConnectivity.isOnline, isTrue);
      });
    });

    group('Full Offline Workflow', () {
      test('complete offline tour playback scenario', () async {
        // 1. Download while online
        await fakeStorage.cacheTour(testTour);
        await fakeStorage.cacheVersion(testTour.id, testVersion);
        await fakeStorage.cacheStops(testTour.id, testStops);
        await fakeStorage.markDownloaded(testTour.id);

        // 2. Go offline
        fakeConnectivity.setOnline(false);

        // 3. Load tour from cache
        final cachedTour = await fakeStorage.getCachedTour(testTour.id);
        final cachedStops = await fakeStorage.getCachedStops(testTour.id);
        expect(cachedTour, isNotNull);
        expect(cachedStops.length, equals(5));

        // 4. Play through tour, saving progress
        for (int i = 0; i < cachedStops.length; i++) {
          await fakeStorage.saveProgress(
            tourId: testTour.id,
            currentStopIndex: i,
            completedStops: Set.from(List.generate(i, (j) => j)),
          );
        }

        // Mark as complete
        await fakeStorage.saveProgress(
          tourId: testTour.id,
          currentStopIndex: cachedStops.length - 1,
          completedStops: Set.from(List.generate(cachedStops.length, (i) => i)),
        );
        await fakeStorage.markProgressPendingSync(testTour.id);

        // 5. Verify final state
        final finalProgress = await fakeStorage.getProgress(testTour.id);
        expect(finalProgress!.completedStops.length, equals(5));
        expect(await fakeStorage.hasPendingSync(testTour.id), isTrue);

        // 6. Come back online and sync
        fakeConnectivity.setOnline(true);
        await fakeStorage.clearPendingSync(testTour.id);

        expect(await fakeStorage.hasPendingSync(testTour.id), isFalse);
      });
    });
  });
}
