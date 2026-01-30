// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pricing_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PricingModel _$PricingModelFromJson(Map<String, dynamic> json) {
  return _PricingModel.fromJson(json);
}

/// @nodoc
mixin _$PricingModel {
  String get id => throw _privateConstructorUsedError;
  String get tourId => throw _privateConstructorUsedError;
  PricingType get type => throw _privateConstructorUsedError;
  double? get price => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  bool get allowPayWhatYouWant => throw _privateConstructorUsedError;
  double? get suggestedPrice => throw _privateConstructorUsedError;
  double? get minimumPrice => throw _privateConstructorUsedError;
  List<PricingTier> get tiers => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PricingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PricingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PricingModelCopyWith<PricingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PricingModelCopyWith<$Res> {
  factory $PricingModelCopyWith(
          PricingModel value, $Res Function(PricingModel) then) =
      _$PricingModelCopyWithImpl<$Res, PricingModel>;
  @useResult
  $Res call(
      {String id,
      String tourId,
      PricingType type,
      double? price,
      String currency,
      bool allowPayWhatYouWant,
      double? suggestedPrice,
      double? minimumPrice,
      List<PricingTier> tiers,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class _$PricingModelCopyWithImpl<$Res, $Val extends PricingModel>
    implements $PricingModelCopyWith<$Res> {
  _$PricingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PricingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? type = null,
    Object? price = freezed,
    Object? currency = null,
    Object? allowPayWhatYouWant = null,
    Object? suggestedPrice = freezed,
    Object? minimumPrice = freezed,
    Object? tiers = null,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PricingType,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      allowPayWhatYouWant: null == allowPayWhatYouWant
          ? _value.allowPayWhatYouWant
          : allowPayWhatYouWant // ignore: cast_nullable_to_non_nullable
              as bool,
      suggestedPrice: freezed == suggestedPrice
          ? _value.suggestedPrice
          : suggestedPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      minimumPrice: freezed == minimumPrice
          ? _value.minimumPrice
          : minimumPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      tiers: null == tiers
          ? _value.tiers
          : tiers // ignore: cast_nullable_to_non_nullable
              as List<PricingTier>,
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
}

/// @nodoc
abstract class _$$PricingModelImplCopyWith<$Res>
    implements $PricingModelCopyWith<$Res> {
  factory _$$PricingModelImplCopyWith(
          _$PricingModelImpl value, $Res Function(_$PricingModelImpl) then) =
      __$$PricingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tourId,
      PricingType type,
      double? price,
      String currency,
      bool allowPayWhatYouWant,
      double? suggestedPrice,
      double? minimumPrice,
      List<PricingTier> tiers,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class __$$PricingModelImplCopyWithImpl<$Res>
    extends _$PricingModelCopyWithImpl<$Res, _$PricingModelImpl>
    implements _$$PricingModelImplCopyWith<$Res> {
  __$$PricingModelImplCopyWithImpl(
      _$PricingModelImpl _value, $Res Function(_$PricingModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PricingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? type = null,
    Object? price = freezed,
    Object? currency = null,
    Object? allowPayWhatYouWant = null,
    Object? suggestedPrice = freezed,
    Object? minimumPrice = freezed,
    Object? tiers = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$PricingModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tourId: null == tourId
          ? _value.tourId
          : tourId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PricingType,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      allowPayWhatYouWant: null == allowPayWhatYouWant
          ? _value.allowPayWhatYouWant
          : allowPayWhatYouWant // ignore: cast_nullable_to_non_nullable
              as bool,
      suggestedPrice: freezed == suggestedPrice
          ? _value.suggestedPrice
          : suggestedPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      minimumPrice: freezed == minimumPrice
          ? _value.minimumPrice
          : minimumPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      tiers: null == tiers
          ? _value._tiers
          : tiers // ignore: cast_nullable_to_non_nullable
              as List<PricingTier>,
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
class _$PricingModelImpl extends _PricingModel {
  const _$PricingModelImpl(
      {required this.id,
      required this.tourId,
      this.type = PricingType.free,
      this.price,
      this.currency = 'EUR',
      this.allowPayWhatYouWant = false,
      this.suggestedPrice,
      this.minimumPrice,
      final List<PricingTier> tiers = const [],
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt})
      : _tiers = tiers,
        super._();

  factory _$PricingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PricingModelImplFromJson(json);

  @override
  final String id;
  @override
  final String tourId;
  @override
  @JsonKey()
  final PricingType type;
  @override
  final double? price;
  @override
  @JsonKey()
  final String currency;
  @override
  @JsonKey()
  final bool allowPayWhatYouWant;
  @override
  final double? suggestedPrice;
  @override
  final double? minimumPrice;
  final List<PricingTier> _tiers;
  @override
  @JsonKey()
  List<PricingTier> get tiers {
    if (_tiers is EqualUnmodifiableListView) return _tiers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tiers);
  }

  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'PricingModel(id: $id, tourId: $tourId, type: $type, price: $price, currency: $currency, allowPayWhatYouWant: $allowPayWhatYouWant, suggestedPrice: $suggestedPrice, minimumPrice: $minimumPrice, tiers: $tiers, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PricingModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.allowPayWhatYouWant, allowPayWhatYouWant) ||
                other.allowPayWhatYouWant == allowPayWhatYouWant) &&
            (identical(other.suggestedPrice, suggestedPrice) ||
                other.suggestedPrice == suggestedPrice) &&
            (identical(other.minimumPrice, minimumPrice) ||
                other.minimumPrice == minimumPrice) &&
            const DeepCollectionEquality().equals(other._tiers, _tiers) &&
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
      type,
      price,
      currency,
      allowPayWhatYouWant,
      suggestedPrice,
      minimumPrice,
      const DeepCollectionEquality().hash(_tiers),
      createdAt,
      updatedAt);

  /// Create a copy of PricingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PricingModelImplCopyWith<_$PricingModelImpl> get copyWith =>
      __$$PricingModelImplCopyWithImpl<_$PricingModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PricingModelImplToJson(
      this,
    );
  }
}

abstract class _PricingModel extends PricingModel {
  const factory _PricingModel(
          {required final String id,
          required final String tourId,
          final PricingType type,
          final double? price,
          final String currency,
          final bool allowPayWhatYouWant,
          final double? suggestedPrice,
          final double? minimumPrice,
          final List<PricingTier> tiers,
          @TimestampConverter() required final DateTime createdAt,
          @TimestampConverter() required final DateTime updatedAt}) =
      _$PricingModelImpl;
  const _PricingModel._() : super._();

  factory _PricingModel.fromJson(Map<String, dynamic> json) =
      _$PricingModelImpl.fromJson;

  @override
  String get id;
  @override
  String get tourId;
  @override
  PricingType get type;
  @override
  double? get price;
  @override
  String get currency;
  @override
  bool get allowPayWhatYouWant;
  @override
  double? get suggestedPrice;
  @override
  double? get minimumPrice;
  @override
  List<PricingTier> get tiers;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of PricingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PricingModelImplCopyWith<_$PricingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PricingTier _$PricingTierFromJson(Map<String, dynamic> json) {
  return _PricingTier.fromJson(json);
}

/// @nodoc
mixin _$PricingTier {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get features => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;

  /// Serializes this PricingTier to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PricingTier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PricingTierCopyWith<PricingTier> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PricingTierCopyWith<$Res> {
  factory $PricingTierCopyWith(
          PricingTier value, $Res Function(PricingTier) then) =
      _$PricingTierCopyWithImpl<$Res, PricingTier>;
  @useResult
  $Res call(
      {String id,
      String name,
      double price,
      String description,
      List<String> features,
      int sortOrder});
}

/// @nodoc
class _$PricingTierCopyWithImpl<$Res, $Val extends PricingTier>
    implements $PricingTierCopyWith<$Res> {
  _$PricingTierCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PricingTier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? price = null,
    Object? description = null,
    Object? features = null,
    Object? sortOrder = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      features: null == features
          ? _value.features
          : features // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PricingTierImplCopyWith<$Res>
    implements $PricingTierCopyWith<$Res> {
  factory _$$PricingTierImplCopyWith(
          _$PricingTierImpl value, $Res Function(_$PricingTierImpl) then) =
      __$$PricingTierImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      double price,
      String description,
      List<String> features,
      int sortOrder});
}

/// @nodoc
class __$$PricingTierImplCopyWithImpl<$Res>
    extends _$PricingTierCopyWithImpl<$Res, _$PricingTierImpl>
    implements _$$PricingTierImplCopyWith<$Res> {
  __$$PricingTierImplCopyWithImpl(
      _$PricingTierImpl _value, $Res Function(_$PricingTierImpl) _then)
      : super(_value, _then);

  /// Create a copy of PricingTier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? price = null,
    Object? description = null,
    Object? features = null,
    Object? sortOrder = null,
  }) {
    return _then(_$PricingTierImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      features: null == features
          ? _value._features
          : features // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PricingTierImpl extends _PricingTier {
  const _$PricingTierImpl(
      {required this.id,
      required this.name,
      required this.price,
      required this.description,
      final List<String> features = const [],
      this.sortOrder = 0})
      : _features = features,
        super._();

  factory _$PricingTierImpl.fromJson(Map<String, dynamic> json) =>
      _$$PricingTierImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double price;
  @override
  final String description;
  final List<String> _features;
  @override
  @JsonKey()
  List<String> get features {
    if (_features is EqualUnmodifiableListView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_features);
  }

  @override
  @JsonKey()
  final int sortOrder;

  @override
  String toString() {
    return 'PricingTier(id: $id, name: $name, price: $price, description: $description, features: $features, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PricingTierImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, price, description,
      const DeepCollectionEquality().hash(_features), sortOrder);

  /// Create a copy of PricingTier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PricingTierImplCopyWith<_$PricingTierImpl> get copyWith =>
      __$$PricingTierImplCopyWithImpl<_$PricingTierImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PricingTierImplToJson(
      this,
    );
  }
}

abstract class _PricingTier extends PricingTier {
  const factory _PricingTier(
      {required final String id,
      required final String name,
      required final double price,
      required final String description,
      final List<String> features,
      final int sortOrder}) = _$PricingTierImpl;
  const _PricingTier._() : super._();

  factory _PricingTier.fromJson(Map<String, dynamic> json) =
      _$PricingTierImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get price;
  @override
  String get description;
  @override
  List<String> get features;
  @override
  int get sortOrder;

  /// Create a copy of PricingTier
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PricingTierImplCopyWith<_$PricingTierImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
