/// Base exception for the app
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory AuthException.invalidCredentials() => const AuthException(
        message: 'Invalid email or password',
        code: 'invalid-credentials',
      );

  factory AuthException.userNotFound() => const AuthException(
        message: 'No user found with this email',
        code: 'user-not-found',
      );

  factory AuthException.emailAlreadyInUse() => const AuthException(
        message: 'An account already exists with this email',
        code: 'email-already-in-use',
      );

  factory AuthException.weakPassword() => const AuthException(
        message: 'Password is too weak',
        code: 'weak-password',
      );

  factory AuthException.networkError() => const AuthException(
        message: 'Network error. Please check your connection.',
        code: 'network-error',
      );

  factory AuthException.unknown([dynamic error]) => AuthException(
        message: 'An unexpected authentication error occurred',
        code: 'unknown',
        originalError: error,
      );
}

/// Tour related exceptions
class TourException extends AppException {
  const TourException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory TourException.notFound() => const TourException(
        message: 'Tour not found',
        code: 'tour-not-found',
      );

  factory TourException.accessDenied() => const TourException(
        message: 'You do not have permission to access this tour',
        code: 'access-denied',
      );

  factory TourException.alreadyPublished() => const TourException(
        message: 'This tour version is already published',
        code: 'already-published',
      );

  factory TourException.invalidVersion() => const TourException(
        message: 'Invalid tour version',
        code: 'invalid-version',
      );

  factory TourException.createFailed([dynamic error]) => TourException(
        message: 'Failed to create tour',
        code: 'create-failed',
        originalError: error,
      );

  factory TourException.updateFailed([dynamic error]) => TourException(
        message: 'Failed to update tour',
        code: 'update-failed',
        originalError: error,
      );
}

/// Storage/file related exceptions
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory StorageException.uploadFailed() => const StorageException(
        message: 'Failed to upload file',
        code: 'upload-failed',
      );

  factory StorageException.downloadFailed() => const StorageException(
        message: 'Failed to download file',
        code: 'download-failed',
      );

  factory StorageException.fileNotFound() => const StorageException(
        message: 'File not found',
        code: 'file-not-found',
      );

  factory StorageException.insufficientStorage() => const StorageException(
        message: 'Insufficient storage space',
        code: 'insufficient-storage',
      );

  factory StorageException.permissionDenied() => const StorageException(
        message: 'Storage permission denied',
        code: 'permission-denied',
      );
}

/// Location related exceptions
class LocationException extends AppException {
  const LocationException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory LocationException.permissionDenied() => const LocationException(
        message: 'Location permission denied',
        code: 'permission-denied',
      );

  factory LocationException.serviceDisabled() => const LocationException(
        message: 'Location services are disabled',
        code: 'service-disabled',
      );

  factory LocationException.timeout() => const LocationException(
        message: 'Location request timed out',
        code: 'timeout',
      );

  factory LocationException.unavailable() => const LocationException(
        message: 'Location is unavailable',
        code: 'unavailable',
      );
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory NetworkException.noConnection() => const NetworkException(
        message: 'No internet connection',
        code: 'no-connection',
      );

  factory NetworkException.timeout() => const NetworkException(
        message: 'Request timed out',
        code: 'timeout',
      );

  factory NetworkException.serverError() => const NetworkException(
        message: 'Server error. Please try again later.',
        code: 'server-error',
      );

  factory NetworkException.unknown([dynamic error]) => NetworkException(
        message: 'An unexpected network error occurred',
        code: 'unknown',
        originalError: error,
      );
}

/// Rate limiting exception
class RateLimitException extends AppException {
  final Duration? retryAfter;

  const RateLimitException({
    required super.message,
    super.code,
    super.originalError,
    this.retryAfter,
  });

  factory RateLimitException.elevenLabs() => const RateLimitException(
        message: 'Rate limit exceeded. Please wait 1 minute before generating more audio.',
        code: 'elevenlabs-rate-limit',
        retryAfter: Duration(minutes: 1),
      );
}

/// Offline related exceptions
class OfflineException extends AppException {
  const OfflineException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory OfflineException.tourNotDownloaded() => const OfflineException(
        message: 'This tour is not available offline. Please download it first.',
        code: 'not-downloaded',
      );

  factory OfflineException.downloadExpired() => const OfflineException(
        message: 'Your offline download has expired. Please re-download the tour.',
        code: 'download-expired',
      );

  factory OfflineException.maxDownloadsReached() => const OfflineException(
        message: 'Maximum offline tours limit reached. Please remove some downloads.',
        code: 'max-downloads-reached',
      );
}
