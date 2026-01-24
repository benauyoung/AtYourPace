/// Application configuration
class AppConfig {
  /// Whether to run in demo mode (without Firebase)
  /// Set this to false when Firebase is configured
  static const bool demoMode = false;

  /// Demo user configuration
  static const String demoUserId = 'demo-user-001';
  static const String demoUserEmail = 'demo@example.com';
  static const String demoUserName = 'Demo User';

  /// Whether Firebase is properly configured
  /// This checks if the API keys are placeholders
  static bool get isFirebaseConfigured {
    // In a real app, you'd check the actual firebase_options.dart values
    // For now, we use demoMode flag
    return !demoMode;
  }
}
