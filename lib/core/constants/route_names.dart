class RouteNames {
  RouteNames._();

  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // User routes
  static const String home = '/home';
  static const String discover = '/discover';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String tourHistory = '/history';
  static const String achievements = '/achievements';
  static const String tourDetails = '/tour/:tourId';
  static const String tourPlayback = '/tour/:tourId/play';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';
  static const String downloads = '/downloads';

  // Creator routes
  static const String creatorDashboard = '/creator';
  static const String creatorAnalytics = '/creator/analytics';
  static const String createTour = '/creator/create';
  static const String editTour = '/creator/tour/:tourId/edit';
  static const String editStop = '/creator/tour/:tourId/stop/:stopId';
  static const String tourPreview = '/creator/tour/:tourId/preview';
  static const String creatorProfile = '/creator/profile';

  // Admin routes
  static const String adminDashboard = '/admin';
  static const String reviewQueue = '/admin/reviews';
  static const String reviewTour = '/admin/reviews/:tourId';
  static const String userManagement = '/admin/users';
  static const String allTours = '/admin/tours';
  static const String adminSettings = '/admin/settings';

  // Helper methods to build routes with parameters
  static String tourDetailsPath(String tourId) => '/tour/$tourId';
  static String tourPlaybackPath(String tourId) => '/tour/$tourId/play';
  static String editTourPath(String tourId) => '/creator/tour/$tourId/edit';
  static String editStopPath(String tourId, String stopId) =>
      '/creator/tour/$tourId/stop/$stopId';
  static String tourPreviewPath(String tourId) => '/creator/tour/$tourId/preview';
  static String reviewTourPath(String tourId) => '/admin/reviews/$tourId';
}
