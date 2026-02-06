import 'package:flutter_test/flutter_test.dart';

import 'package:ayp_tour_guide/services/connectivity_service.dart';

void main() {
  group('ConnectivityStatus', () {
    test('has all expected values', () {
      expect(ConnectivityStatus.values, containsAll([
        ConnectivityStatus.online,
        ConnectivityStatus.offline,
        ConnectivityStatus.unknown,
      ]));
    });
  });

  group('SyncItemType', () {
    test('has all expected values', () {
      expect(SyncItemType.values, containsAll([
        SyncItemType.progress,
        SyncItemType.tourStart,
        SyncItemType.tourComplete,
        SyncItemType.review,
      ]));
    });
  });

  group('PendingSyncItem', () {
    test('creates with required fields', () {
      final item = PendingSyncItem(
        id: 'sync_1',
        type: SyncItemType.progress,
        data: {'tourId': 'tour_1', 'userId': 'user_1'},
        createdAt: DateTime.now(),
      );

      expect(item.id, equals('sync_1'));
      expect(item.type, equals(SyncItemType.progress));
      expect(item.data['tourId'], equals('tour_1'));
      expect(item.retryCount, equals(0));
    });

    test('toJson serializes correctly', () {
      final createdAt = DateTime(2025, 1, 15, 12, 0, 0);
      final item = PendingSyncItem(
        id: 'sync_1',
        type: SyncItemType.progress,
        data: {'tourId': 'tour_1'},
        createdAt: createdAt,
        retryCount: 2,
      );

      final json = item.toJson();

      expect(json['id'], equals('sync_1'));
      expect(json['type'], equals('progress'));
      expect(json['data'], equals({'tourId': 'tour_1'}));
      expect(json['createdAt'], equals(createdAt.toIso8601String()));
      expect(json['retryCount'], equals(2));
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'sync_1',
        'type': 'tourStart',
        'data': {'tourId': 'tour_1', 'userId': 'user_1'},
        'createdAt': '2025-01-15T12:00:00.000',
        'retryCount': 1,
      };

      final item = PendingSyncItem.fromJson(json);

      expect(item.id, equals('sync_1'));
      expect(item.type, equals(SyncItemType.tourStart));
      expect(item.data['tourId'], equals('tour_1'));
      expect(item.retryCount, equals(1));
    });

    test('fromJson handles missing retryCount', () {
      final json = {
        'id': 'sync_1',
        'type': 'review',
        'data': {'tourId': 'tour_1'},
        'createdAt': '2025-01-15T12:00:00.000',
      };

      final item = PendingSyncItem.fromJson(json);

      expect(item.retryCount, equals(0));
    });

    test('incrementRetry creates new item with incremented count', () {
      final original = PendingSyncItem(
        id: 'sync_1',
        type: SyncItemType.progress,
        data: {'tourId': 'tour_1'},
        createdAt: DateTime.now(),
        retryCount: 1,
      );

      final incremented = original.incrementRetry();

      expect(incremented.id, equals(original.id));
      expect(incremented.type, equals(original.type));
      expect(incremented.data, equals(original.data));
      expect(incremented.retryCount, equals(2));
    });

    test('roundtrip serialization preserves data', () {
      final original = PendingSyncItem(
        id: 'sync_1',
        type: SyncItemType.tourComplete,
        data: {'tourId': 'tour_1', 'userId': 'user_1', 'durationSeconds': 3600},
        createdAt: DateTime(2025, 1, 15, 12, 0, 0),
        retryCount: 3,
      );

      final json = original.toJson();
      final restored = PendingSyncItem.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.type, equals(original.type));
      expect(restored.data, equals(original.data));
      expect(restored.retryCount, equals(original.retryCount));
    });
  });

  group('SyncResult', () {
    test('creates with required fields', () {
      final result = SyncResult(synced: 5, failed: 1, remaining: 3);

      expect(result.synced, equals(5));
      expect(result.failed, equals(1));
      expect(result.remaining, equals(3));
    });

    test('hasFailures returns true when failed > 0', () {
      final withFailures = SyncResult(synced: 5, failed: 2, remaining: 0);
      final noFailures = SyncResult(synced: 5, failed: 0, remaining: 0);

      expect(withFailures.hasFailures, isTrue);
      expect(noFailures.hasFailures, isFalse);
    });

    test('hasPending returns true when remaining > 0', () {
      final withPending = SyncResult(synced: 5, failed: 0, remaining: 3);
      final noPending = SyncResult(synced: 5, failed: 0, remaining: 0);

      expect(withPending.hasPending, isTrue);
      expect(noPending.hasPending, isFalse);
    });

    test('isComplete returns true when remaining and failed are 0', () {
      final complete = SyncResult(synced: 10, failed: 0, remaining: 0);
      final withFailures = SyncResult(synced: 8, failed: 2, remaining: 0);
      final withPending = SyncResult(synced: 7, failed: 0, remaining: 3);

      expect(complete.isComplete, isTrue);
      expect(withFailures.isComplete, isFalse);
      expect(withPending.isComplete, isFalse);
    });

    test('toString returns readable format', () {
      final result = SyncResult(synced: 5, failed: 1, remaining: 3);

      expect(result.toString(), equals('SyncResult(synced: 5, failed: 1, remaining: 3)'));
    });
  });

  group('Sync Item Type Serialization', () {
    test('all SyncItemType values serialize correctly', () {
      for (final type in SyncItemType.values) {
        final item = PendingSyncItem(
          id: 'test',
          type: type,
          data: {},
          createdAt: DateTime.now(),
        );

        final json = item.toJson();
        final restored = PendingSyncItem.fromJson(json);

        expect(restored.type, equals(type));
      }
    });

    test('type serializes as name string', () {
      expect(
        PendingSyncItem(
          id: 'test',
          type: SyncItemType.progress,
          data: {},
          createdAt: DateTime.now(),
        ).toJson()['type'],
        equals('progress'),
      );

      expect(
        PendingSyncItem(
          id: 'test',
          type: SyncItemType.tourStart,
          data: {},
          createdAt: DateTime.now(),
        ).toJson()['type'],
        equals('tourStart'),
      );

      expect(
        PendingSyncItem(
          id: 'test',
          type: SyncItemType.tourComplete,
          data: {},
          createdAt: DateTime.now(),
        ).toJson()['type'],
        equals('tourComplete'),
      );

      expect(
        PendingSyncItem(
          id: 'test',
          type: SyncItemType.review,
          data: {},
          createdAt: DateTime.now(),
        ).toJson()['type'],
        equals('review'),
      );
    });
  });

  group('Data Structure', () {
    test('progress sync item data structure', () {
      final item = PendingSyncItem(
        id: 'user_1_tour_1_progress_123',
        type: SyncItemType.progress,
        data: {
          'tourId': 'tour_1',
          'userId': 'user_1',
          'currentStopIndex': 3,
          'progressPercent': 60,
          'totalStops': 5,
        },
        createdAt: DateTime.now(),
      );

      expect(item.data['tourId'], isNotNull);
      expect(item.data['userId'], isNotNull);
      expect(item.data['currentStopIndex'], equals(3));
      expect(item.data['progressPercent'], equals(60));
    });

    test('tour start sync item data structure', () {
      final item = PendingSyncItem(
        id: 'user_1_tour_1_start_123',
        type: SyncItemType.tourStart,
        data: {
          'tourId': 'tour_1',
          'userId': 'user_1',
        },
        createdAt: DateTime.now(),
      );

      expect(item.data['tourId'], isNotNull);
      expect(item.data['userId'], isNotNull);
    });

    test('tour complete sync item data structure', () {
      final item = PendingSyncItem(
        id: 'user_1_tour_1_complete_123',
        type: SyncItemType.tourComplete,
        data: {
          'tourId': 'tour_1',
          'userId': 'user_1',
          'durationSeconds': 3600,
        },
        createdAt: DateTime.now(),
      );

      expect(item.data['tourId'], isNotNull);
      expect(item.data['userId'], isNotNull);
      expect(item.data['durationSeconds'], equals(3600));
    });

    test('review sync item data structure', () {
      final item = PendingSyncItem(
        id: 'user_1_tour_1_review_123',
        type: SyncItemType.review,
        data: {
          'tourId': 'tour_1',
          'userId': 'user_1',
          'userName': 'Test User',
          'rating': 5,
          'comment': 'Great tour!',
        },
        createdAt: DateTime.now(),
      );

      expect(item.data['tourId'], isNotNull);
      expect(item.data['userId'], isNotNull);
      expect(item.data['userName'], equals('Test User'));
      expect(item.data['rating'], equals(5));
      expect(item.data['comment'], equals('Great tour!'));
    });
  });
}
