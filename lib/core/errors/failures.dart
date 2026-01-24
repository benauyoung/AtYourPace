import 'package:equatable/equatable.dart';

/// Base failure class for the Result pattern
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});

  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: 'Invalid email or password',
        code: 'invalid-credentials',
      );

  factory AuthFailure.userNotFound() => const AuthFailure(
        message: 'No user found with this email',
        code: 'user-not-found',
      );

  factory AuthFailure.emailAlreadyInUse() => const AuthFailure(
        message: 'An account already exists with this email',
        code: 'email-already-in-use',
      );

  factory AuthFailure.networkError() => const AuthFailure(
        message: 'Network error. Please check your connection.',
        code: 'network-error',
      );

  factory AuthFailure.unknown() => const AuthFailure(
        message: 'An unexpected error occurred',
        code: 'unknown',
      );
}

class TourFailure extends Failure {
  const TourFailure({required super.message, super.code});

  factory TourFailure.notFound() => const TourFailure(
        message: 'Tour not found',
        code: 'tour-not-found',
      );

  factory TourFailure.accessDenied() => const TourFailure(
        message: 'You do not have permission to access this tour',
        code: 'access-denied',
      );

  factory TourFailure.createFailed() => const TourFailure(
        message: 'Failed to create tour',
        code: 'create-failed',
      );

  factory TourFailure.updateFailed() => const TourFailure(
        message: 'Failed to update tour',
        code: 'update-failed',
      );
}

class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code});

  factory StorageFailure.uploadFailed() => const StorageFailure(
        message: 'Failed to upload file',
        code: 'upload-failed',
      );

  factory StorageFailure.downloadFailed() => const StorageFailure(
        message: 'Failed to download file',
        code: 'download-failed',
      );

  factory StorageFailure.insufficientStorage() => const StorageFailure(
        message: 'Insufficient storage space',
        code: 'insufficient-storage',
      );
}

class LocationFailure extends Failure {
  const LocationFailure({required super.message, super.code});

  factory LocationFailure.permissionDenied() => const LocationFailure(
        message: 'Location permission denied',
        code: 'permission-denied',
      );

  factory LocationFailure.serviceDisabled() => const LocationFailure(
        message: 'Location services are disabled',
        code: 'service-disabled',
      );
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});

  factory NetworkFailure.noConnection() => const NetworkFailure(
        message: 'No internet connection',
        code: 'no-connection',
      );

  factory NetworkFailure.timeout() => const NetworkFailure(
        message: 'Request timed out',
        code: 'timeout',
      );

  factory NetworkFailure.serverError() => const NetworkFailure(
        message: 'Server error. Please try again later.',
        code: 'server-error',
      );
}

class RateLimitFailure extends Failure {
  final Duration? retryAfter;

  const RateLimitFailure({
    required super.message,
    super.code,
    this.retryAfter,
  });

  factory RateLimitFailure.elevenLabs() => const RateLimitFailure(
        message: 'Rate limit exceeded. Please wait before generating more audio.',
        code: 'rate-limit',
        retryAfter: Duration(minutes: 1),
      );

  @override
  List<Object?> get props => [message, code, retryAfter];
}

class OfflineFailure extends Failure {
  const OfflineFailure({required super.message, super.code});

  factory OfflineFailure.notDownloaded() => const OfflineFailure(
        message: 'This tour is not available offline',
        code: 'not-downloaded',
      );

  factory OfflineFailure.downloadExpired() => const OfflineFailure(
        message: 'Your offline download has expired',
        code: 'download-expired',
      );
}
