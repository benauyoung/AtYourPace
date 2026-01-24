import 'package:cloud_functions/cloud_functions.dart';

import '../core/constants/app_constants.dart';

/// Service for calling Firebase Cloud Functions.
/// Currently supports ElevenLabs audio generation.
class CloudFunctionsService {
  final FirebaseFunctions _functions;

  CloudFunctionsService({required FirebaseFunctions functions})
      : _functions = functions;

  /// Generates audio using ElevenLabs text-to-speech API.
  ///
  /// Rate limited to 1 request per minute per user.
  /// Returns the Firebase Storage download URL for the generated audio.
  ///
  /// Throws:
  /// - FirebaseFunctionsException with code 'resource-exhausted' if rate limited
  /// - FirebaseFunctionsException with code 'invalid-argument' for invalid input
  /// - FirebaseFunctionsException with code 'unauthenticated' if not signed in
  Future<String> generateElevenLabsAudio({
    required String tourId,
    required String stopId,
    required String text,
    required String voiceId,
  }) async {
    // Validate text length
    if (text.isEmpty) {
      throw ArgumentError('Text cannot be empty');
    }

    if (text.length > AppConstants.elevenLabsMaxTextLength) {
      throw ArgumentError(
        'Text exceeds maximum length of ${AppConstants.elevenLabsMaxTextLength} characters'
      );
    }

    try {
      final callable = _functions.httpsCallable('generateElevenLabsAudio');

      final result = await callable.call({
        'tourId': tourId,
        'stopId': stopId,
        'text': text,
        'voiceId': voiceId,
      });

      final data = result.data;
      if (data is! Map || !data.containsKey('audioUrl')) {
        throw Exception('Invalid response from Cloud Function');
      }

      return data['audioUrl'] as String;
    } on FirebaseFunctionsException catch (e) {
      // Re-throw with user-friendly messages
      switch (e.code) {
        case 'resource-exhausted':
          throw Exception(
            'Rate limit exceeded. Please wait ${AppConstants.elevenLabsRateLimitMinutes} minute(s) before trying again.'
          );
        case 'invalid-argument':
          throw Exception(e.message ?? 'Invalid input provided');
        case 'unauthenticated':
          throw Exception('You must be signed in to generate audio');
        case 'permission-denied':
          throw Exception('You do not have permission to generate audio for this tour');
        case 'not-found':
          throw Exception('Tour or stop not found');
        case 'internal':
          throw Exception('Server error. Please try again later.');
        default:
          throw Exception('Failed to generate audio: ${e.message ?? e.code}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error: $e');
    }
  }

  /// Gets the list of available ElevenLabs voices.
  /// This is a helper method that returns the predefined voice options.
  /// In a production app, this might fetch from the ElevenLabs API.
  List<ElevenLabsVoice> getAvailableVoices() {
    return [
      const ElevenLabsVoice(
        id: '21m00Tcm4TlvDq8ikWAM',
        name: 'Rachel',
        description: 'Young, female, American accent',
      ),
      const ElevenLabsVoice(
        id: 'AZnzlk1XvdvUeBnXmlld',
        name: 'Domi',
        description: 'Young, female, American accent',
      ),
      const ElevenLabsVoice(
        id: 'EXAVITQu4vr4xnSDxMaL',
        name: 'Bella',
        description: 'Young, female, American accent',
      ),
      const ElevenLabsVoice(
        id: 'ErXwobaYiN019PkySvjV',
        name: 'Antoni',
        description: 'Young, male, American accent',
      ),
      const ElevenLabsVoice(
        id: 'VR6AewLTigWG4xSOukaG',
        name: 'Arnold',
        description: 'Middle-aged, male, American accent',
      ),
      const ElevenLabsVoice(
        id: 'pNInz6obpgDQGcFmaJgB',
        name: 'Adam',
        description: 'Middle-aged, male, American accent',
      ),
      const ElevenLabsVoice(
        id: 'yoZ06aMxZJJ28mfd3POQ',
        name: 'Sam',
        description: 'Young, male, American accent',
      ),
    ];
  }
}

/// Represents an ElevenLabs voice option.
class ElevenLabsVoice {
  final String id;
  final String name;
  final String description;

  const ElevenLabsVoice({
    required this.id,
    required this.name,
    required this.description,
  });
}
