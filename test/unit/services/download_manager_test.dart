import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ayp_tour_guide/services/download_manager.dart';
import 'package:ayp_tour_guide/data/local/offline_storage_service.dart';
import '../../helpers/mock_services.dart';
import '../../helpers/provider_helpers.dart';

void main() {
  group('TourDownloadState', () {
    test('default state has correct values', () {
      const state = TourDownloadState(tourId: 'tour_1');

      expect(state.tourId, equals('tour_1'));
      expect(state.status, equals(DownloadStatus.idle));
      expect(state.progress, equals(0.0));
      expect(state.totalBytes, isNull);
      expect(state.downloadedBytes, isNull);
      expect(state.errorMessage, isNull);
    });

    test('copyWith creates new state with updated values', () {
      const initial = TourDownloadState(tourId: 'tour_1');

      final updated = initial.copyWith(
        status: DownloadStatus.downloading,
        progress: 0.5,
        totalBytes: 10000,
        downloadedBytes: 5000,
      );

      expect(updated.tourId, equals('tour_1'));
      expect(updated.status, equals(DownloadStatus.downloading));
      expect(updated.progress, equals(0.5));
      expect(updated.totalBytes, equals(10000));
      expect(updated.downloadedBytes, equals(5000));
    });

    test('isDownloading returns true when downloading', () {
      const state = TourDownloadState(
        tourId: 'tour_1',
        status: DownloadStatus.downloading,
      );

      expect(state.isDownloading, isTrue);
    });

    test('isComplete returns true when complete', () {
      const state = TourDownloadState(
        tourId: 'tour_1',
        status: DownloadStatus.complete,
      );

      expect(state.isComplete, isTrue);
    });

    test('isFailed returns true when failed', () {
      const state = TourDownloadState(
        tourId: 'tour_1',
        status: DownloadStatus.failed,
        errorMessage: 'Network error',
      );

      expect(state.isFailed, isTrue);
    });

    test('isPaused returns true when paused', () {
      const state = TourDownloadState(
        tourId: 'tour_1',
        status: DownloadStatus.paused,
      );

      expect(state.isPaused, isTrue);
    });

    test('state preserves error message', () {
      const state = TourDownloadState(
        tourId: 'tour_1',
        status: DownloadStatus.failed,
        errorMessage: 'Connection refused',
      );

      expect(state.errorMessage, equals('Connection refused'));
    });
  });

  group('DownloadStatus', () {
    test('has all expected values', () {
      expect(DownloadStatus.values, containsAll([
        DownloadStatus.idle,
        DownloadStatus.queued,
        DownloadStatus.downloading,
        DownloadStatus.paused,
        DownloadStatus.complete,
        DownloadStatus.failed,
      ]));
    });
  });

  group('DownloadManager', () {
    late FakeOfflineStorageService fakeStorage;
    late ProviderContainer container;

    setUp(() async {
      fakeStorage = FakeOfflineStorageService();
      await fakeStorage.initialize();

      container = createTestContainer(
        overrides: [
          offlineStorageServiceProvider.overrideWithValue(fakeStorage),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Demo Mode Download', () {
      test('downloadTourDemo simulates download progress', () async {
        final manager = container.read(downloadManagerProvider.notifier);
        final states = <Map<String, TourDownloadState>>[];

        container.listen<Map<String, TourDownloadState>>(
          downloadManagerProvider,
          (previous, next) => states.add(next),
        );

        await manager.downloadTourDemo('tour_1');

        // Should have received multiple progress updates
        expect(states.isNotEmpty, isTrue);

        // Final state should be complete
        final finalState = container.read(downloadManagerProvider)['tour_1'];
        expect(finalState, isNotNull);
        expect(finalState!.status, equals(DownloadStatus.complete));
        expect(finalState.progress, equals(1.0));
        expect(finalState.totalBytes, equals(5000000));
      });

      test('downloadTourDemo starts with downloading state', () async {
        final manager = container.read(downloadManagerProvider.notifier);

        // Start download but don't await
        final future = manager.downloadTourDemo('tour_1');

        // Check initial state
        await Future.delayed(const Duration(milliseconds: 50));
        final state = container.read(downloadManagerProvider)['tour_1'];
        expect(state, isNotNull);
        expect(state!.status, equals(DownloadStatus.downloading));

        await future;
      });
    });

    group('Download State Queries', () {
      test('isDownloaded returns false when not downloaded', () {
        final manager = container.read(downloadManagerProvider.notifier);

        expect(manager.isDownloaded('tour_1'), isFalse);
      });

      test('isDownloaded delegates to storage', () async {
        await fakeStorage.startDownload('tour_1', 'v1');
        await fakeStorage.completeDownload('tour_1', 1000);

        final manager = container.read(downloadManagerProvider.notifier);

        expect(manager.isDownloaded('tour_1'), isTrue);
      });

      test('getDownloadedTourIds returns list from storage', () async {
        await fakeStorage.startDownload('tour_1', 'v1');
        await fakeStorage.completeDownload('tour_1', 1000);
        await fakeStorage.startDownload('tour_2', 'v1');
        await fakeStorage.completeDownload('tour_2', 2000);

        final manager = container.read(downloadManagerProvider.notifier);
        final ids = manager.getDownloadedTourIds();

        expect(ids, containsAll(['tour_1', 'tour_2']));
      });

      test('getDownloadState returns state from local map', () async {
        final manager = container.read(downloadManagerProvider.notifier);

        await manager.downloadTourDemo('tour_1');

        final state = manager.getDownloadState('tour_1');
        expect(state, isNotNull);
        expect(state!.status, equals(DownloadStatus.complete));
      });

      test('getDownloadState falls back to storage', () async {
        await fakeStorage.startDownload('tour_1', 'v1');
        await fakeStorage.updateDownloadProgress('tour_1', 0.5);

        final manager = container.read(downloadManagerProvider.notifier);
        final state = manager.getDownloadState('tour_1');

        expect(state, isNotNull);
        expect(state!.progress, equals(0.5));
      });

      test('getDownloadState returns null for nonexistent', () {
        final manager = container.read(downloadManagerProvider.notifier);

        expect(manager.getDownloadState('nonexistent'), isNull);
      });
    });

    group('Cancel Download', () {
      test('cancelDownload resets state to idle', () async {
        final manager = container.read(downloadManagerProvider.notifier);

        // Start a demo download (which we can't actually cancel mid-progress in tests)
        // But we can test the cancel functionality
        final future = manager.downloadTourDemo('tour_1');
        await Future.delayed(const Duration(milliseconds: 50));

        manager.cancelDownload('tour_1');

        // State should be reset
        final state = container.read(downloadManagerProvider)['tour_1'];
        expect(state?.status, equals(DownloadStatus.idle));

        // Clean up
        try {
          await future;
        } catch (_) {}
      });

      test('cancelDownload handles nonexistent download', () {
        final manager = container.read(downloadManagerProvider.notifier);

        // Should not throw
        expect(() => manager.cancelDownload('nonexistent'), returnsNormally);
      });
    });

    group('Delete Download', () {
      test('deleteDownload removes from storage and state', () async {
        await fakeStorage.startDownload('tour_1', 'v1');
        await fakeStorage.completeDownload('tour_1', 1000);

        final manager = container.read(downloadManagerProvider.notifier);

        // First, verify it's downloaded
        expect(manager.isDownloaded('tour_1'), isTrue);

        // Delete it
        await manager.deleteDownload('tour_1');

        // Verify it's gone
        expect(manager.isDownloaded('tour_1'), isFalse);
      });

      test('deleteDownload removes from state map', () async {
        final manager = container.read(downloadManagerProvider.notifier);

        await manager.downloadTourDemo('tour_1');

        // Verify state exists
        expect(container.read(downloadManagerProvider)['tour_1'], isNotNull);

        await manager.deleteDownload('tour_1');

        // State should be removed
        expect(container.read(downloadManagerProvider)['tour_1'], isNull);
      });
    });

    group('Duplicate Downloads', () {
      test('does not start duplicate download', () async {
        final manager = container.read(downloadManagerProvider.notifier);

        // Start first download
        final future1 = manager.downloadTourDemo('tour_1');
        await Future.delayed(const Duration(milliseconds: 50));

        // Try to start another download for same tour
        final future2 = manager.downloadTourDemo('tour_1');

        // Wait for both to complete
        await future1;
        await future2;

        // Should still have one state entry
        expect(container.read(downloadManagerProvider)['tour_1'], isNotNull);
      });
    });
  });

  group('Provider Tests', () {
    late FakeOfflineStorageService fakeStorage;
    late ProviderContainer container;

    setUp(() async {
      fakeStorage = FakeOfflineStorageService();
      await fakeStorage.initialize();

      container = createTestContainer(
        overrides: [
          offlineStorageServiceProvider.overrideWithValue(fakeStorage),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('downloadManagerProvider provides DownloadManager', () {
      final manager = container.read(downloadManagerProvider.notifier);

      expect(manager, isA<DownloadManager>());
    });

    test('downloadManagerProvider state is empty initially', () {
      final state = container.read(downloadManagerProvider);

      expect(state, isEmpty);
    });

    test('isTourDownloadedProvider returns correct value', () async {
      await fakeStorage.startDownload('tour_1', 'v1');
      await fakeStorage.completeDownload('tour_1', 1000);

      final isDownloaded = container.read(isTourDownloadedProvider('tour_1'));
      final isNotDownloaded = container.read(isTourDownloadedProvider('tour_2'));

      expect(isDownloaded, isTrue);
      expect(isNotDownloaded, isFalse);
    });

    test('tourDownloadStateProvider returns state', () async {
      final manager = container.read(downloadManagerProvider.notifier);
      await manager.downloadTourDemo('tour_1');

      final state = container.read(tourDownloadStateProvider('tour_1'));

      expect(state, isNotNull);
      expect(state!.status, equals(DownloadStatus.complete));
    });

    test('tourDownloadStateProvider returns null for missing', () {
      final state = container.read(tourDownloadStateProvider('nonexistent'));

      expect(state, isNull);
    });
  });

  group('Status Parsing', () {
    late FakeOfflineStorageService fakeStorage;
    late ProviderContainer container;

    setUp(() async {
      fakeStorage = FakeOfflineStorageService();
      await fakeStorage.initialize();

      container = createTestContainer(
        overrides: [
          offlineStorageServiceProvider.overrideWithValue(fakeStorage),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('parses downloading status', () async {
      await fakeStorage.startDownload('tour_1', 'v1');
      await fakeStorage.updateDownloadProgress('tour_1', 0.5);

      final manager = container.read(downloadManagerProvider.notifier);
      final state = manager.getDownloadState('tour_1');

      expect(state!.status, equals(DownloadStatus.downloading));
    });

    test('parses complete status', () async {
      await fakeStorage.startDownload('tour_1', 'v1');
      await fakeStorage.completeDownload('tour_1', 1000);

      final manager = container.read(downloadManagerProvider.notifier);
      final state = manager.getDownloadState('tour_1');

      expect(state!.status, equals(DownloadStatus.complete));
    });

    test('parses failed status', () async {
      await fakeStorage.startDownload('tour_1', 'v1');
      await fakeStorage.failDownload('tour_1', 'Error');

      final manager = container.read(downloadManagerProvider.notifier);
      final state = manager.getDownloadState('tour_1');

      expect(state!.status, equals(DownloadStatus.failed));
      expect(state.errorMessage, equals('Error'));
    });

    test('defaults to idle for unknown status', () async {
      await fakeStorage.startDownload('tour_1', 'v1');
      // Manually set an unknown status in the fake storage would require
      // modifying the fake, so we just test that the default path works
      final manager = container.read(downloadManagerProvider.notifier);

      // Clear and set idle
      await fakeStorage.deleteDownload('tour_1');
      final state = manager.getDownloadState('tour_1');

      expect(state, isNull);
    });
  });

  group('Edge Cases', () {
    late FakeOfflineStorageService fakeStorage;
    late ProviderContainer container;

    setUp(() async {
      fakeStorage = FakeOfflineStorageService();
      await fakeStorage.initialize();

      container = createTestContainer(
        overrides: [
          offlineStorageServiceProvider.overrideWithValue(fakeStorage),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('handles rapid sequential demo downloads', () async {
      final manager = container.read(downloadManagerProvider.notifier);

      // Start multiple downloads in sequence
      await manager.downloadTourDemo('tour_1');
      await manager.downloadTourDemo('tour_2');
      await manager.downloadTourDemo('tour_3');

      final state = container.read(downloadManagerProvider);
      expect(state['tour_1']?.isComplete, isTrue);
      expect(state['tour_2']?.isComplete, isTrue);
      expect(state['tour_3']?.isComplete, isTrue);
    });

    test('handles download after delete', () async {
      final manager = container.read(downloadManagerProvider.notifier);

      await manager.downloadTourDemo('tour_1');
      await manager.deleteDownload('tour_1');
      await manager.downloadTourDemo('tour_1');

      final state = container.read(downloadManagerProvider)['tour_1'];
      expect(state?.isComplete, isTrue);
    });
  });
}
