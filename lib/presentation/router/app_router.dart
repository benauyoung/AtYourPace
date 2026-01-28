import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_config.dart';
import '../../core/constants/route_names.dart';
import '../../data/models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/demo_auth_provider.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/user/home_screen.dart';
import '../screens/user/discover_screen.dart';
import '../screens/user/tour_details_screen.dart';
import '../screens/user/tour_playback_screen.dart' as playback;
import '../screens/user/profile_screen.dart';
import '../screens/user/edit_profile_screen.dart';
import '../screens/user/favorites_screen.dart';
import '../screens/user/tour_history_screen.dart';
import '../screens/user/achievements_screen.dart';
import '../screens/user/settings_screen.dart';
import '../screens/user/downloads_screen.dart';
import '../screens/user/legal_document_screen.dart';
import '../screens/user/help_screen.dart';
import '../screens/user/my_reviews_screen.dart';
import '../screens/creator/creator_dashboard_screen.dart';
import '../screens/creator/creator_analytics_screen.dart';
import '../screens/creator/tour_editor_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_settings_screen.dart';
import '../screens/admin/all_tours_screen.dart';
import '../screens/admin/review_queue_screen.dart';
import '../screens/admin/tour_review_screen.dart';
import '../screens/admin/user_management_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Use demo providers when in demo mode
  final authState = AppConfig.demoMode
      ? ref.watch(demoCurrentUserProvider)
      : ref.watch(authStateProvider);
  final currentUser = AppConfig.demoMode
      ? ref.watch(demoCurrentUserProvider)
      : ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: AppConfig.demoMode ? RouteNames.home : RouteNames.splash,
    debugLogDiagnostics: true,
    refreshListenable: RouterRefreshNotifier(ref),
    redirect: (context, state) {
      // In demo mode, skip authentication redirects
      if (AppConfig.demoMode) {
        final isSplash = state.matchedLocation == RouteNames.splash;
        final isLoggingIn = state.matchedLocation == RouteNames.login ||
            state.matchedLocation == RouteNames.register;

        // Redirect splash and login screens to home in demo mode
        if (isSplash || isLoggingIn) {
          return RouteNames.home;
        }
        return null;
      }

      final isLoading = authState.isLoading;
      final isLoggedIn = authState.valueOrNull != null;
      final hasResolved = !isLoading; // Auth state has resolved (data or error)
      final isLoggingIn = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register ||
          state.matchedLocation == RouteNames.forgotPassword;
      final isSplash = state.matchedLocation == RouteNames.splash;

      // If still loading auth state, stay on splash
      if (isLoading && isSplash) {
        return null;
      }

      // If auth has resolved and we're on splash, redirect appropriately
      if (hasResolved && isSplash) {
        return isLoggedIn ? RouteNames.home : RouteNames.login;
      }

      // If not logged in and not on auth pages, redirect to login
      if (!isLoggedIn && !isLoggingIn && !isSplash && hasResolved) {
        return RouteNames.login;
      }

      // If logged in and on login/register, redirect to home
      if (isLoggedIn && isLoggingIn) {
        return RouteNames.home;
      }

      // Check role-based access
      final user = currentUser.valueOrNull;
      if (user != null) {
        final isCreatorRoute = state.matchedLocation.startsWith('/creator');
        final isAdminRoute = state.matchedLocation.startsWith('/admin');

        if (isCreatorRoute && !user.isCreator) {
          return RouteNames.home;
        }

        if (isAdminRoute && !user.isAdmin) {
          return RouteNames.home;
        }
      }

      return null;
    },
    routes: [
      // Splash / Initial route
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.discover,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DiscoverScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Edit profile (outside shell for full-screen experience)
      GoRoute(
        path: RouteNames.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),

      // Favorites
      GoRoute(
        path: RouteNames.favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),

      // Tour History
      GoRoute(
        path: RouteNames.tourHistory,
        builder: (context, state) => const TourHistoryScreen(),
      ),

      // Achievements
      GoRoute(
        path: RouteNames.achievements,
        builder: (context, state) => const AchievementsScreen(),
      ),

      // Settings
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Downloads
      GoRoute(
        path: RouteNames.downloads,
        builder: (context, state) => const DownloadsScreen(),
      ),

      // Legal documents
      GoRoute(
        path: RouteNames.termsOfService,
        builder: (context, state) => const LegalDocumentScreen(
          documentType: LegalDocumentType.termsOfService,
        ),
      ),
      GoRoute(
        path: RouteNames.privacyPolicy,
        builder: (context, state) => const LegalDocumentScreen(
          documentType: LegalDocumentType.privacyPolicy,
        ),
      ),

      // Help
      GoRoute(
        path: RouteNames.help,
        builder: (context, state) => const HelpScreen(),
      ),

      // My Reviews
      GoRoute(
        path: RouteNames.myReviews,
        builder: (context, state) => const MyReviewsScreen(),
      ),

      // Tour routes
      GoRoute(
        path: '/tour/:tourId',
        builder: (context, state) => TourDetailsScreen(
          tourId: state.pathParameters['tourId']!,
        ),
        routes: [
          GoRoute(
            path: 'play',
            builder: (context, state) => playback.TourPlaybackScreen(
              tourId: state.pathParameters['tourId']!,
            ),
          ),
        ],
      ),

      // Creator routes
      GoRoute(
        path: RouteNames.creatorDashboard,
        builder: (context, state) => const CreatorDashboardScreen(),
        routes: [
          GoRoute(
            path: 'analytics',
            builder: (context, state) => const CreatorAnalyticsScreen(),
          ),
          GoRoute(
            path: 'create',
            builder: (context, state) => const TourEditorScreen(),
          ),
          GoRoute(
            path: 'tour/:tourId/edit',
            builder: (context, state) => TourEditorScreen(
              tourId: state.pathParameters['tourId'],
            ),
          ),
        ],
      ),

      // Admin routes
      GoRoute(
        path: RouteNames.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'reviews',
            builder: (context, state) => const ReviewQueueScreen(),
          ),
          GoRoute(
            path: 'reviews/:tourId',
            builder: (context, state) => TourReviewScreen(
              tourId: state.pathParameters['tourId']!,
            ),
          ),
          GoRoute(
            path: 'users',
            builder: (context, state) => const UserManagementScreen(),
          ),
          GoRoute(
            path: 'tours',
            builder: (context, state) => const AllToursScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const AdminSettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});

// Helper class to refresh GoRouter when auth state changes
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    // Listen to auth state changes and notify router to re-evaluate redirects
    ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });

    // Trigger initial check after a brief delay to ensure router is ready
    Future.microtask(() => notifyListeners());
  }
}

// Main shell with bottom navigation
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = AppConfig.demoMode
        ? ref.watch(demoCurrentUserProvider).value
        : ref.watch(currentUserProvider).value;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context, currentUser?.isCreator ?? false),
        onDestinationSelected: (index) => _onItemTapped(index, context, currentUser),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          if (currentUser?.isCreator ?? false)
            const NavigationDestination(
              icon: Icon(Icons.add_box_outlined),
              selectedIcon: Icon(Icons.add_box),
              label: 'Create',
            ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context, bool isCreator) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RouteNames.home)) return 0;
    if (location.startsWith(RouteNames.discover)) return 1;
    if (location.startsWith(RouteNames.creatorDashboard)) return 2;
    if (location.startsWith(RouteNames.profile)) {
      // Profile is index 3 for creators (4 tabs), index 2 for non-creators (3 tabs)
      return isCreator ? 3 : 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, UserModel? user) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.discover);
        break;
      case 2:
        if (user?.isCreator ?? false) {
          context.go(RouteNames.creatorDashboard);
        } else {
          context.go(RouteNames.profile);
        }
        break;
      case 3:
        context.go(RouteNames.profile);
        break;
    }
  }
}

// Splash screen - just shows loading UI while router handles navigation via redirect
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state - this triggers router refresh when state changes
    final authState = ref.watch(authStateProvider);

    // The router's redirect logic handles all navigation
    // This widget just needs to display loading UI

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.tour,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'AYP Tour Guide',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            authState.when(
              data: (_) => const CircularProgressIndicator(),
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text('Error: $e', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go(RouteNames.login),
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Error screen
class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'The page you are looking for does not exist.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

// Note: TourReviewScreen is now imported from screens/admin/tour_review_screen.dart
