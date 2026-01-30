import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart';

part 'collection_model.freezed.dart';
part 'collection_model.g.dart';

enum CollectionType {
  @JsonValue('geographic')
  geographic,
  @JsonValue('thematic')
  thematic,
  @JsonValue('seasonal')
  seasonal,
  @JsonValue('custom')
  custom,
}

@freezed
class CollectionModel with _$CollectionModel {
  const CollectionModel._();

  const factory CollectionModel({
    required String id,
    required String name,
    required String description,
    String? coverImageUrl,
    required List<String> tourIds,
    @Default(true) bool isCurated,
    String? curatorId,
    String? curatorName,
    @Default(false) bool isFeatured,
    @Default([]) List<String> tags,
    @Default(CollectionType.geographic) CollectionType type,
    @Default(0) int sortOrder,
    String? city,
    String? region,
    String? country,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _CollectionModel;

  factory CollectionModel.fromJson(Map<String, dynamic> json) =>
      _$CollectionModelFromJson(json);

  factory CollectionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CollectionModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// Get the number of tours in this collection
  int get tourCount => tourIds.length;

  /// Check if collection has tours
  bool get hasTours => tourIds.isNotEmpty;

  /// Check if collection is empty
  bool get isEmpty => tourIds.isEmpty;

  /// Check if collection has a cover image
  bool get hasCoverImage => coverImageUrl != null && coverImageUrl!.isNotEmpty;

  /// Check if a tour is in this collection
  bool containsTour(String tourId) => tourIds.contains(tourId);

  /// Get display location
  String? get locationDisplay {
    if (city != null) return city;
    if (region != null) return region;
    return country;
  }

  /// Get type display name
  String get typeDisplay {
    switch (type) {
      case CollectionType.geographic:
        return 'Geographic';
      case CollectionType.thematic:
        return 'Thematic';
      case CollectionType.seasonal:
        return 'Seasonal';
      case CollectionType.custom:
        return 'Custom';
    }
  }

  /// Get type icon name
  String get typeIcon {
    switch (type) {
      case CollectionType.geographic:
        return 'location_on';
      case CollectionType.thematic:
        return 'category';
      case CollectionType.seasonal:
        return 'event';
      case CollectionType.custom:
        return 'folder';
    }
  }
}

/// Predefined Paris collections
class ParisCollections {
  static const List<Map<String, dynamic>> predefined = [
    {
      'name': 'Iconic Paris',
      'description':
          'Must-see landmarks: Eiffel Tower, Louvre, Notre-Dame, Arc de Triomphe',
      'type': 'geographic',
      'tags': ['landmarks', 'famous', 'must-see'],
      'sortOrder': 1,
      'city': 'Paris',
      'country': 'France',
    },
    {
      'name': 'Hidden Montmartre',
      'description':
          'Off-the-beaten-path gems in the artistic Montmartre neighborhood',
      'type': 'geographic',
      'tags': ['montmartre', 'hidden', 'local'],
      'sortOrder': 2,
      'city': 'Paris',
      'country': 'France',
    },
    {
      'name': 'Seine Riverside',
      'description': 'Scenic tours along the beautiful Seine river banks',
      'type': 'geographic',
      'tags': ['seine', 'river', 'scenic'],
      'sortOrder': 3,
      'city': 'Paris',
      'country': 'France',
    },
    {
      'name': 'Art & Museums',
      'description': 'World-class museums: Louvre, Orsay, Rodin, Picasso',
      'type': 'thematic',
      'tags': ['art', 'museums', 'culture'],
      'sortOrder': 4,
      'city': 'Paris',
      'country': 'France',
    },
    {
      'name': 'Historic Paris',
      'description': 'Medieval quarters, Latin Quarter, Le Marais',
      'type': 'thematic',
      'tags': ['history', 'medieval', 'heritage'],
      'sortOrder': 5,
      'city': 'Paris',
      'country': 'France',
    },
    {
      'name': "Foodie's Paris",
      'description': 'Markets, bakeries, restaurants, wine bars',
      'type': 'thematic',
      'tags': ['food', 'gastronomy', 'culinary'],
      'sortOrder': 6,
      'city': 'Paris',
      'country': 'France',
    },
    {
      'name': 'Romantic Paris',
      'description': 'Perfect tours for couples and romantic spots',
      'type': 'thematic',
      'tags': ['romantic', 'couples', 'love'],
      'sortOrder': 7,
      'city': 'Paris',
      'country': 'France',
    },
    {
      'name': 'Paris by Night',
      'description': 'Evening and nighttime tours of illuminated Paris',
      'type': 'seasonal',
      'tags': ['night', 'evening', 'lights'],
      'sortOrder': 8,
      'city': 'Paris',
      'country': 'France',
    },
    {
      'name': 'Literary Paris',
      'description': "Shakespeare & Co, historic cafés, writer haunts",
      'type': 'thematic',
      'tags': ['literature', 'books', 'writers'],
      'sortOrder': 9,
      'city': 'Paris',
      'country': 'France',
    },
    {
      'name': 'Modern Paris',
      'description': 'La Défense, contemporary architecture, new Paris',
      'type': 'geographic',
      'tags': ['modern', 'contemporary', 'architecture'],
      'sortOrder': 10,
      'city': 'Paris',
      'country': 'France',
    },
  ];

  /// Create CollectionModel from predefined data
  static CollectionModel createFromPredefined(
    Map<String, dynamic> data, {
    required String id,
    required String curatorId,
    required String curatorName,
  }) {
    final now = DateTime.now();
    return CollectionModel(
      id: id,
      name: data['name'] as String,
      description: data['description'] as String,
      tourIds: const [],
      isCurated: true,
      curatorId: curatorId,
      curatorName: curatorName,
      isFeatured: true,
      tags: (data['tags'] as List<dynamic>).cast<String>(),
      type: _parseCollectionType(data['type'] as String),
      sortOrder: data['sortOrder'] as int,
      city: data['city'] as String?,
      country: data['country'] as String?,
      createdAt: now,
      updatedAt: now,
    );
  }

  static CollectionType _parseCollectionType(String type) {
    switch (type) {
      case 'geographic':
        return CollectionType.geographic;
      case 'thematic':
        return CollectionType.thematic;
      case 'seasonal':
        return CollectionType.seasonal;
      default:
        return CollectionType.custom;
    }
  }
}

extension CollectionTypeExtension on CollectionType {
  String get displayName {
    switch (this) {
      case CollectionType.geographic:
        return 'Geographic';
      case CollectionType.thematic:
        return 'Thematic';
      case CollectionType.seasonal:
        return 'Seasonal';
      case CollectionType.custom:
        return 'Custom';
    }
  }

  String get description {
    switch (this) {
      case CollectionType.geographic:
        return 'Tours in a specific location or area';
      case CollectionType.thematic:
        return 'Tours around a common theme';
      case CollectionType.seasonal:
        return 'Tours for specific seasons or times';
      case CollectionType.custom:
        return 'Custom curated collection';
    }
  }
}
