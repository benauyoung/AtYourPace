import 'package:flutter_test/flutter_test.dart';

import 'package:ayp_tour_guide/data/models/tour_model.dart';
import 'package:ayp_tour_guide/data/models/tour_version_model.dart';
import 'package:ayp_tour_guide/data/models/stop_model.dart';
import '../../helpers/mock_services.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('OfflineStorageService', () {
    late FakeOfflineStorageService storage;

    setUp(() async {
      storage = FakeOfflineStorageService();
      await storage.initialize();
    });

    tearDown(() async {
      await storage.close();
    });

    group('Tour Caching', () {
      test('cacheTour stores tour data', () async {
        final tour = createTestTour(id: 'tour_1');

        await storage.cacheTour(tour);

        final cached = storage.getCachedTour('tour_1');
        expect(cached, isNotNull);
      });

      test('getCachedTour returns null for missing tour', () {
        final cached = storage.getCachedTour('nonexistent');

        expect(cached, isNull);
      });

      test('clearTourCache removes all tours', () async {
        await storage.cacheTour(createTestTour(id: 'tour_1'));
        await storage.cacheTour(createTestTour(id: 'tour_2'));

        await storage.clearTourCache();

        expect(storage.getCachedTour('tour_1'), isNull);
        expect(storage.getCachedTour('tour_2'), isNull);
      });
    });

    group('Version Caching', () {
      test('cacheVersion stores version data', () async {
        final version = createTestTourVersion(id: 'version_1', tourId: 'tour_1');

        await storage.cacheVersion(version);

        final cached = storage.getCachedVersion('tour_1', 'version_1');
        expect(cached, isNotNull);
      });

      test('getCachedVersion returns null for missing version', () {
        final cached = storage.getCachedVersion('tour_1', 'nonexistent');

        expect(cached, isNull);
      });

      test('versions are keyed by tourId and versionId', () async {
        final version1 = createTestTourVersion(id: 'v1', tourId: 'tour_1');
        final version2 = createTestTourVersion(id: 'v2', tourId: 'tour_1');
        final version3 = createTestTourVersion(id: 'v1', tourId: 'tour_2');

        await storage.cacheVersion(version1);
        await storage.cacheVersion(version2);
        await storage.cacheVersion(version3);

        expect(storage.getCachedVersion('tour_1', 'v1'), isNotNull);
        expect(storage.getCachedVersion('tour_1', 'v2'), isNotNull);
        expect(storage.getCachedVersion('tour_2', 'v1'), isNotNull);
        expect(storage.getCachedVersion('tour_2', 'v2'), isNull);
      });
    });

    group('Stops Caching', () {
      test('cacheStops stores stops data', () async {
        final stops = createTestStops(count: 3, tourId: 'tour_1', versionId: 'v1');

        await storage.cacheStops('tour_1', 'v1', stops);

        final cached = storage.getCachedStops('tour_1', 'v1');
        expect(cached, isNotNull);
        expect(cached!.length, equals(3));
      });

      test('getCachedStops returns null for missing stops', () {
        final cached = storage.getCachedStops('tour_1', 'nonexistent');

        expect(cached, isNull);
      });

      test('stops are keyed by tourId and versionId', () async {
        final stops1 = createTestStops(count: 2, tourId: 'tour_1', versionId: 'v1');
        final stops2 = createTestStops(count: 4, tourId: 'tour_1', versionId: 'v2');

        await storage.cacheStops('tour_1', 'v1', stops1);
        await storage.cacheStops('tour_1', 'v2', stops2);

        final cached1 = storage.getCachedStops('tour_1', 'v1');
        final cached2 = storage.getCachedStops('tour_1', 'v2');

        expect(cached1!.length, equals(2));
        expect(cached2!.length, equals(4));
      });
    });

    group('Download State Management', () {
      test('startDownload initializes download state', () async {
        await storage.startDownload('tour_1', 'v1');

        final status = storage.getDownloadStatus('tour_1');
        expect(status, isNotNull);
        expect(status!['status'], equals('downloading'));
        expect(status['progress'], equals(0.0));
        expect(status['tourId'], equals('tour_1'));
        expect(status['versionId'], equals('v1'));
      });

      test('updateDownloadProgress updates progress', () async {
        await storage.startDownload('tour_1', 'v1');

        await storage.updateDownloadProgress('tour_1', 0.5);

        final status = storage.getDownloadStatus('tour_1');
        expect(status!['progress'], equals(0.5));
      });

      test('updateDownloadProgress updates fileSize', () async {
        await storage.startDownload('tour_1', 'v1');

        await storage.updateDownloadProgress('tour_1', 0.7, fileSize: 5000000);

        final status = storage.getDownloadStatus('tour_1');
        expect(status!['progress'], equals(0.7));
        expect(status['fileSize'], equals(5000000));
      });

      test('completeDownload marks as complete', () async {
        await storage.startDownload('tour_1', 'v1');
        await storage.updateDownloadProgress('tour_1', 0.5);

        await storage.completeDownload('tour_1', 10000000);

        final status = storage.getDownloadStatus('tour_1');
        expect(status!['status'], equals('complete'));
        expect(status['progress'], equals(1.0));
        expect(status['fileSize'], equals(10000000));
        expect(status['completedAt'], isNotNull);
        expect(status['expiresAt'], isNotNull);
      });

      test('failDownload marks as failed with error', () async {
        await storage.startDownload('tour_1', 'v1');

        await storage.failDownload('tour_1', 'Network error');

        final status = storage.getDownloadStatus('tour_1');
        expect(status!['status'], equals('failed'));
        expect(status['error'], equals('Network error'));
      });

      test('isDownloaded returns true for completed downloads', () async {
        await storage.startDownload('tour_1', 'v1');
        await storage.completeDownload('tour_1', 1000);

        expect(storage.isDownloaded('tour_1'), isTrue);
      });

      test('isDownloaded returns false for in-progress downloads', () async {
        await storage.startDownload('tour_1', 'v1');

        expect(storage.isDownloaded('tour_1'), isFalse);
      });

      test('isDownloaded returns false for failed downloads', () async {
        await storage.startDownload('tour_1', 'v1');
        await storage.failDownload('tour_1', 'Error');

        expect(storage.isDownloaded('tour_1'), isFalse);
      });

      test('isDownloaded returns false for missing downloads', () {
        expect(storage.isDownloaded('nonexistent'), isFalse);
      });

      test('getDownloadedTourIds returns completed tours', () async {
        await storage.startDownload('tour_1', 'v1');
        await storage.completeDownload('tour_1', 1000);

        await storage.startDownload('tour_2', 'v1');
        // tour_2 still downloading

        await storage.startDownload('tour_3', 'v1');
        await storage.completeDownload('tour_3', 2000);

        final ids = storage.getDownloadedTourIds();

        expect(ids, containsAll(['tour_1', 'tour_3']));
        expect(ids, isNot(contains('tour_2')));
      });

      test('deleteDownload removes all related data', () async {
        await storage.cacheTour(createTestTour(id: 'tour_1'));
        await storage.cacheVersion(createTestTourVersion(id: 'v1', tourId: 'tour_1'));
        await storage.cacheStops('tour_1', 'v1', createTestStops(count: 2));
        await storage.startDownload('tour_1', 'v1');
        await storage.completeDownload('tour_1', 1000);

        await storage.deleteDownload('tour_1');

        expect(storage.isDownloaded('tour_1'), isFalse);
        expect(storage.getDownloadStatus('tour_1'), isNull);
        expect(storage.getCachedTour('tour_1'), isNull);
        expect(storage.getCachedVersion('tour_1', 'v1'), isNull);
        expect(storage.getCachedStops('tour_1', 'v1'), isNull);
      });
    });

    group('User Progress', () {
      test('saveProgress stores progress data', () async {
        await storage.saveProgress(
          tourId: 'tour_1',
          versionId: 'v1',
          currentStopIndex: 3,
          completedStops: [0, 1, 2],
          status: 'in_progress',
        );

        final progress = storage.getProgress('tour_1');
        expect(progress, isNotNull);
        expect(progress!['tourId'], equals('tour_1'));
        expect(progress['currentStopIndex'], equals(3));
        expect(progress['completedStops'], equals([0, 1, 2]));
        expect(progress['status'], equals('in_progress'));
      });

      test('getProgress returns null for missing progress', () {
        final progress = storage.getProgress('nonexistent');

        expect(progress, isNull);
      });

      test('clearProgress removes progress', () async {
        await storage.saveProgress(
          tourId: 'tour_1',
          versionId: 'v1',
          currentStopIndex: 2,
          completedStops: [0, 1],
          status: 'in_progress',
        );

        await storage.clearProgress('tour_1');

        expect(storage.getProgress('tour_1'), isNull);
      });

      test('getInProgressTourIds returns in-progress tours', () async {
        await storage.saveProgress(
          tourId: 'tour_1',
          versionId: 'v1',
          currentStopIndex: 2,
          completedStops: [0, 1],
          status: 'in_progress',
        );

        await storage.saveProgress(
          tourId: 'tour_2',
          versionId: 'v1',
          currentStopIndex: 5,
          completedStops: [0, 1, 2, 3, 4],
          status: 'completed',
        );

        await storage.saveProgress(
          tourId: 'tour_3',
          versionId: 'v1',
          currentStopIndex: 0,
          completedStops: [],
          status: 'in_progress',
        );

        final ids = storage.getInProgressTourIds();

        expect(ids, containsAll(['tour_1', 'tour_3']));
        expect(ids, isNot(contains('tour_2')));
      });

      test('saveProgress overwrites existing progress', () async {
        await storage.saveProgress(
          tourId: 'tour_1',
          versionId: 'v1',
          currentStopIndex: 1,
          completedStops: [0],
          status: 'in_progress',
        );

        await storage.saveProgress(
          tourId: 'tour_1',
          versionId: 'v1',
          currentStopIndex: 3,
          completedStops: [0, 1, 2],
          status: 'in_progress',
        );

        final progress = storage.getProgress('tour_1');
        expect(progress!['currentStopIndex'], equals(3));
        expect(progress['completedStops'], equals([0, 1, 2]));
      });
    });

    group('Settings', () {
      test('saveSetting stores value', () async {
        await storage.saveSetting('theme', 'dark');

        final theme = storage.getSetting<String>('theme');
        expect(theme, equals('dark'));
      });

      test('getSetting returns default when missing', () {
        final value = storage.getSetting<String>('missing', defaultValue: 'default');

        expect(value, equals('default'));
      });

      test('getSetting returns null when no default', () {
        final value = storage.getSetting<String>('missing');

        expect(value, isNull);
      });

      test('saveSetting overwrites existing value', () async {
        await storage.saveSetting('theme', 'light');
        await storage.saveSetting('theme', 'dark');

        final theme = storage.getSetting<String>('theme');
        expect(theme, equals('dark'));
      });

      test('settings support different types', () async {
        await storage.saveSetting('volume', 0.8);
        await storage.saveSetting('autoplay', true);
        await storage.saveSetting('maxDownloads', 5);

        expect(storage.getSetting<double>('volume'), equals(0.8));
        expect(storage.getSetting<bool>('autoplay'), isTrue);
        expect(storage.getSetting<int>('maxDownloads'), equals(5));
      });
    });

    group('Cleanup', () {
      test('cleanupExpired is callable', () async {
        // The fake implementation is a no-op, but verify it doesn't throw
        await expectLater(storage.cleanupExpired(), completes);
      });

      test('getCacheSize returns 0 for fake implementation', () async {
        final size = await storage.getCacheSize();

        expect(size, equals(0));
      });

      test('clearAll removes all data', () async {
        await storage.cacheTour(createTestTour(id: 'tour_1'));
        await storage.cacheVersion(createTestTourVersion(id: 'v1', tourId: 'tour_1'));
        await storage.cacheStops('tour_1', 'v1', createTestStops(count: 2));
        await storage.startDownload('tour_1', 'v1');
        await storage.completeDownload('tour_1', 1000);
        await storage.saveProgress(
          tourId: 'tour_1',
          versionId: 'v1',
          currentStopIndex: 1,
          completedStops: [0],
          status: 'in_progress',
        );
        await storage.saveSetting('theme', 'dark');

        await storage.clearAll();

        expect(storage.getCachedTour('tour_1'), isNull);
        expect(storage.getCachedVersion('tour_1', 'v1'), isNull);
        expect(storage.getCachedStops('tour_1', 'v1'), isNull);
        expect(storage.isDownloaded('tour_1'), isFalse);
        expect(storage.getProgress('tour_1'), isNull);
        expect(storage.getSetting<String>('theme'), isNull);
      });
    });

    group('Initialization', () {
      test('initialize is idempotent', () async {
        await storage.initialize();
        await storage.initialize();
        await storage.initialize();

        // Should not throw and storage should work
        await storage.cacheTour(createTestTour(id: 'tour_1'));
        expect(storage.getCachedTour('tour_1'), isNotNull);
      });

      test('close is callable', () async {
        await expectLater(storage.close(), completes);
      });
    });

    group('Edge Cases', () {
      test('updateDownloadProgress does nothing for nonexistent download', () async {
        await storage.updateDownloadProgress('nonexistent', 0.5);

        expect(storage.getDownloadStatus('nonexistent'), isNull);
      });

      test('completeDownload does nothing for nonexistent download', () async {
        await storage.completeDownload('nonexistent', 1000);

        expect(storage.getDownloadStatus('nonexistent'), isNull);
      });

      test('failDownload does nothing for nonexistent download', () async {
        await storage.failDownload('nonexistent', 'Error');

        expect(storage.getDownloadStatus('nonexistent'), isNull);
      });

      test('handles empty stops list', () async {
        await storage.cacheStops('tour_1', 'v1', []);

        final cached = storage.getCachedStops('tour_1', 'v1');
        expect(cached, isNotNull);
        expect(cached, isEmpty);
      });

      test('handles empty completed stops', () async {
        await storage.saveProgress(
          tourId: 'tour_1',
          versionId: 'v1',
          currentStopIndex: 0,
          completedStops: [],
          status: 'in_progress',
        );

        final progress = storage.getProgress('tour_1');
        expect(progress!['completedStops'], isEmpty);
      });
    });
  });
}
