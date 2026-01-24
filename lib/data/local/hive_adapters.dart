import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/tour_model.dart';
import '../models/tour_version_model.dart';
import '../models/stop_model.dart';

// Type IDs for Hive adapters
// Keep these consistent - never change existing IDs
class HiveTypeIds {
  static const int cachedTour = 0;
  static const int cachedTourVersion = 1;
  static const int cachedStop = 2;
  static const int downloadedTour = 3;
  static const int tourStats = 4;
  static const int stopMedia = 5;
  static const int geoPoint = 6;
  static const int tourCategory = 7;
  static const int tourType = 8;
  static const int tourStatus = 9;
  static const int tourDifficulty = 10;
  static const int audioSource = 11;
}

// Box names
class HiveBoxNames {
  static const String cachedTours = 'cached_tours';
  static const String cachedVersions = 'cached_versions';
  static const String cachedStops = 'cached_stops';
  static const String downloads = 'downloads';
  static const String userProgress = 'user_progress';
  static const String settings = 'settings';
}

/// Cached tour for offline storage
@HiveType(typeId: HiveTypeIds.cachedTour)
class CachedTour extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String creatorId;

  @HiveField(2)
  final String creatorName;

  @HiveField(3)
  final String? slug;

  @HiveField(4)
  final int categoryIndex;

  @HiveField(5)
  final int tourTypeIndex;

  @HiveField(6)
  final int statusIndex;

  @HiveField(7)
  final bool featured;

  @HiveField(8)
  final double startLatitude;

  @HiveField(9)
  final double startLongitude;

  @HiveField(10)
  final String geohash;

  @HiveField(11)
  final String? city;

  @HiveField(12)
  final String? country;

  @HiveField(13)
  final String? liveVersionId;

  @HiveField(14)
  final int? liveVersion;

  @HiveField(15)
  final String? draftVersionId;

  @HiveField(16)
  final int? draftVersion;

  @HiveField(17)
  final int totalPlays;

  @HiveField(18)
  final int totalDownloads;

  @HiveField(19)
  final double averageRating;

  @HiveField(20)
  final int totalRatings;

  @HiveField(21)
  final DateTime createdAt;

  @HiveField(22)
  final DateTime updatedAt;

  @HiveField(23)
  final DateTime? publishedAt;

  @HiveField(24)
  final DateTime cachedAt;

  CachedTour({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    this.slug,
    required this.categoryIndex,
    required this.tourTypeIndex,
    required this.statusIndex,
    required this.featured,
    required this.startLatitude,
    required this.startLongitude,
    required this.geohash,
    this.city,
    this.country,
    this.liveVersionId,
    this.liveVersion,
    this.draftVersionId,
    this.draftVersion,
    required this.totalPlays,
    required this.totalDownloads,
    required this.averageRating,
    required this.totalRatings,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    required this.cachedAt,
  });

  factory CachedTour.fromTourModel(TourModel tour) {
    return CachedTour(
      id: tour.id,
      creatorId: tour.creatorId,
      creatorName: tour.creatorName,
      slug: tour.slug,
      categoryIndex: tour.category.index,
      tourTypeIndex: tour.tourType.index,
      statusIndex: tour.status.index,
      featured: tour.featured,
      startLatitude: tour.startLocation.latitude,
      startLongitude: tour.startLocation.longitude,
      geohash: tour.geohash,
      city: tour.city,
      country: tour.country,
      liveVersionId: tour.liveVersionId,
      liveVersion: tour.liveVersion,
      draftVersionId: tour.draftVersionId,
      draftVersion: tour.draftVersion,
      totalPlays: tour.stats.totalPlays,
      totalDownloads: tour.stats.totalDownloads,
      averageRating: tour.stats.averageRating,
      totalRatings: tour.stats.totalRatings,
      createdAt: tour.createdAt,
      updatedAt: tour.updatedAt,
      publishedAt: tour.publishedAt,
      cachedAt: DateTime.now(),
    );
  }

  TourModel toTourModel() {
    return TourModel(
      id: id,
      creatorId: creatorId,
      creatorName: creatorName,
      slug: slug,
      category: TourCategory.values[categoryIndex],
      tourType: TourType.values[tourTypeIndex],
      status: TourStatus.values[statusIndex],
      featured: featured,
      startLocation: GeoPoint(startLatitude, startLongitude),
      geohash: geohash,
      city: city,
      country: country,
      liveVersionId: liveVersionId,
      liveVersion: liveVersion,
      draftVersionId: draftVersionId ?? 'v1',
      draftVersion: draftVersion ?? 1,
      stats: TourStats(
        totalPlays: totalPlays,
        totalDownloads: totalDownloads,
        averageRating: averageRating,
        totalRatings: totalRatings,
      ),
      createdAt: createdAt,
      updatedAt: updatedAt,
      publishedAt: publishedAt,
    );
  }

  bool get isExpired {
    // Cache expires after 1 hour
    return DateTime.now().difference(cachedAt).inHours > 1;
  }
}

/// Cached tour version for offline storage
@HiveType(typeId: HiveTypeIds.cachedTourVersion)
class CachedTourVersion extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String tourId;

  @HiveField(2)
  final int versionNumber;

  @HiveField(3)
  final int versionTypeIndex;

  @HiveField(4)
  final String title;

  @HiveField(5)
  final String description;

  @HiveField(6)
  final String? coverImageUrl;

  @HiveField(7)
  final String? duration;

  @HiveField(8)
  final String? distance;

  @HiveField(9)
  final int difficultyIndex;

  @HiveField(10)
  final List<String> languages;

  @HiveField(11)
  final String? encodedPolyline;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  final DateTime updatedAt;

  @HiveField(14)
  final DateTime cachedAt;

  CachedTourVersion({
    required this.id,
    required this.tourId,
    required this.versionNumber,
    required this.versionTypeIndex,
    required this.title,
    required this.description,
    this.coverImageUrl,
    this.duration,
    this.distance,
    required this.difficultyIndex,
    required this.languages,
    this.encodedPolyline,
    required this.createdAt,
    required this.updatedAt,
    required this.cachedAt,
  });

  factory CachedTourVersion.fromVersionModel(TourVersionModel version) {
    return CachedTourVersion(
      id: version.id,
      tourId: version.tourId,
      versionNumber: version.versionNumber,
      versionTypeIndex: version.versionType.index,
      title: version.title,
      description: version.description,
      coverImageUrl: version.coverImageUrl,
      duration: version.duration,
      distance: version.distance,
      difficultyIndex: version.difficulty.index,
      languages: version.languages,
      encodedPolyline: version.route?.encodedPolyline,
      createdAt: version.createdAt,
      updatedAt: version.updatedAt,
      cachedAt: DateTime.now(),
    );
  }

  TourVersionModel toVersionModel() {
    return TourVersionModel(
      id: id,
      tourId: tourId,
      versionNumber: versionNumber,
      versionType: VersionType.values[versionTypeIndex],
      title: title,
      description: description,
      coverImageUrl: coverImageUrl,
      duration: duration,
      distance: distance,
      difficulty: TourDifficulty.values[difficultyIndex],
      languages: languages,
      route: encodedPolyline != null
          ? TourRoute(encodedPolyline: encodedPolyline)
          : null,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Cached stop for offline storage
@HiveType(typeId: HiveTypeIds.cachedStop)
class CachedStop extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String tourId;

  @HiveField(2)
  final String versionId;

  @HiveField(3)
  final int order;

  @HiveField(4)
  final String name;

  @HiveField(5)
  final String description;

  @HiveField(6)
  final double latitude;

  @HiveField(7)
  final double longitude;

  @HiveField(8)
  final String geohash;

  @HiveField(9)
  final int triggerRadius;

  @HiveField(10)
  final String? audioUrl;

  @HiveField(11)
  final String? localAudioPath;

  @HiveField(12)
  final int audioSourceIndex;

  @HiveField(13)
  final int? audioDuration;

  @HiveField(14)
  final String? audioText;

  @HiveField(15)
  final List<String> imageUrls;

  @HiveField(16)
  final List<String> localImagePaths;

  @HiveField(17)
  final DateTime createdAt;

  @HiveField(18)
  final DateTime updatedAt;

  @HiveField(19)
  final DateTime cachedAt;

  CachedStop({
    required this.id,
    required this.tourId,
    required this.versionId,
    required this.order,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.triggerRadius,
    this.audioUrl,
    this.localAudioPath,
    required this.audioSourceIndex,
    this.audioDuration,
    this.audioText,
    required this.imageUrls,
    required this.localImagePaths,
    required this.createdAt,
    required this.updatedAt,
    required this.cachedAt,
  });

  factory CachedStop.fromStopModel(StopModel stop, {String? localAudioPath, List<String>? localImagePaths}) {
    return CachedStop(
      id: stop.id,
      tourId: stop.tourId,
      versionId: stop.versionId,
      order: stop.order,
      name: stop.name,
      description: stop.description,
      latitude: stop.location.latitude,
      longitude: stop.location.longitude,
      geohash: stop.geohash,
      triggerRadius: stop.triggerRadius,
      audioUrl: stop.media.audioUrl,
      localAudioPath: localAudioPath,
      audioSourceIndex: stop.media.audioSource.index,
      audioDuration: stop.media.audioDuration,
      audioText: stop.media.audioText,
      imageUrls: stop.media.images.map((i) => i.url).toList(),
      localImagePaths: localImagePaths ?? [],
      createdAt: stop.createdAt,
      updatedAt: stop.updatedAt,
      cachedAt: DateTime.now(),
    );
  }

  StopModel toStopModel() {
    return StopModel(
      id: id,
      tourId: tourId,
      versionId: versionId,
      order: order,
      name: name,
      description: description,
      location: GeoPoint(latitude, longitude),
      geohash: geohash,
      triggerRadius: triggerRadius,
      media: StopMedia(
        audioUrl: localAudioPath ?? audioUrl,
        audioSource: AudioSource.values[audioSourceIndex],
        audioDuration: audioDuration,
        audioText: audioText,
        images: imageUrls.asMap().entries.map((e) => StopImage(
          url: localImagePaths.length > e.key ? localImagePaths[e.key] : e.value,
          order: e.key,
        )).toList(),
      ),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Downloaded tour metadata
@HiveType(typeId: HiveTypeIds.downloadedTour)
class DownloadedTour extends HiveObject {
  @HiveField(0)
  final String tourId;

  @HiveField(1)
  final String versionId;

  @HiveField(2)
  final DateTime downloadedAt;

  @HiveField(3)
  final DateTime? expiresAt;

  @HiveField(4)
  final int fileSize;

  @HiveField(5)
  final String status; // 'downloading', 'complete', 'failed', 'expired'

  @HiveField(6)
  final double downloadProgress;

  @HiveField(7)
  final String? errorMessage;

  DownloadedTour({
    required this.tourId,
    required this.versionId,
    required this.downloadedAt,
    this.expiresAt,
    required this.fileSize,
    required this.status,
    this.downloadProgress = 0.0,
    this.errorMessage,
  });

  bool get isComplete => status == 'complete';
  bool get isDownloading => status == 'downloading';
  bool get isFailed => status == 'failed';
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  DownloadedTour copyWith({
    String? tourId,
    String? versionId,
    DateTime? downloadedAt,
    DateTime? expiresAt,
    int? fileSize,
    String? status,
    double? downloadProgress,
    String? errorMessage,
  }) {
    return DownloadedTour(
      tourId: tourId ?? this.tourId,
      versionId: versionId ?? this.versionId,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      fileSize: fileSize ?? this.fileSize,
      status: status ?? this.status,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
