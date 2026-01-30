import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../data/models/voice_generation_model.dart';

/// Result of a voice generation operation.
class VoiceGenerationResult {
  final String? audioUrl;
  final int? audioDuration;
  final VoiceGenerationStatus status;
  final String? errorMessage;

  const VoiceGenerationResult({
    this.audioUrl,
    this.audioDuration,
    required this.status,
    this.errorMessage,
  });

  bool get isSuccess => status == VoiceGenerationStatus.completed;
  bool get hasError => status == VoiceGenerationStatus.failed;

  factory VoiceGenerationResult.success({
    required String audioUrl,
    required int audioDuration,
  }) {
    return VoiceGenerationResult(
      audioUrl: audioUrl,
      audioDuration: audioDuration,
      status: VoiceGenerationStatus.completed,
    );
  }

  factory VoiceGenerationResult.error(String message) {
    return VoiceGenerationResult(
      status: VoiceGenerationStatus.failed,
      errorMessage: message,
    );
  }

  factory VoiceGenerationResult.processing() {
    return const VoiceGenerationResult(
      status: VoiceGenerationStatus.processing,
    );
  }
}

/// Service for generating voice audio using ElevenLabs API.
class VoiceGenerationService {
  final Dio _dio;
  final FirebaseStorage _storage;
  final String _apiKey;

  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  static const int _maxTextLength = 5000;
  static const Duration _rateLimitDuration = Duration(minutes: 1);

  DateTime? _lastRequestTime;

  VoiceGenerationService({
    required String elevenLabsApiKey,
    required FirebaseStorage storage,
    Dio? dio,
  })  : _apiKey = elevenLabsApiKey,
        _storage = storage,
        _dio = dio ?? Dio();

  /// Generates voice audio from text.
  Future<VoiceGenerationResult> generateVoice({
    required String text,
    required String voiceId,
    required String tourId,
    required String stopId,
  }) async {
    // Validate input
    if (text.isEmpty) {
      return VoiceGenerationResult.error('Text cannot be empty');
    }

    if (text.length > _maxTextLength) {
      return VoiceGenerationResult.error(
        'Text exceeds maximum length of $_maxTextLength characters',
      );
    }

    // Get voice option
    final voiceOption = VoiceOptions.getById(voiceId);
    if (voiceOption == null) {
      return VoiceGenerationResult.error('Invalid voice ID: $voiceId');
    }

    // Check rate limiting
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed < _rateLimitDuration) {
        final waitTime = _rateLimitDuration - elapsed;
        return VoiceGenerationResult.error(
          'Rate limited. Please wait ${waitTime.inSeconds} seconds.',
        );
      }
    }

    try {
      _lastRequestTime = DateTime.now();

      // Call ElevenLabs API
      final response = await _dio.post(
        '$_baseUrl/text-to-speech/${voiceOption.elevenLabsId}',
        options: Options(
          headers: {
            'xi-api-key': _apiKey,
            'Content-Type': 'application/json',
            'Accept': 'audio/mpeg',
          },
          responseType: ResponseType.bytes,
        ),
        data: {
          'text': text,
          'model_id': 'eleven_multilingual_v2',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.75,
            'style': 0.0,
            'use_speaker_boost': true,
          },
        },
      );

      if (response.statusCode != 200) {
        return VoiceGenerationResult.error(
          'ElevenLabs API error: ${response.statusCode}',
        );
      }

      final audioData = response.data as List<int>;
      if (audioData.isEmpty) {
        return VoiceGenerationResult.error('Empty audio response');
      }

      // Upload to Firebase Storage
      final audioUrl = await _uploadAudio(
        audioData: Uint8List.fromList(audioData),
        tourId: tourId,
        stopId: stopId,
      );

      // Estimate duration based on text length
      final duration = _estimateDuration(text);

      return VoiceGenerationResult.success(
        audioUrl: audioUrl,
        audioDuration: duration,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        return VoiceGenerationResult.error(
          'Rate limit exceeded. Please try again later.',
        );
      }
      if (e.response?.statusCode == 401) {
        return VoiceGenerationResult.error(
          'Invalid API key',
        );
      }
      return VoiceGenerationResult.error(
        'Network error: ${e.message}',
      );
    } catch (e) {
      return VoiceGenerationResult.error(
        'Voice generation failed: $e',
      );
    }
  }

  /// Uploads audio data to Firebase Storage.
  Future<String> _uploadAudio({
    required Uint8List audioData,
    required String tourId,
    required String stopId,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'tours/$tourId/audio/${stopId}_$timestamp.mp3';

    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putData(
      audioData,
      SettableMetadata(
        contentType: 'audio/mpeg',
        customMetadata: {
          'tourId': tourId,
          'stopId': stopId,
          'generatedAt': DateTime.now().toIso8601String(),
        },
      ),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  /// Estimates audio duration based on text length.
  /// Average speaking rate is about 150 words per minute.
  int _estimateDuration(String text) {
    final wordCount = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    return (wordCount / 150 * 60).round();
  }

  /// Gets available voices.
  List<VoiceOption> getAvailableVoices() {
    return VoiceOptions.available;
  }

  /// Gets voices filtered by accent.
  List<VoiceOption> getVoicesByAccent(String accent) {
    return VoiceOptions.getByAccent(accent);
  }

  /// Gets voices filtered by gender.
  List<VoiceOption> getVoicesByGender(String gender) {
    return VoiceOptions.getByGender(gender);
  }

  /// Previews a voice by returning its preview URL.
  String? getVoicePreviewUrl(String voiceId) {
    return VoiceOptions.getById(voiceId)?.previewUrl;
  }

  /// Validates text for voice generation.
  ValidationResult validateText(String text) {
    if (text.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Text cannot be empty',
      );
    }

    if (text.length > _maxTextLength) {
      return ValidationResult(
        isValid: false,
        message: 'Text exceeds maximum length of $_maxTextLength characters '
            '(current: ${text.length})',
      );
    }

    // Check for unsupported characters
    final unsupportedPattern = RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]');
    if (unsupportedPattern.hasMatch(text)) {
      return ValidationResult(
        isValid: false,
        message: 'Text contains unsupported characters',
      );
    }

    return ValidationResult(
      isValid: true,
      characterCount: text.length,
      wordCount: text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length,
      estimatedDuration: _estimateDuration(text),
    );
  }

  /// Gets remaining rate limit time in seconds.
  int? getRateLimitRemainingSeconds() {
    if (_lastRequestTime == null) return null;

    final elapsed = DateTime.now().difference(_lastRequestTime!);
    if (elapsed >= _rateLimitDuration) return null;

    return (_rateLimitDuration - elapsed).inSeconds;
  }

  /// Checks if the service is rate limited.
  bool get isRateLimited {
    if (_lastRequestTime == null) return false;
    return DateTime.now().difference(_lastRequestTime!) < _rateLimitDuration;
  }

  /// Deletes generated audio from storage.
  Future<void> deleteAudio(String audioUrl) async {
    try {
      final ref = _storage.refFromURL(audioUrl);
      await ref.delete();
    } catch (e) {
      // Ignore errors if file doesn't exist
    }
  }

  /// Gets audio file size from URL.
  Future<int?> getAudioFileSize(String audioUrl) async {
    try {
      final ref = _storage.refFromURL(audioUrl);
      final metadata = await ref.getMetadata();
      return metadata.size;
    } catch (e) {
      return null;
    }
  }
}

/// Result of text validation.
class ValidationResult {
  final bool isValid;
  final String? message;
  final int? characterCount;
  final int? wordCount;
  final int? estimatedDuration;

  const ValidationResult({
    required this.isValid,
    this.message,
    this.characterCount,
    this.wordCount,
    this.estimatedDuration,
  });

  String get estimatedDurationFormatted {
    if (estimatedDuration == null) return 'Unknown';
    final minutes = estimatedDuration! ~/ 60;
    final seconds = estimatedDuration! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
