import 'package:flutter_test/flutter_test.dart';

import 'package:ayp_tour_guide/data/models/voice_generation_model.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('VoiceGenerationModel', () {
    group('Serialization', () {
      test('fromJson creates model with required fields', () {
        final json = {
          'id': 'voice_gen_1',
          'stopId': 'stop_1',
          'tourId': 'tour_1',
          'script': 'Welcome to the Eiffel Tower',
          'voiceId': 'voice_sophie',
          'voiceName': 'Sophie',
          'status': 'pending',
          'regenerationCount': 0,
          'history': [],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final voiceGen = VoiceGenerationModel.fromJson(json);

        expect(voiceGen.id, equals('voice_gen_1'));
        expect(voiceGen.stopId, equals('stop_1'));
        expect(voiceGen.tourId, equals('tour_1'));
        expect(voiceGen.script, equals('Welcome to the Eiffel Tower'));
        expect(voiceGen.voiceId, equals('voice_sophie'));
        expect(voiceGen.voiceName, equals('Sophie'));
        expect(voiceGen.status, equals(VoiceGenerationStatus.pending));
      });

      test('fromJson handles completed generation', () {
        final json = {
          'id': 'voice_gen_1',
          'stopId': 'stop_1',
          'tourId': 'tour_1',
          'script': 'Welcome to the Eiffel Tower',
          'voiceId': 'voice_sophie',
          'voiceName': 'Sophie',
          'audioUrl': 'https://storage.example.com/audio.mp3',
          'audioDuration': 120,
          'status': 'completed',
          'regenerationCount': 0,
          'history': [],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final voiceGen = VoiceGenerationModel.fromJson(json);

        expect(voiceGen.status, equals(VoiceGenerationStatus.completed));
        expect(voiceGen.audioUrl, equals('https://storage.example.com/audio.mp3'));
        expect(voiceGen.audioDuration, equals(120));
      });

      test('fromJson handles failed generation', () {
        final json = {
          'id': 'voice_gen_1',
          'stopId': 'stop_1',
          'tourId': 'tour_1',
          'script': 'Welcome to the Eiffel Tower',
          'voiceId': 'voice_sophie',
          'voiceName': 'Sophie',
          'status': 'failed',
          'errorMessage': 'API rate limit exceeded',
          'regenerationCount': 1,
          'history': [],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final voiceGen = VoiceGenerationModel.fromJson(json);

        expect(voiceGen.status, equals(VoiceGenerationStatus.failed));
        expect(voiceGen.errorMessage, equals('API rate limit exceeded'));
      });

      test('toJson serializes correctly', () {
        final voiceGen = createTestVoiceGeneration(
          id: 'voice_gen_1',
          stopId: 'stop_1',
          script: 'Test script',
          voiceId: 'voice_sophie',
        );

        final json = voiceGen.toJson();

        expect(json['id'], equals('voice_gen_1'));
        expect(json['stopId'], equals('stop_1'));
        expect(json['script'], equals('Test script'));
        expect(json['voiceId'], equals('voice_sophie'));
      });

      test('toFirestore removes id field', () {
        final voiceGen = createTestVoiceGeneration(id: 'voice_gen_1');

        final firestoreData = voiceGen.toFirestore();

        expect(firestoreData.containsKey('id'), isFalse);
        expect(firestoreData['stopId'], equals('stop_1'));
      });
    });

    group('Status Properties', () {
      test('isCompleted returns true for completed status', () {
        final completed = createTestVoiceGeneration(status: VoiceGenerationStatus.completed);
        expect(completed.isCompleted, isTrue);
      });

      test('isFailed returns true for failed status', () {
        final failed = createTestVoiceGeneration(status: VoiceGenerationStatus.failed);
        expect(failed.isFailed, isTrue);
      });

      test('isProcessing returns true for processing status', () {
        final processing = createTestVoiceGeneration(status: VoiceGenerationStatus.processing);
        expect(processing.isProcessing, isTrue);
      });

      test('isPending returns true for pending status', () {
        final pending = createTestVoiceGeneration(status: VoiceGenerationStatus.pending);
        expect(pending.isPending, isTrue);
      });

      test('hasAudio returns true when audio available and completed', () {
        final withAudio = createTestVoiceGeneration(
          status: VoiceGenerationStatus.completed,
          audioUrl: 'https://example.com/audio.mp3',
        );
        final pendingWithUrl = createTestVoiceGeneration(
          status: VoiceGenerationStatus.pending,
          audioUrl: 'https://example.com/audio.mp3',
        );
        final completedNoUrl = createTestVoiceGeneration(
          status: VoiceGenerationStatus.completed,
        );

        expect(withAudio.hasAudio, isTrue);
        expect(pendingWithUrl.hasAudio, isFalse);
        expect(completedNoUrl.hasAudio, isFalse);
      });

      test('wasRegenerated returns true when regenerationCount > 0', () {
        final regenerated = createTestVoiceGeneration(regenerationCount: 1);
        final original = createTestVoiceGeneration(regenerationCount: 0);

        expect(regenerated.wasRegenerated, isTrue);
        expect(original.wasRegenerated, isFalse);
      });
    });

    group('Script Properties', () {
      test('characterCount returns script length', () {
        final voiceGen = createTestVoiceGeneration(script: 'Hello world');
        expect(voiceGen.characterCount, equals(11));
      });

      test('wordCount returns correct word count', () {
        final voiceGen = createTestVoiceGeneration(script: 'Hello world this is a test');
        expect(voiceGen.wordCount, equals(6));
      });

      test('estimatedDuration calculates based on word count', () {
        // 150 words per minute = 2.5 words per second
        // 150 words should be 60 seconds
        final voiceGen = createTestVoiceGeneration(
          script: List.generate(150, (i) => 'word').join(' '),
        );
        expect(voiceGen.estimatedDuration, closeTo(60, 5));
      });

      test('estimatedDurationFormatted returns formatted time', () {
        final voiceGen = createTestVoiceGeneration(
          script: List.generate(150, (i) => 'word').join(' '),
        );
        expect(voiceGen.estimatedDurationFormatted, contains(':'));
      });

      test('durationFormatted returns formatted time when audioDuration set', () {
        final voiceGen = createTestVoiceGeneration(audioDuration: 125);
        expect(voiceGen.durationFormatted, equals('2:05'));
      });

      test('durationFormatted returns Unknown when audioDuration null', () {
        final voiceGen = createTestVoiceGeneration();
        expect(voiceGen.durationFormatted, equals('Unknown'));
      });
    });

    group('Display Properties', () {
      test('statusDisplay returns correct values', () {
        expect(createTestVoiceGeneration(status: VoiceGenerationStatus.pending).statusDisplay, equals('Pending'));
        expect(createTestVoiceGeneration(status: VoiceGenerationStatus.processing).statusDisplay, equals('Generating...'));
        expect(createTestVoiceGeneration(status: VoiceGenerationStatus.completed).statusDisplay, equals('Complete'));
        expect(createTestVoiceGeneration(status: VoiceGenerationStatus.failed).statusDisplay, equals('Failed'));
      });

      test('statusColorHex returns correct colors', () {
        expect(createTestVoiceGeneration(status: VoiceGenerationStatus.pending).statusColorHex, equals(0xFF9E9E9E));
        expect(createTestVoiceGeneration(status: VoiceGenerationStatus.processing).statusColorHex, equals(0xFF2196F3));
        expect(createTestVoiceGeneration(status: VoiceGenerationStatus.completed).statusColorHex, equals(0xFF4CAF50));
        expect(createTestVoiceGeneration(status: VoiceGenerationStatus.failed).statusColorHex, equals(0xFFF44336));
      });

      test('voiceOption returns voice details for valid voiceId', () {
        final voiceGen = createTestVoiceGeneration(voiceId: 'voice_sophie');
        expect(voiceGen.voiceOption, isNotNull);
        expect(voiceGen.voiceOption!.name, equals('Sophie'));
      });

      test('voiceOption returns null for invalid voiceId', () {
        final voiceGen = createTestVoiceGeneration(voiceId: 'invalid_voice');
        expect(voiceGen.voiceOption, isNull);
      });
    });

    group('Enum Handling', () {
      test('all VoiceGenerationStatus values serialize correctly', () {
        for (final status in VoiceGenerationStatus.values) {
          final voiceGen = createTestVoiceGeneration(status: status);
          final json = voiceGen.toJson();
          final restored = VoiceGenerationModel.fromJson(json);
          expect(restored.status, equals(status));
        }
      });
    });
  });

  group('VoiceGenerationHistory', () {
    test('fromJson parses correctly', () {
      final json = {
        'script': 'Original script',
        'voiceId': 'voice_sophie',
        'audioUrl': 'https://example.com/old_audio.mp3',
        'audioDuration': 90,
        'generatedAt': DateTime.now().toIso8601String(),
      };

      final history = VoiceGenerationHistory.fromJson(json);

      expect(history.script, equals('Original script'));
      expect(history.voiceId, equals('voice_sophie'));
      expect(history.audioUrl, equals('https://example.com/old_audio.mp3'));
      expect(history.audioDuration, equals(90));
    });

    test('durationFormatted returns formatted time', () {
      final history = VoiceGenerationHistory(
        script: 'Test',
        voiceId: 'voice_sophie',
        audioUrl: 'https://example.com/audio.mp3',
        audioDuration: 125,
        generatedAt: DateTime.now(),
      );

      expect(history.durationFormatted, equals('2:05'));
    });
  });

  group('VoiceOption', () {
    test('isFrench returns true for French accent', () {
      final sophie = VoiceOptions.getById('voice_sophie');
      expect(sophie, isNotNull);
      expect(sophie!.isFrench, isTrue);
    });

    test('isBritish returns true for British English accent', () {
      final emma = VoiceOptions.getById('voice_emma');
      expect(emma, isNotNull);
      expect(emma!.isBritish, isTrue);
    });

    test('isAmerican returns true for American English accent', () {
      final james = VoiceOptions.getById('voice_james');
      expect(james, isNotNull);
      expect(james!.isAmerican, isTrue);
    });

    test('isMale and isFemale return correct values', () {
      final sophie = VoiceOptions.getById('voice_sophie');
      final pierre = VoiceOptions.getById('voice_pierre');

      expect(sophie!.isFemale, isTrue);
      expect(sophie.isMale, isFalse);
      expect(pierre!.isMale, isTrue);
      expect(pierre.isFemale, isFalse);
    });
  });

  group('VoiceOptions', () {
    test('available contains all voices', () {
      expect(VoiceOptions.available.length, equals(4));
    });

    test('getById returns correct voice', () {
      final voice = VoiceOptions.getById('voice_sophie');
      expect(voice, isNotNull);
      expect(voice!.name, equals('Sophie'));
    });

    test('getById returns null for invalid id', () {
      final voice = VoiceOptions.getById('invalid_voice');
      expect(voice, isNull);
    });

    test('getByAccent returns voices by accent', () {
      final french = VoiceOptions.getByAccent('French');
      expect(french.length, equals(2));
    });

    test('getByGender returns voices by gender', () {
      final female = VoiceOptions.getByGender('Female');
      expect(female.length, equals(2));
    });

    test('frenchVoices returns French voices', () {
      expect(VoiceOptions.frenchVoices.length, equals(2));
    });

    test('englishVoices returns British and American voices', () {
      expect(VoiceOptions.englishVoices.length, equals(2));
    });

    test('maleVoices returns male voices', () {
      expect(VoiceOptions.maleVoices.length, equals(2));
    });

    test('femaleVoices returns female voices', () {
      expect(VoiceOptions.femaleVoices.length, equals(2));
    });
  });

  group('VoiceGenerationStatusExtension', () {
    test('displayName returns correct values', () {
      expect(VoiceGenerationStatus.pending.displayName, equals('Pending'));
      expect(VoiceGenerationStatus.processing.displayName, equals('Processing'));
      expect(VoiceGenerationStatus.completed.displayName, equals('Completed'));
      expect(VoiceGenerationStatus.failed.displayName, equals('Failed'));
    });

    test('description returns correct values', () {
      expect(VoiceGenerationStatus.pending.description, contains('Waiting'));
      expect(VoiceGenerationStatus.processing.description, contains('generated'));
      expect(VoiceGenerationStatus.completed.description, contains('successful'));
      expect(VoiceGenerationStatus.failed.description, contains('failed'));
    });
  });
}
