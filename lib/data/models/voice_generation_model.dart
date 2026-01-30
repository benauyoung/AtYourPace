import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart';

part 'voice_generation_model.freezed.dart';
part 'voice_generation_model.g.dart';

enum VoiceGenerationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
}

@freezed
class VoiceGenerationModel with _$VoiceGenerationModel {
  const VoiceGenerationModel._();

  const factory VoiceGenerationModel({
    required String id,
    required String stopId,
    required String tourId,
    required String script,
    required String voiceId,
    required String voiceName,
    String? audioUrl,
    int? audioDuration,
    @Default(VoiceGenerationStatus.pending) VoiceGenerationStatus status,
    String? errorMessage,
    @Default(0) int regenerationCount,
    @Default([]) List<VoiceGenerationHistory> history,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _VoiceGenerationModel;

  factory VoiceGenerationModel.fromJson(Map<String, dynamic> json) =>
      _$VoiceGenerationModelFromJson(json);

  factory VoiceGenerationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VoiceGenerationModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// Check if generation is complete
  bool get isCompleted => status == VoiceGenerationStatus.completed;

  /// Check if generation failed
  bool get isFailed => status == VoiceGenerationStatus.failed;

  /// Check if generation is in progress
  bool get isProcessing => status == VoiceGenerationStatus.processing;

  /// Check if generation is pending
  bool get isPending => status == VoiceGenerationStatus.pending;

  /// Check if audio is available
  bool get hasAudio => audioUrl != null && isCompleted;

  /// Check if this has been regenerated
  bool get wasRegenerated => regenerationCount > 0;

  /// Get character count of script
  int get characterCount => script.length;

  /// Get word count of script
  int get wordCount => script.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  /// Estimate duration in seconds based on word count (avg 150 words per minute)
  int get estimatedDuration {
    return (wordCount / 150 * 60).round();
  }

  /// Format estimated duration
  String get estimatedDurationFormatted {
    final minutes = estimatedDuration ~/ 60;
    final seconds = estimatedDuration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format actual duration
  String get durationFormatted {
    if (audioDuration == null) return 'Unknown';
    final minutes = audioDuration! ~/ 60;
    final seconds = audioDuration! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get status display text
  String get statusDisplay {
    switch (status) {
      case VoiceGenerationStatus.pending:
        return 'Pending';
      case VoiceGenerationStatus.processing:
        return 'Generating...';
      case VoiceGenerationStatus.completed:
        return 'Complete';
      case VoiceGenerationStatus.failed:
        return 'Failed';
    }
  }

  /// Get status color hex
  int get statusColorHex {
    switch (status) {
      case VoiceGenerationStatus.pending:
        return 0xFF9E9E9E; // Grey
      case VoiceGenerationStatus.processing:
        return 0xFF2196F3; // Blue
      case VoiceGenerationStatus.completed:
        return 0xFF4CAF50; // Green
      case VoiceGenerationStatus.failed:
        return 0xFFF44336; // Red
    }
  }

  /// Get the voice option details
  VoiceOption? get voiceOption => VoiceOptions.getById(voiceId);
}

@freezed
class VoiceGenerationHistory with _$VoiceGenerationHistory {
  const VoiceGenerationHistory._();

  const factory VoiceGenerationHistory({
    required String script,
    required String voiceId,
    required String audioUrl,
    required int audioDuration,
    @TimestampConverter() required DateTime generatedAt,
  }) = _VoiceGenerationHistory;

  factory VoiceGenerationHistory.fromJson(Map<String, dynamic> json) =>
      _$VoiceGenerationHistoryFromJson(json);

  /// Format duration
  String get durationFormatted {
    final minutes = audioDuration ~/ 60;
    final seconds = audioDuration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Voice option definition for ElevenLabs voices
class VoiceOption {
  final String id;
  final String name;
  final String description;
  final String accent;
  final String gender;
  final String previewUrl;
  final String elevenLabsId;

  const VoiceOption({
    required this.id,
    required this.name,
    required this.description,
    required this.accent,
    required this.gender,
    required this.previewUrl,
    required this.elevenLabsId,
  });

  bool get isFrench => accent == 'French';
  bool get isBritish => accent == 'British English';
  bool get isAmerican => accent == 'American English';
  bool get isMale => gender == 'Male';
  bool get isFemale => gender == 'Female';
}

/// Available voice options
class VoiceOptions {
  static const List<VoiceOption> available = [
    VoiceOption(
      id: 'voice_sophie',
      name: 'Sophie',
      description: 'Warm, friendly female voice',
      accent: 'French',
      gender: 'Female',
      previewUrl: 'https://storage.googleapis.com/ayp-voices/sophie_preview.mp3',
      elevenLabsId: 'EXAVITQu4vr4xnSDxMaL', // Rachel - placeholder
    ),
    VoiceOption(
      id: 'voice_pierre',
      name: 'Pierre',
      description: 'Professional male voice',
      accent: 'French',
      gender: 'Male',
      previewUrl: 'https://storage.googleapis.com/ayp-voices/pierre_preview.mp3',
      elevenLabsId: 'onwK4e9ZLuTAKqWW03F9', // Daniel - placeholder
    ),
    VoiceOption(
      id: 'voice_emma',
      name: 'Emma',
      description: 'Clear, articulate female voice',
      accent: 'British English',
      gender: 'Female',
      previewUrl: 'https://storage.googleapis.com/ayp-voices/emma_preview.mp3',
      elevenLabsId: 'XrExE9yKIg1WjnnlVkGX', // Emily - placeholder
    ),
    VoiceOption(
      id: 'voice_james',
      name: 'James',
      description: 'Engaging male narrator',
      accent: 'American English',
      gender: 'Male',
      previewUrl: 'https://storage.googleapis.com/ayp-voices/james_preview.mp3',
      elevenLabsId: 'IKne3meq5aSn9XLyUdCD', // Josh - placeholder
    ),
  ];

  /// Get a voice by its ID
  static VoiceOption? getById(String id) {
    try {
      return available.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get voices by accent
  static List<VoiceOption> getByAccent(String accent) {
    return available.where((v) => v.accent == accent).toList();
  }

  /// Get voices by gender
  static List<VoiceOption> getByGender(String gender) {
    return available.where((v) => v.gender == gender).toList();
  }

  /// Get French voices
  static List<VoiceOption> get frenchVoices =>
      available.where((v) => v.isFrench).toList();

  /// Get English voices
  static List<VoiceOption> get englishVoices =>
      available.where((v) => v.isBritish || v.isAmerican).toList();

  /// Get male voices
  static List<VoiceOption> get maleVoices =>
      available.where((v) => v.isMale).toList();

  /// Get female voices
  static List<VoiceOption> get femaleVoices =>
      available.where((v) => v.isFemale).toList();
}

extension VoiceGenerationStatusExtension on VoiceGenerationStatus {
  String get displayName {
    switch (this) {
      case VoiceGenerationStatus.pending:
        return 'Pending';
      case VoiceGenerationStatus.processing:
        return 'Processing';
      case VoiceGenerationStatus.completed:
        return 'Completed';
      case VoiceGenerationStatus.failed:
        return 'Failed';
    }
  }

  String get description {
    switch (this) {
      case VoiceGenerationStatus.pending:
        return 'Waiting to be processed';
      case VoiceGenerationStatus.processing:
        return 'Voice is being generated';
      case VoiceGenerationStatus.completed:
        return 'Voice generation successful';
      case VoiceGenerationStatus.failed:
        return 'Voice generation failed';
    }
  }
}
