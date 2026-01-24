// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stop_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StopModel _$StopModelFromJson(Map<String, dynamic> json) {
  return _StopModel.fromJson(json);
}

/// @nodoc
mixin _$StopModel {
  String get id => throw _privateConstructorUsedError;
  String get tourId => throw _privateConstructorUsedError;
  String get versionId => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description =>
      throw _privateConstructorUsedError; // Location & Geofencing
  @GeoPointConverter()
  GeoPoint get location => throw _privateConstructorUsedError;
  String get geohash => throw _privateConstructorUsedError;
  int get triggerRadius => throw _privateConstructorUsedError; // Media
  StopMedia get media =>
      throw _privateConstructorUsedError; // Navigation hints (for driving tours)
  StopNavigation? get navigation =>
      throw _privateConstructorUsedError; // Timestamps
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this StopModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StopModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StopModelCopyWith<StopModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StopModelCopyWith<$Res> {
  factory $StopModelCopyWith(StopModel value, $Res Function(StopModel) then) =
      _$StopModelCopyWithImpl<$Res, StopModel>;
  @useResult
  $Res call(
      {String id,
      String tourId,
      String versionId,
      int order,
      String name,
      String description,
      @GeoPointConverter() GeoPoint location,
      String geohash,
      int triggerRadius,
      StopMedia media,
      StopNavigation? navigation,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});

  $StopMediaCopyWith<$Res> get media;
  $StopNavigationCopyWith<$Res>? get navigation;
}

/// @nodoc
class _$StopModelCopyWithImpl<$Res, $Val extends StopModel>
    implements $StopModelCopyWith<$Res> {
  _$StopModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StopModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? versionId = null,
    Object? order = null,
    Object? name = null,
    Object? description = null,
    Object? location = null,
    Object? geohash = null,
    Object? triggerRadius = null,
    Object? media = null,
    Object? navigation = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tourId: null == tourId
          ? _value.tourId
          : tourId // ignore: cast_nullable_to_non_nullable
              as String,
      versionId: null == versionId
          ? _value.versionId
          : versionId // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as GeoPoint,
      geohash: null == geohash
          ? _value.geohash
          : geohash // ignore: cast_nullable_to_non_nullable
              as String,
      triggerRadius: null == triggerRadius
          ? _value.triggerRadius
          : triggerRadius // ignore: cast_nullable_to_non_nullable
              as int,
      media: null == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as StopMedia,
      navigation: freezed == navigation
          ? _value.navigation
          : navigation // ignore: cast_nullable_to_non_nullable
              as StopNavigation?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of StopModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StopMediaCopyWith<$Res> get media {
    return $StopMediaCopyWith<$Res>(_value.media, (value) {
      return _then(_value.copyWith(media: value) as $Val);
    });
  }

  /// Create a copy of StopModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StopNavigationCopyWith<$Res>? get navigation {
    if (_value.navigation == null) {
      return null;
    }

    return $StopNavigationCopyWith<$Res>(_value.navigation!, (value) {
      return _then(_value.copyWith(navigation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StopModelImplCopyWith<$Res>
    implements $StopModelCopyWith<$Res> {
  factory _$$StopModelImplCopyWith(
          _$StopModelImpl value, $Res Function(_$StopModelImpl) then) =
      __$$StopModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tourId,
      String versionId,
      int order,
      String name,
      String description,
      @GeoPointConverter() GeoPoint location,
      String geohash,
      int triggerRadius,
      StopMedia media,
      StopNavigation? navigation,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});

  @override
  $StopMediaCopyWith<$Res> get media;
  @override
  $StopNavigationCopyWith<$Res>? get navigation;
}

/// @nodoc
class __$$StopModelImplCopyWithImpl<$Res>
    extends _$StopModelCopyWithImpl<$Res, _$StopModelImpl>
    implements _$$StopModelImplCopyWith<$Res> {
  __$$StopModelImplCopyWithImpl(
      _$StopModelImpl _value, $Res Function(_$StopModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of StopModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? versionId = null,
    Object? order = null,
    Object? name = null,
    Object? description = null,
    Object? location = null,
    Object? geohash = null,
    Object? triggerRadius = null,
    Object? media = null,
    Object? navigation = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$StopModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tourId: null == tourId
          ? _value.tourId
          : tourId // ignore: cast_nullable_to_non_nullable
              as String,
      versionId: null == versionId
          ? _value.versionId
          : versionId // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as GeoPoint,
      geohash: null == geohash
          ? _value.geohash
          : geohash // ignore: cast_nullable_to_non_nullable
              as String,
      triggerRadius: null == triggerRadius
          ? _value.triggerRadius
          : triggerRadius // ignore: cast_nullable_to_non_nullable
              as int,
      media: null == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as StopMedia,
      navigation: freezed == navigation
          ? _value.navigation
          : navigation // ignore: cast_nullable_to_non_nullable
              as StopNavigation?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StopModelImpl extends _StopModel {
  const _$StopModelImpl(
      {required this.id,
      required this.tourId,
      required this.versionId,
      required this.order,
      required this.name,
      this.description = '',
      @GeoPointConverter() required this.location,
      required this.geohash,
      this.triggerRadius = 30,
      this.media = const StopMedia(),
      this.navigation,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt})
      : super._();

  factory _$StopModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$StopModelImplFromJson(json);

  @override
  final String id;
  @override
  final String tourId;
  @override
  final String versionId;
  @override
  final int order;
  @override
  final String name;
  @override
  @JsonKey()
  final String description;
// Location & Geofencing
  @override
  @GeoPointConverter()
  final GeoPoint location;
  @override
  final String geohash;
  @override
  @JsonKey()
  final int triggerRadius;
// Media
  @override
  @JsonKey()
  final StopMedia media;
// Navigation hints (for driving tours)
  @override
  final StopNavigation? navigation;
// Timestamps
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'StopModel(id: $id, tourId: $tourId, versionId: $versionId, order: $order, name: $name, description: $description, location: $location, geohash: $geohash, triggerRadius: $triggerRadius, media: $media, navigation: $navigation, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StopModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.versionId, versionId) ||
                other.versionId == versionId) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.geohash, geohash) || other.geohash == geohash) &&
            (identical(other.triggerRadius, triggerRadius) ||
                other.triggerRadius == triggerRadius) &&
            (identical(other.media, media) || other.media == media) &&
            (identical(other.navigation, navigation) ||
                other.navigation == navigation) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tourId,
      versionId,
      order,
      name,
      description,
      location,
      geohash,
      triggerRadius,
      media,
      navigation,
      createdAt,
      updatedAt);

  /// Create a copy of StopModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StopModelImplCopyWith<_$StopModelImpl> get copyWith =>
      __$$StopModelImplCopyWithImpl<_$StopModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StopModelImplToJson(
      this,
    );
  }
}

abstract class _StopModel extends StopModel {
  const factory _StopModel(
          {required final String id,
          required final String tourId,
          required final String versionId,
          required final int order,
          required final String name,
          final String description,
          @GeoPointConverter() required final GeoPoint location,
          required final String geohash,
          final int triggerRadius,
          final StopMedia media,
          final StopNavigation? navigation,
          @TimestampConverter() required final DateTime createdAt,
          @TimestampConverter() required final DateTime updatedAt}) =
      _$StopModelImpl;
  const _StopModel._() : super._();

  factory _StopModel.fromJson(Map<String, dynamic> json) =
      _$StopModelImpl.fromJson;

  @override
  String get id;
  @override
  String get tourId;
  @override
  String get versionId;
  @override
  int get order;
  @override
  String get name;
  @override
  String get description; // Location & Geofencing
  @override
  @GeoPointConverter()
  GeoPoint get location;
  @override
  String get geohash;
  @override
  int get triggerRadius; // Media
  @override
  StopMedia get media; // Navigation hints (for driving tours)
  @override
  StopNavigation? get navigation; // Timestamps
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of StopModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StopModelImplCopyWith<_$StopModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StopMedia _$StopMediaFromJson(Map<String, dynamic> json) {
  return _StopMedia.fromJson(json);
}

/// @nodoc
mixin _$StopMedia {
  String? get audioUrl => throw _privateConstructorUsedError;
  AudioSource get audioSource => throw _privateConstructorUsedError;
  int? get audioDuration => throw _privateConstructorUsedError;
  String? get audioText => throw _privateConstructorUsedError;
  String? get voiceId => throw _privateConstructorUsedError;
  List<StopImage> get images => throw _privateConstructorUsedError;
  String? get videoUrl => throw _privateConstructorUsedError;

  /// Serializes this StopMedia to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StopMedia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StopMediaCopyWith<StopMedia> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StopMediaCopyWith<$Res> {
  factory $StopMediaCopyWith(StopMedia value, $Res Function(StopMedia) then) =
      _$StopMediaCopyWithImpl<$Res, StopMedia>;
  @useResult
  $Res call(
      {String? audioUrl,
      AudioSource audioSource,
      int? audioDuration,
      String? audioText,
      String? voiceId,
      List<StopImage> images,
      String? videoUrl});
}

/// @nodoc
class _$StopMediaCopyWithImpl<$Res, $Val extends StopMedia>
    implements $StopMediaCopyWith<$Res> {
  _$StopMediaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StopMedia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? audioUrl = freezed,
    Object? audioSource = null,
    Object? audioDuration = freezed,
    Object? audioText = freezed,
    Object? voiceId = freezed,
    Object? images = null,
    Object? videoUrl = freezed,
  }) {
    return _then(_value.copyWith(
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      audioSource: null == audioSource
          ? _value.audioSource
          : audioSource // ignore: cast_nullable_to_non_nullable
              as AudioSource,
      audioDuration: freezed == audioDuration
          ? _value.audioDuration
          : audioDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      audioText: freezed == audioText
          ? _value.audioText
          : audioText // ignore: cast_nullable_to_non_nullable
              as String?,
      voiceId: freezed == voiceId
          ? _value.voiceId
          : voiceId // ignore: cast_nullable_to_non_nullable
              as String?,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<StopImage>,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StopMediaImplCopyWith<$Res>
    implements $StopMediaCopyWith<$Res> {
  factory _$$StopMediaImplCopyWith(
          _$StopMediaImpl value, $Res Function(_$StopMediaImpl) then) =
      __$$StopMediaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? audioUrl,
      AudioSource audioSource,
      int? audioDuration,
      String? audioText,
      String? voiceId,
      List<StopImage> images,
      String? videoUrl});
}

/// @nodoc
class __$$StopMediaImplCopyWithImpl<$Res>
    extends _$StopMediaCopyWithImpl<$Res, _$StopMediaImpl>
    implements _$$StopMediaImplCopyWith<$Res> {
  __$$StopMediaImplCopyWithImpl(
      _$StopMediaImpl _value, $Res Function(_$StopMediaImpl) _then)
      : super(_value, _then);

  /// Create a copy of StopMedia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? audioUrl = freezed,
    Object? audioSource = null,
    Object? audioDuration = freezed,
    Object? audioText = freezed,
    Object? voiceId = freezed,
    Object? images = null,
    Object? videoUrl = freezed,
  }) {
    return _then(_$StopMediaImpl(
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      audioSource: null == audioSource
          ? _value.audioSource
          : audioSource // ignore: cast_nullable_to_non_nullable
              as AudioSource,
      audioDuration: freezed == audioDuration
          ? _value.audioDuration
          : audioDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      audioText: freezed == audioText
          ? _value.audioText
          : audioText // ignore: cast_nullable_to_non_nullable
              as String?,
      voiceId: freezed == voiceId
          ? _value.voiceId
          : voiceId // ignore: cast_nullable_to_non_nullable
              as String?,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<StopImage>,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StopMediaImpl extends _StopMedia {
  const _$StopMediaImpl(
      {this.audioUrl,
      this.audioSource = AudioSource.recorded,
      this.audioDuration,
      this.audioText,
      this.voiceId,
      final List<StopImage> images = const [],
      this.videoUrl})
      : _images = images,
        super._();

  factory _$StopMediaImpl.fromJson(Map<String, dynamic> json) =>
      _$$StopMediaImplFromJson(json);

  @override
  final String? audioUrl;
  @override
  @JsonKey()
  final AudioSource audioSource;
  @override
  final int? audioDuration;
  @override
  final String? audioText;
  @override
  final String? voiceId;
  final List<StopImage> _images;
  @override
  @JsonKey()
  List<StopImage> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final String? videoUrl;

  @override
  String toString() {
    return 'StopMedia(audioUrl: $audioUrl, audioSource: $audioSource, audioDuration: $audioDuration, audioText: $audioText, voiceId: $voiceId, images: $images, videoUrl: $videoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StopMediaImpl &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.audioSource, audioSource) ||
                other.audioSource == audioSource) &&
            (identical(other.audioDuration, audioDuration) ||
                other.audioDuration == audioDuration) &&
            (identical(other.audioText, audioText) ||
                other.audioText == audioText) &&
            (identical(other.voiceId, voiceId) || other.voiceId == voiceId) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      audioUrl,
      audioSource,
      audioDuration,
      audioText,
      voiceId,
      const DeepCollectionEquality().hash(_images),
      videoUrl);

  /// Create a copy of StopMedia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StopMediaImplCopyWith<_$StopMediaImpl> get copyWith =>
      __$$StopMediaImplCopyWithImpl<_$StopMediaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StopMediaImplToJson(
      this,
    );
  }
}

abstract class _StopMedia extends StopMedia {
  const factory _StopMedia(
      {final String? audioUrl,
      final AudioSource audioSource,
      final int? audioDuration,
      final String? audioText,
      final String? voiceId,
      final List<StopImage> images,
      final String? videoUrl}) = _$StopMediaImpl;
  const _StopMedia._() : super._();

  factory _StopMedia.fromJson(Map<String, dynamic> json) =
      _$StopMediaImpl.fromJson;

  @override
  String? get audioUrl;
  @override
  AudioSource get audioSource;
  @override
  int? get audioDuration;
  @override
  String? get audioText;
  @override
  String? get voiceId;
  @override
  List<StopImage> get images;
  @override
  String? get videoUrl;

  /// Create a copy of StopMedia
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StopMediaImplCopyWith<_$StopMediaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StopImage _$StopImageFromJson(Map<String, dynamic> json) {
  return _StopImage.fromJson(json);
}

/// @nodoc
mixin _$StopImage {
  String get url => throw _privateConstructorUsedError;
  String? get caption => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;

  /// Serializes this StopImage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StopImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StopImageCopyWith<StopImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StopImageCopyWith<$Res> {
  factory $StopImageCopyWith(StopImage value, $Res Function(StopImage) then) =
      _$StopImageCopyWithImpl<$Res, StopImage>;
  @useResult
  $Res call({String url, String? caption, int order});
}

/// @nodoc
class _$StopImageCopyWithImpl<$Res, $Val extends StopImage>
    implements $StopImageCopyWith<$Res> {
  _$StopImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StopImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? caption = freezed,
    Object? order = null,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StopImageImplCopyWith<$Res>
    implements $StopImageCopyWith<$Res> {
  factory _$$StopImageImplCopyWith(
          _$StopImageImpl value, $Res Function(_$StopImageImpl) then) =
      __$$StopImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String url, String? caption, int order});
}

/// @nodoc
class __$$StopImageImplCopyWithImpl<$Res>
    extends _$StopImageCopyWithImpl<$Res, _$StopImageImpl>
    implements _$$StopImageImplCopyWith<$Res> {
  __$$StopImageImplCopyWithImpl(
      _$StopImageImpl _value, $Res Function(_$StopImageImpl) _then)
      : super(_value, _then);

  /// Create a copy of StopImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? caption = freezed,
    Object? order = null,
  }) {
    return _then(_$StopImageImpl(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StopImageImpl implements _StopImage {
  const _$StopImageImpl({required this.url, this.caption, this.order = 0});

  factory _$StopImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$StopImageImplFromJson(json);

  @override
  final String url;
  @override
  final String? caption;
  @override
  @JsonKey()
  final int order;

  @override
  String toString() {
    return 'StopImage(url: $url, caption: $caption, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StopImageImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.order, order) || other.order == order));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url, caption, order);

  /// Create a copy of StopImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StopImageImplCopyWith<_$StopImageImpl> get copyWith =>
      __$$StopImageImplCopyWithImpl<_$StopImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StopImageImplToJson(
      this,
    );
  }
}

abstract class _StopImage implements StopImage {
  const factory _StopImage(
      {required final String url,
      final String? caption,
      final int order}) = _$StopImageImpl;

  factory _StopImage.fromJson(Map<String, dynamic> json) =
      _$StopImageImpl.fromJson;

  @override
  String get url;
  @override
  String? get caption;
  @override
  int get order;

  /// Create a copy of StopImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StopImageImplCopyWith<_$StopImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StopNavigation _$StopNavigationFromJson(Map<String, dynamic> json) {
  return _StopNavigation.fromJson(json);
}

/// @nodoc
mixin _$StopNavigation {
  String? get arrivalInstruction => throw _privateConstructorUsedError;
  String? get parkingInfo => throw _privateConstructorUsedError;
  String? get direction => throw _privateConstructorUsedError;

  /// Serializes this StopNavigation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StopNavigation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StopNavigationCopyWith<StopNavigation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StopNavigationCopyWith<$Res> {
  factory $StopNavigationCopyWith(
          StopNavigation value, $Res Function(StopNavigation) then) =
      _$StopNavigationCopyWithImpl<$Res, StopNavigation>;
  @useResult
  $Res call(
      {String? arrivalInstruction, String? parkingInfo, String? direction});
}

/// @nodoc
class _$StopNavigationCopyWithImpl<$Res, $Val extends StopNavigation>
    implements $StopNavigationCopyWith<$Res> {
  _$StopNavigationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StopNavigation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? arrivalInstruction = freezed,
    Object? parkingInfo = freezed,
    Object? direction = freezed,
  }) {
    return _then(_value.copyWith(
      arrivalInstruction: freezed == arrivalInstruction
          ? _value.arrivalInstruction
          : arrivalInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      parkingInfo: freezed == parkingInfo
          ? _value.parkingInfo
          : parkingInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      direction: freezed == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StopNavigationImplCopyWith<$Res>
    implements $StopNavigationCopyWith<$Res> {
  factory _$$StopNavigationImplCopyWith(_$StopNavigationImpl value,
          $Res Function(_$StopNavigationImpl) then) =
      __$$StopNavigationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? arrivalInstruction, String? parkingInfo, String? direction});
}

/// @nodoc
class __$$StopNavigationImplCopyWithImpl<$Res>
    extends _$StopNavigationCopyWithImpl<$Res, _$StopNavigationImpl>
    implements _$$StopNavigationImplCopyWith<$Res> {
  __$$StopNavigationImplCopyWithImpl(
      _$StopNavigationImpl _value, $Res Function(_$StopNavigationImpl) _then)
      : super(_value, _then);

  /// Create a copy of StopNavigation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? arrivalInstruction = freezed,
    Object? parkingInfo = freezed,
    Object? direction = freezed,
  }) {
    return _then(_$StopNavigationImpl(
      arrivalInstruction: freezed == arrivalInstruction
          ? _value.arrivalInstruction
          : arrivalInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      parkingInfo: freezed == parkingInfo
          ? _value.parkingInfo
          : parkingInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      direction: freezed == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StopNavigationImpl implements _StopNavigation {
  const _$StopNavigationImpl(
      {this.arrivalInstruction, this.parkingInfo, this.direction});

  factory _$StopNavigationImpl.fromJson(Map<String, dynamic> json) =>
      _$$StopNavigationImplFromJson(json);

  @override
  final String? arrivalInstruction;
  @override
  final String? parkingInfo;
  @override
  final String? direction;

  @override
  String toString() {
    return 'StopNavigation(arrivalInstruction: $arrivalInstruction, parkingInfo: $parkingInfo, direction: $direction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StopNavigationImpl &&
            (identical(other.arrivalInstruction, arrivalInstruction) ||
                other.arrivalInstruction == arrivalInstruction) &&
            (identical(other.parkingInfo, parkingInfo) ||
                other.parkingInfo == parkingInfo) &&
            (identical(other.direction, direction) ||
                other.direction == direction));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, arrivalInstruction, parkingInfo, direction);

  /// Create a copy of StopNavigation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StopNavigationImplCopyWith<_$StopNavigationImpl> get copyWith =>
      __$$StopNavigationImplCopyWithImpl<_$StopNavigationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StopNavigationImplToJson(
      this,
    );
  }
}

abstract class _StopNavigation implements StopNavigation {
  const factory _StopNavigation(
      {final String? arrivalInstruction,
      final String? parkingInfo,
      final String? direction}) = _$StopNavigationImpl;

  factory _StopNavigation.fromJson(Map<String, dynamic> json) =
      _$StopNavigationImpl.fromJson;

  @override
  String? get arrivalInstruction;
  @override
  String? get parkingInfo;
  @override
  String? get direction;

  /// Create a copy of StopNavigation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StopNavigationImplCopyWith<_$StopNavigationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
