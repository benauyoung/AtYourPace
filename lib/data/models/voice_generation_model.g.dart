// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_generation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VoiceGenerationModelImpl _$$VoiceGenerationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$VoiceGenerationModelImpl(
      id: json['id'] as String,
      stopId: json['stopId'] as String,
      tourId: json['tourId'] as String,
      script: json['script'] as String,
      voiceId: json['voiceId'] as String,
      voiceName: json['voiceName'] as String,
      audioUrl: json['audioUrl'] as String?,
      audioDuration: (json['audioDuration'] as num?)?.toInt(),
      status:
          $enumDecodeNullable(_$VoiceGenerationStatusEnumMap, json['status']) ??
              VoiceGenerationStatus.pending,
      errorMessage: json['errorMessage'] as String?,
      regenerationCount: (json['regenerationCount'] as num?)?.toInt() ?? 0,
      history: (json['history'] as List<dynamic>?)
              ?.map((e) =>
                  VoiceGenerationHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$VoiceGenerationModelImplToJson(
        _$VoiceGenerationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stopId': instance.stopId,
      'tourId': instance.tourId,
      'script': instance.script,
      'voiceId': instance.voiceId,
      'voiceName': instance.voiceName,
      'audioUrl': instance.audioUrl,
      'audioDuration': instance.audioDuration,
      'status': _$VoiceGenerationStatusEnumMap[instance.status]!,
      'errorMessage': instance.errorMessage,
      'regenerationCount': instance.regenerationCount,
      'history': instance.history,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$VoiceGenerationStatusEnumMap = {
  VoiceGenerationStatus.pending: 'pending',
  VoiceGenerationStatus.processing: 'processing',
  VoiceGenerationStatus.completed: 'completed',
  VoiceGenerationStatus.failed: 'failed',
};

_$VoiceGenerationHistoryImpl _$$VoiceGenerationHistoryImplFromJson(
        Map<String, dynamic> json) =>
    _$VoiceGenerationHistoryImpl(
      script: json['script'] as String,
      voiceId: json['voiceId'] as String,
      audioUrl: json['audioUrl'] as String,
      audioDuration: (json['audioDuration'] as num).toInt(),
      generatedAt: const TimestampConverter().fromJson(json['generatedAt']),
    );

Map<String, dynamic> _$$VoiceGenerationHistoryImplToJson(
        _$VoiceGenerationHistoryImpl instance) =>
    <String, dynamic>{
      'script': instance.script,
      'voiceId': instance.voiceId,
      'audioUrl': instance.audioUrl,
      'audioDuration': instance.audioDuration,
      'generatedAt': const TimestampConverter().toJson(instance.generatedAt),
    };
