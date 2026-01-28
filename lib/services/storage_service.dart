import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../core/constants/app_constants.dart';

/// Service for uploading files to Firebase Storage.
/// Handles tour covers, audio files, images, and videos.
class StorageService {
  final FirebaseStorage _storage;

  StorageService({required FirebaseStorage storage}) : _storage = storage;

  /// Uploads tour cover image.
  /// TODO: Add image compression with flutter_image_compress package
  /// (quality: 85, maxWidth: 1920, maxHeight: 1080)
  Future<String> uploadTourCover({
    required String tourId,
    required Uint8List imageBytes,
  }) async {
    final path = StoragePaths.tourCover(tourId);
    final ref = _storage.ref(path);

    // Upload with metadata
    await ref.putData(
      imageBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await ref.getDownloadURL();
  }

  /// Uploads stop audio file from File object (mobile platforms).
  Future<String> uploadStopAudio({
    required String tourId,
    required String stopId,
    required File audioFile,
  }) async {
    final path = StoragePaths.tourAudio(tourId, stopId);
    final ref = _storage.ref(path);

    await ref.putFile(
      audioFile,
      SettableMetadata(contentType: 'audio/mpeg'),
    );

    return await ref.getDownloadURL();
  }

  /// Uploads stop audio from bytes (web platform or in-memory audio).
  Future<String> uploadStopAudioBytes({
    required String tourId,
    required String stopId,
    required Uint8List audioBytes,
  }) async {
    final path = StoragePaths.tourAudio(tourId, stopId);
    final ref = _storage.ref(path);

    await ref.putData(
      audioBytes,
      SettableMetadata(contentType: 'audio/mpeg'),
    );

    return await ref.getDownloadURL();
  }

  /// Uploads stop image from bytes.
  Future<String> uploadStopImageBytes({
    required String tourId,
    required String stopId,
    required int index,
    required Uint8List imageBytes,
  }) async {
    final path = StoragePaths.tourImage(tourId, stopId, index);
    final ref = _storage.ref(path);

    await ref.putData(
      imageBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await ref.getDownloadURL();
  }

  /// Uploads stop image from File (mobile platforms).
  Future<String> uploadStopImage({
    required String tourId,
    required String stopId,
    required File imageFile,
    required int imageIndex,
  }) async {
    final path = StoragePaths.tourImage(tourId, stopId, imageIndex);
    final ref = _storage.ref(path);

    await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await ref.getDownloadURL();
  }

  /// Uploads stop video.
  Future<String> uploadStopVideo({
    required String tourId,
    required String stopId,
    required File videoFile,
  }) async {
    final path = StoragePaths.tourVideo(tourId, stopId);
    final ref = _storage.ref(path);

    await ref.putFile(
      videoFile,
      SettableMetadata(contentType: 'video/mp4'),
    );

    return await ref.getDownloadURL();
  }

  /// Uploads user avatar from bytes.
  Future<String> uploadUserAvatar({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    final path = StoragePaths.userAvatar(userId);
    final ref = _storage.ref(path);

    await ref.putData(
      imageBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await ref.getDownloadURL();
  }

  /// Uploads user avatar from File (mobile platforms).
  Future<String> uploadUserAvatarFile({
    required String userId,
    required File imageFile,
  }) async {
    final path = StoragePaths.userAvatar(userId);
    final ref = _storage.ref(path);

    await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await ref.getDownloadURL();
  }

  /// Deletes a file at the given path.
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref(path);
      await ref.delete();
    } catch (e) {
      // File may not exist, ignore
    }
  }

  /// Gets download URL for a file at the given path.
  Future<String?> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref(path);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  /// Deletes all files for a tour (cover, audio, images, videos).
  Future<void> deleteTourFiles(String tourId) async {
    try {
      final tourRef = _storage.ref('tours/$tourId');
      final listResult = await tourRef.listAll();

      // Delete all files in the tour directory
      for (final item in listResult.items) {
        await item.delete();
      }

      // Recursively delete subdirectories
      for (final prefix in listResult.prefixes) {
        final subListResult = await prefix.listAll();
        for (final item in subListResult.items) {
          await item.delete();
        }
      }
    } catch (e) {
      // Ignore errors if files don't exist
    }
  }
}
