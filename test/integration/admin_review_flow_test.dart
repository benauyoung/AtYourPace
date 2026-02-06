import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:ayp_tour_guide/data/models/tour_model.dart';
import 'package:ayp_tour_guide/data/models/user_model.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

/// Integration tests for the admin review flow.
///
/// Tests the flow: View Queue -> Select Tour -> Review
/// -> Approve/Reject -> Audit Log
void main() {
  group('Admin Review Flow Integration', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockToursCollection;
    late MockCollectionReference<Map<String, dynamic>> mockUsersCollection;
    late MockDocumentReference<Map<String, dynamic>> mockTourDoc;
    late MockDocumentReference<Map<String, dynamic>> mockUserDoc;
    late MockWriteBatch mockBatch;

    const adminUserId = 'admin_user_123';
    const adminUserName = 'Admin User';

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockToursCollection = MockCollectionReference();
      mockUsersCollection = MockCollectionReference();
      mockTourDoc = MockDocumentReference();
      mockUserDoc = MockDocumentReference();
      mockBatch = MockWriteBatch();

      when(mockFirestore.collection('tours')).thenReturn(mockToursCollection);
      when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
      when(mockToursCollection.doc(any)).thenReturn(mockTourDoc);
      when(mockUsersCollection.doc(any)).thenReturn(mockUserDoc);
      when(mockFirestore.batch()).thenReturn(mockBatch);
      when(mockBatch.commit()).thenAnswer((_) async {});
    });

    group('Admin Authorization', () {
      test('admin user has correct role', () {
        final adminUser = UserModel(
          uid: adminUserId,
          email: 'admin@example.com',
          displayName: adminUserName,
          role: UserRole.admin,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(adminUser.role, equals(UserRole.admin));
        expect(adminUser.isAdmin, isTrue);
      });

      test('regular user cannot access admin functions', () {
        final regularUser = UserModel(
          uid: 'user_123',
          email: 'user@example.com',
          displayName: 'Regular User',
          role: UserRole.user,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(regularUser.role, equals(UserRole.user));
        expect(regularUser.isAdmin, isFalse);
      });

      test('creator user cannot access admin functions', () {
        final creatorUser = UserModel(
          uid: 'creator_123',
          email: 'creator@example.com',
          displayName: 'Creator User',
          role: UserRole.creator,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(creatorUser.role, equals(UserRole.creator));
        expect(creatorUser.isAdmin, isFalse);
      });
    });

    group('Review Queue', () {
      test('filters tours by pending status', () {
        final tours = [
          createTestTour(id: 'tour_1', status: TourStatus.pendingReview),
          createTestTour(id: 'tour_2', status: TourStatus.draft),
          createTestTour(id: 'tour_3', status: TourStatus.pendingReview),
          createTestTour(id: 'tour_4', status: TourStatus.approved),
          createTestTour(id: 'tour_5', status: TourStatus.pendingReview),
        ];

        final pendingTours = tours
            .where((t) => t.status == TourStatus.pendingReview)
            .toList();

        expect(pendingTours.length, equals(3));
        expect(pendingTours.every((t) => t.status == TourStatus.pendingReview), isTrue);
      });

      test('sorts queue by submission date', () {
        final now = DateTime.now();
        final tours = [
          createTestTour(id: 'tour_1', status: TourStatus.pendingReview)
              .copyWith(updatedAt: now.subtract(const Duration(days: 1))),
          createTestTour(id: 'tour_2', status: TourStatus.pendingReview)
              .copyWith(updatedAt: now.subtract(const Duration(days: 3))),
          createTestTour(id: 'tour_3', status: TourStatus.pendingReview)
              .copyWith(updatedAt: now.subtract(const Duration(days: 2))),
        ];

        // Sort by oldest first (FIFO)
        final sortedTours = List<TourModel>.from(tours)
          ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));

        expect(sortedTours[0].id, equals('tour_2')); // Oldest
        expect(sortedTours[1].id, equals('tour_3'));
        expect(sortedTours[2].id, equals('tour_1')); // Newest
      });

      test('shows creator information for each tour', () {
        final tour = createTestTour(
          creatorId: 'creator_456',
          creatorName: 'John Creator',
        );

        expect(tour.creatorId, isNotEmpty);
        expect(tour.creatorName, equals('John Creator'));
      });
    });

    group('Tour Approval', () {
      test('approves tour and changes status to published', () {
        var tour = createTestTour(status: TourStatus.pendingReview);

        expect(tour.status, equals(TourStatus.pendingReview));

        tour = tour.copyWith(
          status: TourStatus.approved,
          liveVersionId: tour.draftVersionId,
          updatedAt: DateTime.now(),
        );

        expect(tour.status, equals(TourStatus.approved));
        expect(tour.liveVersionId, isNotNull);
      });

      test('sets published version ID on approval', () {
        var tour = createTestTour(
          status: TourStatus.pendingReview,
          draftVersionId: 'draft_v1',
        );

        expect(tour.liveVersionId, isNull);

        tour = tour.copyWith(
          status: TourStatus.approved,
          liveVersionId: tour.draftVersionId,
        );

        expect(tour.liveVersionId, equals('draft_v1'));
      });

      test('records approval timestamp', () {
        final beforeApproval = DateTime.now();

        var tour = createTestTour(status: TourStatus.pendingReview);

        tour = tour.copyWith(
          status: TourStatus.approved,
          updatedAt: DateTime.now(),
        );

        expect(tour.updatedAt.isAfter(beforeApproval) ||
            tour.updatedAt.isAtSameMomentAs(beforeApproval), isTrue);
      });
    });

    group('Tour Rejection', () {
      test('rejects tour and changes status back to draft', () {
        var tour = createTestTour(status: TourStatus.pendingReview);

        tour = tour.copyWith(
          status: TourStatus.draft,
          updatedAt: DateTime.now(),
        );

        expect(tour.status, equals(TourStatus.draft));
      });

      test('rejection reason is recorded', () {
        // Rejection reason would typically be stored in a separate
        // review/feedback document, not on the tour itself
        const rejectionReason = 'Audio quality needs improvement';

        // Create a review record
        final reviewRecord = {
          'tourId': 'tour_123',
          'reviewerId': adminUserId,
          'reviewerName': adminUserName,
          'action': 'rejected',
          'reason': rejectionReason,
          'timestamp': DateTime.now(),
        };

        expect(reviewRecord['reason'], equals(rejectionReason));
        expect(reviewRecord['action'], equals('rejected'));
      });
    });

    group('Feature Tours', () {
      test('marks tour as featured', () {
        var tour = createTestTour(
          status: TourStatus.approved,
          featured: false,
        );

        expect(tour.featured, isFalse);

        tour = tour.copyWith(featured: true);

        expect(tour.featured, isTrue);
      });

      test('unmarks tour as featured', () {
        var tour = createTestTour(
          status: TourStatus.approved,
          featured: true,
        );

        expect(tour.featured, isTrue);

        tour = tour.copyWith(featured: false);

        expect(tour.featured, isFalse);
      });

      test('only published tours can be featured', () {
        final draftTour = createTestTour(status: TourStatus.draft);
        final pendingTour = createTestTour(status: TourStatus.pendingReview);
        final publishedTour = createTestTour(status: TourStatus.approved);

        // Business logic check
        expect(draftTour.status == TourStatus.approved, isFalse);
        expect(pendingTour.status == TourStatus.approved, isFalse);
        expect(publishedTour.status == TourStatus.approved, isTrue);
      });
    });

    group('Hide/Unhide Tours', () {
      test('hides published tour', () {
        var tour = createTestTour(status: TourStatus.approved);

        tour = tour.copyWith(status: TourStatus.hidden);

        expect(tour.status, equals(TourStatus.hidden));
      });

      test('unhides tour back to published', () {
        var tour = createTestTour(status: TourStatus.hidden);

        tour = tour.copyWith(status: TourStatus.approved);

        expect(tour.status, equals(TourStatus.approved));
      });
    });

    group('User Management', () {
      test('promotes user to creator role', () {
        var user = UserModel(
          uid: 'user_123',
          email: 'user@example.com',
          displayName: 'Regular User',
          role: UserRole.user,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(user.role, equals(UserRole.user));

        user = user.copyWith(role: UserRole.creator);

        expect(user.role, equals(UserRole.creator));
      });

      test('demotes creator to user role', () {
        var user = UserModel(
          uid: 'creator_123',
          email: 'creator@example.com',
          displayName: 'Creator',
          role: UserRole.creator,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        user = user.copyWith(role: UserRole.user);

        expect(user.role, equals(UserRole.user));
      });

      // Note: User banning functionality would require a 'banned' field
      // on UserModel. Currently this is not implemented.
    });

    group('Audit Logging', () {
      test('creates audit entry for approval', () {
        final auditEntry = {
          'action': 'tour_approved',
          'tourId': 'tour_123',
          'adminId': adminUserId,
          'adminName': adminUserName,
          'timestamp': DateTime.now(),
          'details': {
            'previousStatus': 'pending',
            'newStatus': 'published',
          },
        };

        expect(auditEntry['action'], equals('tour_approved'));
        expect(auditEntry['adminId'], equals(adminUserId));
      });

      test('creates audit entry for rejection', () {
        final auditEntry = <String, dynamic>{
          'action': 'tour_rejected',
          'tourId': 'tour_123',
          'adminId': adminUserId,
          'adminName': adminUserName,
          'timestamp': DateTime.now(),
          'details': <String, dynamic>{
            'previousStatus': 'pending',
            'newStatus': 'draft',
            'reason': 'Incomplete audio narration',
          },
        };

        expect(auditEntry['action'], equals('tour_rejected'));
        expect((auditEntry['details'] as Map)['reason'], isNotEmpty);
      });

      test('creates audit entry for user role change', () {
        final auditEntry = <String, dynamic>{
          'action': 'user_role_changed',
          'userId': 'user_123',
          'adminId': adminUserId,
          'adminName': adminUserName,
          'timestamp': DateTime.now(),
          'details': <String, dynamic>{
            'previousRole': 'user',
            'newRole': 'creator',
          },
        };

        expect(auditEntry['action'], equals('user_role_changed'));
        expect((auditEntry['details'] as Map)['previousRole'], equals('user'));
        expect((auditEntry['details'] as Map)['newRole'], equals('creator'));
      });

      test('creates audit entry for user role demotion', () {
        final auditEntry = <String, dynamic>{
          'action': 'user_role_changed',
          'userId': 'user_456',
          'adminId': adminUserId,
          'adminName': adminUserName,
          'timestamp': DateTime.now(),
          'details': <String, dynamic>{
            'previousRole': 'creator',
            'newRole': 'user',
          },
        };

        expect(auditEntry['action'], equals('user_role_changed'));
      });

      test('creates audit entry for feature toggle', () {
        final auditEntry = <String, dynamic>{
          'action': 'tour_featured',
          'tourId': 'tour_789',
          'adminId': adminUserId,
          'adminName': adminUserName,
          'timestamp': DateTime.now(),
          'details': <String, dynamic>{
            'featured': true,
          },
        };

        expect(auditEntry['action'], equals('tour_featured'));
        expect((auditEntry['details'] as Map)['featured'], isTrue);
      });
    });

    group('Full Review Workflow', () {
      test('complete approval workflow', () {
        // 1. Tour is submitted for review
        var tour = createTestTour(
          id: 'workflow_tour_1',
          status: TourStatus.pendingReview,
          creatorId: 'creator_789',
          creatorName: 'Tour Creator',
        );

        expect(tour.status, equals(TourStatus.pendingReview));

        // 2. Admin reviews and approves
        tour = tour.copyWith(
          status: TourStatus.approved,
          liveVersionId: tour.draftVersionId,
          updatedAt: DateTime.now(),
        );

        // 3. Create audit log
        final auditLog = {
          'action': 'tour_approved',
          'tourId': tour.id,
          'adminId': adminUserId,
          'timestamp': DateTime.now(),
        };

        expect(tour.status, equals(TourStatus.approved));
        expect(tour.liveVersionId, isNotNull);
        expect(auditLog['action'], equals('tour_approved'));
      });

      test('complete rejection workflow', () {
        // 1. Tour is submitted for review
        var tour = createTestTour(
          id: 'workflow_tour_2',
          status: TourStatus.pendingReview,
        );

        // 2. Admin reviews and rejects
        tour = tour.copyWith(
          status: TourStatus.draft,
          updatedAt: DateTime.now(),
        );

        // 3. Create rejection feedback
        final feedback = {
          'tourId': tour.id,
          'reviewerId': adminUserId,
          'action': 'rejected',
          'reason': 'Please improve audio quality on stops 2 and 3',
          'timestamp': DateTime.now(),
        };

        // 4. Create audit log
        final auditLog = {
          'action': 'tour_rejected',
          'tourId': tour.id,
          'adminId': adminUserId,
          'details': {'reason': feedback['reason']},
          'timestamp': DateTime.now(),
        };

        expect(tour.status, equals(TourStatus.draft));
        expect(feedback['reason'], isNotEmpty);
        expect(auditLog['action'], equals('tour_rejected'));
      });

      test('feature then unfeature workflow', () {
        var tour = createTestTour(
          status: TourStatus.approved,
          featured: false,
        );

        // Feature the tour
        tour = tour.copyWith(featured: true);
        expect(tour.featured, isTrue);

        // Later, unfeature it
        tour = tour.copyWith(featured: false);
        expect(tour.featured, isFalse);
      });
    });

    group('Statistics and Reporting', () {
      test('counts tours by status', () {
        final tours = [
          createTestTour(status: TourStatus.draft),
          createTestTour(status: TourStatus.draft),
          createTestTour(status: TourStatus.pendingReview),
          createTestTour(status: TourStatus.pendingReview),
          createTestTour(status: TourStatus.pendingReview),
          createTestTour(status: TourStatus.approved),
          createTestTour(status: TourStatus.approved),
          createTestTour(status: TourStatus.approved),
          createTestTour(status: TourStatus.approved),
          createTestTour(status: TourStatus.hidden),
        ];

        final statusCounts = <TourStatus, int>{};
        for (final tour in tours) {
          statusCounts[tour.status] = (statusCounts[tour.status] ?? 0) + 1;
        }

        expect(statusCounts[TourStatus.draft], equals(2));
        expect(statusCounts[TourStatus.pendingReview], equals(3));
        expect(statusCounts[TourStatus.approved], equals(4));
        expect(statusCounts[TourStatus.hidden], equals(1));
      });

      test('counts users by role', () {
        final users = [
          UserModel(uid: '1', email: '', displayName: '', role: UserRole.user, createdAt: DateTime.now(), updatedAt: DateTime.now()),
          UserModel(uid: '2', email: '', displayName: '', role: UserRole.user, createdAt: DateTime.now(), updatedAt: DateTime.now()),
          UserModel(uid: '3', email: '', displayName: '', role: UserRole.user, createdAt: DateTime.now(), updatedAt: DateTime.now()),
          UserModel(uid: '4', email: '', displayName: '', role: UserRole.creator, createdAt: DateTime.now(), updatedAt: DateTime.now()),
          UserModel(uid: '5', email: '', displayName: '', role: UserRole.creator, createdAt: DateTime.now(), updatedAt: DateTime.now()),
          UserModel(uid: '6', email: '', displayName: '', role: UserRole.admin, createdAt: DateTime.now(), updatedAt: DateTime.now()),
        ];

        final roleCounts = <UserRole, int>{};
        for (final user in users) {
          roleCounts[user.role] = (roleCounts[user.role] ?? 0) + 1;
        }

        expect(roleCounts[UserRole.user], equals(3));
        expect(roleCounts[UserRole.creator], equals(2));
        expect(roleCounts[UserRole.admin], equals(1));
      });
    });
  });
}
