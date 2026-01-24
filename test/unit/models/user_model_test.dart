import 'package:flutter_test/flutter_test.dart';

import 'package:ayp_tour_guide/data/models/user_model.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('UserModel', () {
    group('Serialization', () {
      test('fromJson creates model with required fields', () {
        final json = {
          'uid': 'user_123',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'role': 'user',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final user = UserModel.fromJson(json);

        expect(user.uid, equals('user_123'));
        expect(user.email, equals('test@example.com'));
        expect(user.displayName, equals('Test User'));
        expect(user.role, equals(UserRole.user));
      });

      test('fromJson handles optional fields', () {
        final json = {
          'uid': 'user_123',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'photoUrl': 'https://example.com/photo.jpg',
          'role': 'creator',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'creatorProfile': {
            'bio': 'Test bio',
            'verified': true,
            'totalTours': 5,
            'totalDownloads': 100,
          },
        };

        final user = UserModel.fromJson(json);

        expect(user.photoUrl, equals('https://example.com/photo.jpg'));
        expect(user.role, equals(UserRole.creator));
        expect(user.creatorProfile, isNotNull);
        expect(user.creatorProfile!.bio, equals('Test bio'));
        expect(user.creatorProfile!.verified, isTrue);
      });

      test('toJson serializes correctly', () {
        final user = createTestUser(
          uid: 'user_123',
          email: 'test@example.com',
          displayName: 'Test User',
          role: UserRole.user,
        );

        final json = user.toJson();

        expect(json['uid'], equals('user_123'));
        expect(json['email'], equals('test@example.com'));
        expect(json['displayName'], equals('Test User'));
        expect(json['role'], equals('user'));
      });

      test('toFirestore removes uid field', () {
        final user = createTestUser(uid: 'user_123');

        final firestoreData = user.toFirestore();

        expect(firestoreData.containsKey('uid'), isFalse);
        expect(firestoreData['email'], equals('test@example.com'));
      });

      test('toJson includes key fields', () {
        final original = createTestCreator(uid: 'creator_1');

        // Note: Direct toJson() with freezed keeps nested freezed objects as class instances.
        // We verify the JSON output has the expected top-level fields.
        final json = original.toJson();

        expect(json['uid'], equals(original.uid));
        expect(json['email'], equals(original.email));
        expect(json['role'], equals('creator'));
        expect(json['creatorProfile'], isNotNull);
      });
    });

    group('Enum Handling', () {
      test('all UserRole values serialize correctly', () {
        for (final role in UserRole.values) {
          final user = createTestUser(role: role);
          final json = user.toJson();

          // Verify the role is serialized as its name
          expect(json['role'], equals(role.name));
        }
      });

      test('UserRole serializes as string', () {
        expect(createTestUser(role: UserRole.user).toJson()['role'], equals('user'));
        expect(createTestUser(role: UserRole.creator).toJson()['role'], equals('creator'));
        expect(createTestUser(role: UserRole.admin).toJson()['role'], equals('admin'));
      });
    });

    group('Computed Properties', () {
      test('isCreator returns true for creator role', () {
        final creator = createTestUser(role: UserRole.creator);
        final user = createTestUser(role: UserRole.user);

        expect(creator.isCreator, isTrue);
        expect(user.isCreator, isFalse);
      });

      test('isCreator returns true for admin role', () {
        final admin = createTestUser(role: UserRole.admin);

        expect(admin.isCreator, isTrue);
      });

      test('isAdmin returns true only for admin role', () {
        final admin = createTestUser(role: UserRole.admin);
        final creator = createTestUser(role: UserRole.creator);
        final user = createTestUser(role: UserRole.user);

        expect(admin.isAdmin, isTrue);
        expect(creator.isAdmin, isFalse);
        expect(user.isAdmin, isFalse);
      });
    });
  });

  group('CreatorProfile', () {
    test('default values', () {
      const profile = CreatorProfile();

      expect(profile.bio, equals(''));
      expect(profile.verified, isFalse);
      expect(profile.totalTours, equals(0));
      expect(profile.totalDownloads, equals(0));
    });

    test('fromJson parses correctly', () {
      final json = {
        'bio': 'I create amazing tours!',
        'verified': true,
        'totalTours': 10,
        'totalDownloads': 500,
      };

      final profile = CreatorProfile.fromJson(json);

      expect(profile.bio, equals('I create amazing tours!'));
      expect(profile.verified, isTrue);
      expect(profile.totalTours, equals(10));
      expect(profile.totalDownloads, equals(500));
    });

    test('serializes correctly', () {
      const profile = CreatorProfile(
        bio: 'Test bio',
        verified: true,
        totalTours: 5,
        totalDownloads: 100,
      );

      final json = profile.toJson();

      expect(json['bio'], equals('Test bio'));
      expect(json['verified'], isTrue);
      expect(json['totalTours'], equals(5));
      expect(json['totalDownloads'], equals(100));
    });
  });

  group('UserPreferences', () {
    test('default values', () {
      const prefs = UserPreferences();

      expect(prefs.autoPlayAudio, isTrue);
      expect(prefs.triggerMode, equals(TriggerMode.geofence));
      expect(prefs.offlineEnabled, isTrue);
      expect(prefs.preferredVoice, isNull);
    });

    test('fromJson parses correctly', () {
      final json = {
        'autoPlayAudio': false,
        'triggerMode': 'manual',
        'offlineEnabled': false,
        'preferredVoice': 'voice_1',
      };

      final prefs = UserPreferences.fromJson(json);

      expect(prefs.autoPlayAudio, isFalse);
      expect(prefs.triggerMode, equals(TriggerMode.manual));
      expect(prefs.offlineEnabled, isFalse);
      expect(prefs.preferredVoice, equals('voice_1'));
    });

    test('TriggerMode enum serializes correctly', () {
      const geofence = UserPreferences(triggerMode: TriggerMode.geofence);
      const manual = UserPreferences(triggerMode: TriggerMode.manual);

      expect(geofence.toJson()['triggerMode'], equals('geofence'));
      expect(manual.toJson()['triggerMode'], equals('manual'));
    });

    test('preferences included in user serialization', () {
      final user = createTestUser();
      final json = user.toJson();

      // Note: Freezed returns the UserPreferences object, not a Map directly from toJson.
      // In real Firestore usage, the converter handles this.
      final prefs = json['preferences'];
      expect(prefs, isNotNull);
      // Access via UserPreferences if it's the freezed object
      if (prefs is UserPreferences) {
        expect(prefs.autoPlayAudio, isTrue);
      } else if (prefs is Map) {
        expect(prefs['autoPlayAudio'], isTrue);
      }
    });
  });

  group('TimestampConverter', () {
    const converter = TimestampConverter();

    test('fromJson handles ISO string', () {
      final isoString = '2025-01-15T12:00:00.000Z';

      final result = converter.fromJson(isoString);

      expect(result.year, equals(2025));
      expect(result.month, equals(1));
      expect(result.day, equals(15));
    });

    test('fromJson handles milliseconds', () {
      final millis = DateTime(2025, 1, 15, 12, 0, 0).millisecondsSinceEpoch;

      final result = converter.fromJson(millis);

      expect(result.year, equals(2025));
      expect(result.month, equals(1));
      expect(result.day, equals(15));
    });

    test('fromJson returns now for unsupported input type', () {
      // For unsupported types (not Timestamp, String, or int), returns now
      final before = DateTime.now();
      final result = converter.fromJson({'some': 'map'}); // Map is not a supported type
      final after = DateTime.now();

      expect(result.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(result.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('fromJson throws FormatException for invalid string', () {
      // Invalid date strings throw FormatException from DateTime.parse
      expect(() => converter.fromJson('invalid'), throwsFormatException);
    });
  });

  group('NullableTimestampConverter', () {
    const converter = NullableTimestampConverter();

    test('fromJson returns null for null input', () {
      final result = converter.fromJson(null);

      expect(result, isNull);
    });

    test('fromJson handles ISO string', () {
      final result = converter.fromJson('2025-01-15T12:00:00.000Z');

      expect(result, isNotNull);
      expect(result!.year, equals(2025));
    });

    test('toJson returns null for null date', () {
      final result = converter.toJson(null);

      expect(result, isNull);
    });
  });

  group('Test Helpers', () {
    test('createTestUser creates valid user', () {
      final user = createTestUser();

      expect(user.uid, isNotEmpty);
      expect(user.email, equals('test@example.com'));
      expect(user.displayName, equals('Test User'));
      expect(user.role, equals(UserRole.user));
    });

    test('createTestCreator creates creator user', () {
      final creator = createTestCreator();

      expect(creator.role, equals(UserRole.creator));
      expect(creator.creatorProfile, isNotNull);
    });

    test('createTestAdmin creates admin user', () {
      final admin = createTestAdmin();

      expect(admin.role, equals(UserRole.admin));
      expect(admin.isAdmin, isTrue);
    });
  });
}
