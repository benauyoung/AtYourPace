import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:ayp_tour_guide/services/progress_service.dart';
import '../../helpers/test_helpers.mocks.dart';

/// Custom matcher to check if a map contains a specific key
Matcher mapContainsKey(String key) => predicate<Map<String, dynamic>>(
      (map) => map.containsKey(key),
      'contains key "$key"',
    );

/// Custom matcher to check if a map does not contain a specific key
Matcher mapNotContainsKey(String key) => predicate<Map<String, dynamic>>(
      (map) => !map.containsKey(key),
      'does not contain key "$key"',
    );

void main() {
  group('ProgressService', () {
    late ProgressService progressService;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockUsersCollection;
    late MockCollectionReference<Map<String, dynamic>> mockToursCollection;
    late MockCollectionReference<Map<String, dynamic>> mockProgressCollection;
    late MockDocumentReference<Map<String, dynamic>> mockUserDoc;
    late MockDocumentReference<Map<String, dynamic>> mockTourDoc;
    late MockDocumentReference<Map<String, dynamic>> mockProgressDoc;
    late MockDocumentSnapshot<Map<String, dynamic>> mockProgressSnapshot;
    late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
    late MockWriteBatch mockBatch;

    const testUserId = 'test_user_123';
    const testTourId = 'test_tour_456';

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockUsersCollection = MockCollectionReference();
      mockToursCollection = MockCollectionReference();
      mockProgressCollection = MockCollectionReference();
      mockUserDoc = MockDocumentReference();
      mockTourDoc = MockDocumentReference();
      mockProgressDoc = MockDocumentReference();
      mockProgressSnapshot = MockDocumentSnapshot();
      mockQuerySnapshot = MockQuerySnapshot();
      mockBatch = MockWriteBatch();

      // Setup collection paths
      when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
      when(mockFirestore.collection('tours')).thenReturn(mockToursCollection);

      when(mockUsersCollection.doc(testUserId)).thenReturn(mockUserDoc);
      when(mockToursCollection.doc(testTourId)).thenReturn(mockTourDoc);

      when(mockUserDoc.collection('progress')).thenReturn(mockProgressCollection);
      when(mockProgressCollection.doc(testTourId)).thenReturn(mockProgressDoc);

      when(mockFirestore.batch()).thenReturn(mockBatch);
      when(mockBatch.commit()).thenAnswer((_) async {});

      progressService = ProgressService(
        firestore: mockFirestore,
        userId: testUserId,
      );
    });

    group('saveProgress', () {
      test('saves progress with all fields', () async {
        when(mockProgressDoc.set(any, any)).thenAnswer((_) async {});

        await progressService.saveProgress(
          tourId: testTourId,
          currentStopIndex: 3,
          progressPercent: 60,
          totalStops: 5,
        );

        verify(mockProgressDoc.set(
          argThat(allOf(
            containsPair('tourId', testTourId),
            containsPair('currentStopIndex', 3),
            containsPair('progressPercent', 60),
            containsPair('totalStops', 5),
            containsPair('completed', false),
          )),
          argThat(isA<SetOptions>()),
        )).called(1);
      });

      test('saves progress without optional totalStops', () async {
        when(mockProgressDoc.set(any, any)).thenAnswer((_) async {});

        await progressService.saveProgress(
          tourId: testTourId,
          currentStopIndex: 2,
          progressPercent: 40,
        );

        verify(mockProgressDoc.set(
          argThat(allOf(
            containsPair('tourId', testTourId),
            containsPair('currentStopIndex', 2),
            containsPair('progressPercent', 40),
          )),
          any,
        )).called(1);
      });
    });

    group('markCompleted', () {
      test('marks tour as completed and increments stats', () async {
        await progressService.markCompleted(
          tourId: testTourId,
          durationSeconds: 3600,
        );

        verify(mockBatch.set(
          any,
          argThat(allOf(
            containsPair('completed', true),
            containsPair('progressPercent', 100),
            containsPair('durationSeconds', 3600),
          )),
          argThat(isA<SetOptions>()),
        )).called(1);

        verify(mockBatch.update(
          any,
          argThat(mapContainsKey('stats.completions')),
        )).called(1);

        verify(mockBatch.commit()).called(1);
      });

      test('marks completed without duration', () async {
        await progressService.markCompleted(tourId: testTourId);

        verify(mockBatch.set(
          any,
          argThat(allOf(
            containsPair('completed', true),
            containsPair('progressPercent', 100),
            mapNotContainsKey('durationSeconds'),
          )),
          any,
        )).called(1);
      });
    });

    group('getProgress', () {
      test('returns progress data when exists', () async {
        final testData = {
          'tourId': testTourId,
          'currentStopIndex': 2,
          'progressPercent': 50,
          'completed': false,
        };

        when(mockProgressDoc.get()).thenAnswer((_) async => mockProgressSnapshot);
        when(mockProgressSnapshot.exists).thenReturn(true);
        when(mockProgressSnapshot.data()).thenReturn(testData);

        final result = await progressService.getProgress(testTourId);

        expect(result, isNotNull);
        expect(result!['tourId'], equals(testTourId));
        expect(result['progressPercent'], equals(50));
      });

      test('returns null when progress does not exist', () async {
        when(mockProgressDoc.get()).thenAnswer((_) async => mockProgressSnapshot);
        when(mockProgressSnapshot.exists).thenReturn(false);

        final result = await progressService.getProgress(testTourId);

        expect(result, isNull);
      });
    });

    group('getCompletedTours', () {
      test('returns list of completed tours', () async {
        final mockDoc1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        final mockDoc2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();

        when(mockProgressCollection.where('completed', isEqualTo: true))
            .thenReturn(mockProgressCollection);
        when(mockProgressCollection.orderBy('completedAt', descending: true))
            .thenReturn(mockProgressCollection);
        when(mockProgressCollection.get()).thenAnswer((_) async => mockQuerySnapshot);

        when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
        when(mockDoc1.id).thenReturn('tour_1');
        when(mockDoc1.data()).thenReturn({
          'tourId': 'tour_1',
          'progressPercent': 100,
          'completed': true,
        });
        when(mockDoc2.id).thenReturn('tour_2');
        when(mockDoc2.data()).thenReturn({
          'tourId': 'tour_2',
          'progressPercent': 100,
          'completed': true,
        });

        final result = await progressService.getCompletedTours();

        expect(result.length, equals(2));
        expect(result[0]['id'], equals('tour_1'));
        expect(result[1]['id'], equals('tour_2'));
      });
    });

    group('getInProgressTours', () {
      test('returns list of in-progress tours', () async {
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

        when(mockProgressCollection.where('completed', isEqualTo: false))
            .thenReturn(mockProgressCollection);
        when(mockProgressCollection.orderBy('lastPlayedAt', descending: true))
            .thenReturn(mockProgressCollection);
        when(mockProgressCollection.get()).thenAnswer((_) async => mockQuerySnapshot);

        when(mockQuerySnapshot.docs).thenReturn([mockDoc]);
        when(mockDoc.id).thenReturn('tour_1');
        when(mockDoc.data()).thenReturn({
          'tourId': 'tour_1',
          'progressPercent': 50,
          'completed': false,
        });

        final result = await progressService.getInProgressTours();

        expect(result.length, equals(1));
        expect(result[0]['progressPercent'], equals(50));
      });
    });

    group('recordTourStart', () {
      test('increments play count for existing progress', () async {
        when(mockTourDoc.update(any)).thenAnswer((_) async {});
        when(mockProgressDoc.get()).thenAnswer((_) async => mockProgressSnapshot);
        when(mockProgressSnapshot.exists).thenReturn(true);

        await progressService.recordTourStart(testTourId);

        verify(mockTourDoc.update(any)).called(1);
      });

      test('creates initial progress when none exists', () async {
        when(mockTourDoc.update(any)).thenAnswer((_) async {});
        when(mockProgressDoc.get()).thenAnswer((_) async => mockProgressSnapshot);
        when(mockProgressSnapshot.exists).thenReturn(false);
        when(mockProgressDoc.set(any)).thenAnswer((_) async {});

        await progressService.recordTourStart(testTourId);

        verify(mockProgressDoc.set(
          argThat(allOf(
            containsPair('tourId', testTourId),
            containsPair('currentStopIndex', 0),
            containsPair('progressPercent', 0),
            containsPair('completed', false),
          )),
        )).called(1);
      });
    });

    group('recordTourDownload', () {
      test('increments download count', () async {
        when(mockTourDoc.update(any)).thenAnswer((_) async {});

        await progressService.recordTourDownload(testTourId);

        verify(mockTourDoc.update(any)).called(1);
      });
    });

    group('deleteProgress', () {
      test('deletes progress document', () async {
        when(mockProgressDoc.delete()).thenAnswer((_) async {});

        await progressService.deleteProgress(testTourId);

        verify(mockProgressDoc.delete()).called(1);
      });
    });

    group('clearAllProgress', () {
      test('deletes all progress documents', () async {
        final mockDoc1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        final mockDoc2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        final mockRef1 = MockDocumentReference<Map<String, dynamic>>();
        final mockRef2 = MockDocumentReference<Map<String, dynamic>>();

        when(mockProgressCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
        when(mockDoc1.reference).thenReturn(mockRef1);
        when(mockDoc2.reference).thenReturn(mockRef2);

        await progressService.clearAllProgress();

        verify(mockBatch.delete(mockRef1)).called(1);
        verify(mockBatch.delete(mockRef2)).called(1);
        verify(mockBatch.commit()).called(1);
      });
    });
  });
}
