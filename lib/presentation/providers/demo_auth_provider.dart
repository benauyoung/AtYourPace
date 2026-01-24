import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_config.dart';
import '../../data/models/user_model.dart';

/// Demo user for testing without Firebase
final demoUser = UserModel(
  uid: AppConfig.demoUserId,
  email: AppConfig.demoUserEmail,
  displayName: AppConfig.demoUserName,
  role: UserRole.creator, // Give demo user creator access
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

/// Provider that returns a demo user stream
final demoAuthStateProvider = StreamProvider<UserModel?>((ref) {
  // Simulate a brief loading period, then return demo user
  return Stream.value(demoUser).asBroadcastStream();
});

/// Provider for demo current user
final demoCurrentUserProvider = StreamProvider<UserModel?>((ref) {
  return Stream.value(demoUser);
});

/// Demo auth state notifier
final demoAuthStateNotifierProvider =
    StateNotifierProvider<DemoAuthStateNotifier, DemoAuthState>((ref) {
  return DemoAuthStateNotifier();
});

class DemoAuthStateNotifier extends StateNotifier<DemoAuthState> {
  DemoAuthStateNotifier() : super(DemoAuthState.authenticated(demoUser));

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const DemoAuthState.loading();
    await Future.delayed(const Duration(milliseconds: 500));
    state = DemoAuthState.authenticated(demoUser);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    UserRole role = UserRole.user,
  }) async {
    state = const DemoAuthState.loading();
    await Future.delayed(const Duration(milliseconds: 500));
    final user = UserModel(
      uid: AppConfig.demoUserId,
      email: email,
      displayName: displayName,
      role: role,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = DemoAuthState.authenticated(user);
  }

  Future<void> signInWithGoogle() async {
    state = const DemoAuthState.loading();
    await Future.delayed(const Duration(milliseconds: 500));
    state = DemoAuthState.authenticated(demoUser);
  }

  Future<void> signOut() async {
    state = const DemoAuthState.unauthenticated();
  }

  void clearError() {
    if (state is DemoAuthStateError) {
      state = const DemoAuthState.initial();
    }
  }
}

/// Demo auth state
sealed class DemoAuthState {
  const DemoAuthState();

  const factory DemoAuthState.initial() = DemoAuthStateInitial;
  const factory DemoAuthState.loading() = DemoAuthStateLoading;
  const factory DemoAuthState.authenticated(UserModel user) =
      DemoAuthStateAuthenticated;
  const factory DemoAuthState.unauthenticated() = DemoAuthStateUnauthenticated;
  const factory DemoAuthState.error(String message) = DemoAuthStateError;

  bool get isLoading => this is DemoAuthStateLoading;
  bool get isAuthenticated => this is DemoAuthStateAuthenticated;
  bool get isError => this is DemoAuthStateError;
  bool get isInitial => this is DemoAuthStateInitial;

  UserModel? get user {
    if (this is DemoAuthStateAuthenticated) {
      return (this as DemoAuthStateAuthenticated).user;
    }
    return null;
  }

  String? get errorMessage {
    if (this is DemoAuthStateError) {
      return (this as DemoAuthStateError).message;
    }
    return null;
  }
}

class DemoAuthStateInitial extends DemoAuthState {
  const DemoAuthStateInitial();
}

class DemoAuthStateLoading extends DemoAuthState {
  const DemoAuthStateLoading();
}

class DemoAuthStateAuthenticated extends DemoAuthState {
  final UserModel _user;
  const DemoAuthStateAuthenticated(this._user);

  @override
  UserModel? get user => _user;
}

class DemoAuthStateUnauthenticated extends DemoAuthState {
  const DemoAuthStateUnauthenticated();
}

class DemoAuthStateError extends DemoAuthState {
  final String message;
  const DemoAuthStateError(this.message);

  @override
  String? get errorMessage => message;
}
