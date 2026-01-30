import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/models/voice_generation_model.dart';
import '../../../../../services/voice_generation_service.dart';

/// State for voice generation
class VoiceGenerationState {
  final String script;
  final String? selectedVoiceId;
  final VoiceGenerationStatus status;
  final String? audioUrl;
  final int? audioDuration;
  final String? errorMessage;
  final bool isPlaying;
  final int regenerationCount;
  final List<VoiceGenerationHistory> history;

  const VoiceGenerationState({
    this.script = '',
    this.selectedVoiceId,
    this.status = VoiceGenerationStatus.pending,
    this.audioUrl,
    this.audioDuration,
    this.errorMessage,
    this.isPlaying = false,
    this.regenerationCount = 0,
    this.history = const [],
  });

  VoiceGenerationState copyWith({
    String? script,
    String? selectedVoiceId,
    VoiceGenerationStatus? status,
    String? audioUrl,
    int? audioDuration,
    String? errorMessage,
    bool clearError = false,
    bool? isPlaying,
    int? regenerationCount,
    List<VoiceGenerationHistory>? history,
  }) {
    return VoiceGenerationState(
      script: script ?? this.script,
      selectedVoiceId: selectedVoiceId ?? this.selectedVoiceId,
      status: status ?? this.status,
      audioUrl: audioUrl ?? this.audioUrl,
      audioDuration: audioDuration ?? this.audioDuration,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPlaying: isPlaying ?? this.isPlaying,
      regenerationCount: regenerationCount ?? this.regenerationCount,
      history: history ?? this.history,
    );
  }

  /// Check if generation is in progress
  bool get isGenerating => status == VoiceGenerationStatus.processing;

  /// Check if generation completed successfully
  bool get isCompleted => status == VoiceGenerationStatus.completed;

  /// Check if generation failed
  bool get hasFailed => status == VoiceGenerationStatus.failed;

  /// Check if audio is available
  bool get hasAudio => audioUrl != null && isCompleted;

  /// Get character count
  int get characterCount => script.length;

  /// Get word count
  int get wordCount =>
      script.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  /// Estimated duration in seconds (150 words per minute average)
  int get estimatedDuration => (wordCount / 150 * 60).round();

  /// Formatted estimated duration
  String get estimatedDurationFormatted {
    final minutes = estimatedDuration ~/ 60;
    final seconds = estimatedDuration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formatted actual duration
  String get actualDurationFormatted {
    if (audioDuration == null) return '--:--';
    final minutes = audioDuration! ~/ 60;
    final seconds = audioDuration! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if script is valid for generation
  bool get isScriptValid => script.isNotEmpty && script.length <= 5000;

  /// Check if ready to generate
  bool get canGenerate =>
      isScriptValid && selectedVoiceId != null && !isGenerating;

  /// Get selected voice option
  VoiceOption? get selectedVoice =>
      selectedVoiceId != null ? VoiceOptions.getById(selectedVoiceId!) : null;

  /// Get validation message
  String? get validationMessage {
    if (script.isEmpty) return 'Enter a script to generate audio';
    if (script.length > 5000) return 'Script exceeds 5000 character limit';
    if (selectedVoiceId == null) return 'Select a voice';
    return null;
  }
}

/// Voice generation notifier
class VoiceGenerationNotifier extends StateNotifier<VoiceGenerationState> {
  final VoiceGenerationService _service;
  final String tourId;
  final String stopId;

  VoiceGenerationNotifier({
    required VoiceGenerationService service,
    required this.tourId,
    required this.stopId,
    String? initialScript,
    String? initialVoiceId,
    String? initialAudioUrl,
    int? initialAudioDuration,
  })  : _service = service,
        super(VoiceGenerationState(
          script: initialScript ?? '',
          selectedVoiceId: initialVoiceId ?? VoiceOptions.available.first.id,
          audioUrl: initialAudioUrl,
          audioDuration: initialAudioDuration,
          status: initialAudioUrl != null
              ? VoiceGenerationStatus.completed
              : VoiceGenerationStatus.pending,
        ));

  /// Update script text
  void updateScript(String script) {
    state = state.copyWith(script: script, clearError: true);
  }

  /// Select a voice
  void selectVoice(String voiceId) {
    state = state.copyWith(selectedVoiceId: voiceId);
  }

  /// Generate voice audio
  Future<bool> generate() async {
    if (!state.canGenerate) return false;

    state = state.copyWith(
      status: VoiceGenerationStatus.processing,
      clearError: true,
    );

    final result = await _service.generateVoice(
      text: state.script,
      voiceId: state.selectedVoiceId!,
      tourId: tourId,
      stopId: stopId,
    );

    if (result.isSuccess) {
      // Add to history if this is a regeneration
      final updatedHistory = state.hasAudio
          ? [
              ...state.history,
              VoiceGenerationHistory(
                script: state.script,
                voiceId: state.selectedVoiceId!,
                audioUrl: state.audioUrl!,
                audioDuration: state.audioDuration!,
                generatedAt: DateTime.now(),
              ),
            ]
          : state.history;

      state = state.copyWith(
        status: VoiceGenerationStatus.completed,
        audioUrl: result.audioUrl,
        audioDuration: result.audioDuration,
        regenerationCount:
            state.hasAudio ? state.regenerationCount + 1 : state.regenerationCount,
        history: updatedHistory,
      );
      return true;
    } else {
      state = state.copyWith(
        status: VoiceGenerationStatus.failed,
        errorMessage: result.errorMessage,
      );
      return false;
    }
  }

  /// Regenerate with same settings
  Future<bool> regenerate() async {
    return generate();
  }

  /// Set playing state
  void setPlaying(bool playing) {
    state = state.copyWith(isPlaying: playing);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset to initial state
  void reset() {
    state = const VoiceGenerationState();
  }

  /// Delete current audio
  Future<void> deleteAudio() async {
    if (state.audioUrl != null) {
      await _service.deleteAudio(state.audioUrl!);
      state = state.copyWith(
        audioUrl: null,
        audioDuration: null,
        status: VoiceGenerationStatus.pending,
      );
    }
  }

  /// Get available voices
  List<VoiceOption> get availableVoices => _service.getAvailableVoices();

  /// Get voices by accent
  List<VoiceOption> getVoicesByAccent(String accent) =>
      _service.getVoicesByAccent(accent);

  /// Get rate limit status
  bool get isRateLimited => _service.isRateLimited;

  /// Get remaining rate limit seconds
  int? get rateLimitRemainingSeconds => _service.getRateLimitRemainingSeconds();

  /// Validate current script
  ValidationResult validateScript() => _service.validateText(state.script);
}

/// Provider for voice generation service
final voiceGenerationServiceProvider = Provider<VoiceGenerationService>((ref) {
  // API key should come from environment/config
  const apiKey = String.fromEnvironment(
    'ELEVENLABS_API_KEY',
    defaultValue: '',
  );

  return VoiceGenerationService(
    elevenLabsApiKey: apiKey,
    storage: FirebaseStorage.instance,
  );
});

/// Provider for voice generation state
final voiceGenerationProvider = StateNotifierProvider.autoDispose
    .family<VoiceGenerationNotifier, VoiceGenerationState,
        ({String tourId, String stopId, String? initialScript, String? initialVoiceId, String? initialAudioUrl, int? initialAudioDuration})>(
  (ref, params) {
    final service = ref.watch(voiceGenerationServiceProvider);
    return VoiceGenerationNotifier(
      service: service,
      tourId: params.tourId,
      stopId: params.stopId,
      initialScript: params.initialScript,
      initialVoiceId: params.initialVoiceId,
      initialAudioUrl: params.initialAudioUrl,
      initialAudioDuration: params.initialAudioDuration,
    );
  },
);
