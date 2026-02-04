// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marketplace_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MarketplaceState {
  String get searchQuery => throw _privateConstructorUsedError;
  TourCategory? get selectedCategory => throw _privateConstructorUsedError;
  TourType? get selectedTourType => throw _privateConstructorUsedError;
  bool get isMapView => throw _privateConstructorUsedError;
  AsyncValue<List<TourModel>> get filteredTours =>
      throw _privateConstructorUsedError;
  List<CollectionModel> get visibleCollections =>
      throw _privateConstructorUsedError;

  /// Create a copy of MarketplaceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketplaceStateCopyWith<MarketplaceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketplaceStateCopyWith<$Res> {
  factory $MarketplaceStateCopyWith(
          MarketplaceState value, $Res Function(MarketplaceState) then) =
      _$MarketplaceStateCopyWithImpl<$Res, MarketplaceState>;
  @useResult
  $Res call(
      {String searchQuery,
      TourCategory? selectedCategory,
      TourType? selectedTourType,
      bool isMapView,
      AsyncValue<List<TourModel>> filteredTours,
      List<CollectionModel> visibleCollections});
}

/// @nodoc
class _$MarketplaceStateCopyWithImpl<$Res, $Val extends MarketplaceState>
    implements $MarketplaceStateCopyWith<$Res> {
  _$MarketplaceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketplaceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searchQuery = null,
    Object? selectedCategory = freezed,
    Object? selectedTourType = freezed,
    Object? isMapView = null,
    Object? filteredTours = null,
    Object? visibleCollections = null,
  }) {
    return _then(_value.copyWith(
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      selectedCategory: freezed == selectedCategory
          ? _value.selectedCategory
          : selectedCategory // ignore: cast_nullable_to_non_nullable
              as TourCategory?,
      selectedTourType: freezed == selectedTourType
          ? _value.selectedTourType
          : selectedTourType // ignore: cast_nullable_to_non_nullable
              as TourType?,
      isMapView: null == isMapView
          ? _value.isMapView
          : isMapView // ignore: cast_nullable_to_non_nullable
              as bool,
      filteredTours: null == filteredTours
          ? _value.filteredTours
          : filteredTours // ignore: cast_nullable_to_non_nullable
              as AsyncValue<List<TourModel>>,
      visibleCollections: null == visibleCollections
          ? _value.visibleCollections
          : visibleCollections // ignore: cast_nullable_to_non_nullable
              as List<CollectionModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MarketplaceStateImplCopyWith<$Res>
    implements $MarketplaceStateCopyWith<$Res> {
  factory _$$MarketplaceStateImplCopyWith(_$MarketplaceStateImpl value,
          $Res Function(_$MarketplaceStateImpl) then) =
      __$$MarketplaceStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String searchQuery,
      TourCategory? selectedCategory,
      TourType? selectedTourType,
      bool isMapView,
      AsyncValue<List<TourModel>> filteredTours,
      List<CollectionModel> visibleCollections});
}

/// @nodoc
class __$$MarketplaceStateImplCopyWithImpl<$Res>
    extends _$MarketplaceStateCopyWithImpl<$Res, _$MarketplaceStateImpl>
    implements _$$MarketplaceStateImplCopyWith<$Res> {
  __$$MarketplaceStateImplCopyWithImpl(_$MarketplaceStateImpl _value,
      $Res Function(_$MarketplaceStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketplaceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searchQuery = null,
    Object? selectedCategory = freezed,
    Object? selectedTourType = freezed,
    Object? isMapView = null,
    Object? filteredTours = null,
    Object? visibleCollections = null,
  }) {
    return _then(_$MarketplaceStateImpl(
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      selectedCategory: freezed == selectedCategory
          ? _value.selectedCategory
          : selectedCategory // ignore: cast_nullable_to_non_nullable
              as TourCategory?,
      selectedTourType: freezed == selectedTourType
          ? _value.selectedTourType
          : selectedTourType // ignore: cast_nullable_to_non_nullable
              as TourType?,
      isMapView: null == isMapView
          ? _value.isMapView
          : isMapView // ignore: cast_nullable_to_non_nullable
              as bool,
      filteredTours: null == filteredTours
          ? _value.filteredTours
          : filteredTours // ignore: cast_nullable_to_non_nullable
              as AsyncValue<List<TourModel>>,
      visibleCollections: null == visibleCollections
          ? _value._visibleCollections
          : visibleCollections // ignore: cast_nullable_to_non_nullable
              as List<CollectionModel>,
    ));
  }
}

/// @nodoc

class _$MarketplaceStateImpl implements _MarketplaceState {
  const _$MarketplaceStateImpl(
      {this.searchQuery = '',
      this.selectedCategory = null,
      this.selectedTourType = null,
      this.isMapView = false,
      this.filteredTours = const AsyncValue.loading(),
      final List<CollectionModel> visibleCollections = const []})
      : _visibleCollections = visibleCollections;

  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final TourCategory? selectedCategory;
  @override
  @JsonKey()
  final TourType? selectedTourType;
  @override
  @JsonKey()
  final bool isMapView;
  @override
  @JsonKey()
  final AsyncValue<List<TourModel>> filteredTours;
  final List<CollectionModel> _visibleCollections;
  @override
  @JsonKey()
  List<CollectionModel> get visibleCollections {
    if (_visibleCollections is EqualUnmodifiableListView)
      return _visibleCollections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_visibleCollections);
  }

  @override
  String toString() {
    return 'MarketplaceState(searchQuery: $searchQuery, selectedCategory: $selectedCategory, selectedTourType: $selectedTourType, isMapView: $isMapView, filteredTours: $filteredTours, visibleCollections: $visibleCollections)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketplaceStateImpl &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            const DeepCollectionEquality()
                .equals(other.selectedCategory, selectedCategory) &&
            const DeepCollectionEquality()
                .equals(other.selectedTourType, selectedTourType) &&
            (identical(other.isMapView, isMapView) ||
                other.isMapView == isMapView) &&
            (identical(other.filteredTours, filteredTours) ||
                other.filteredTours == filteredTours) &&
            const DeepCollectionEquality()
                .equals(other._visibleCollections, _visibleCollections));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      searchQuery,
      const DeepCollectionEquality().hash(selectedCategory),
      const DeepCollectionEquality().hash(selectedTourType),
      isMapView,
      filteredTours,
      const DeepCollectionEquality().hash(_visibleCollections));

  /// Create a copy of MarketplaceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketplaceStateImplCopyWith<_$MarketplaceStateImpl> get copyWith =>
      __$$MarketplaceStateImplCopyWithImpl<_$MarketplaceStateImpl>(
          this, _$identity);
}

abstract class _MarketplaceState implements MarketplaceState {
  const factory _MarketplaceState(
      {final String searchQuery,
      final TourCategory? selectedCategory,
      final TourType? selectedTourType,
      final bool isMapView,
      final AsyncValue<List<TourModel>> filteredTours,
      final List<CollectionModel> visibleCollections}) = _$MarketplaceStateImpl;

  @override
  String get searchQuery;
  @override
  TourCategory? get selectedCategory;
  @override
  TourType? get selectedTourType;
  @override
  bool get isMapView;
  @override
  AsyncValue<List<TourModel>> get filteredTours;
  @override
  List<CollectionModel> get visibleCollections;

  /// Create a copy of MarketplaceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketplaceStateImplCopyWith<_$MarketplaceStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
