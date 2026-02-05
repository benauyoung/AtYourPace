import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../data/models/user_model.dart';

// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Auth state stream provider
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// Current user data provider
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);

      return ref
          .watch(firestoreProvider)
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .snapshots()
          .map((doc) {
        if (!doc.exists) return null;
        return UserModel.fromFirestore(doc);
      });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  User? get currentUser => _auth.currentUser;

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException.unknown();
      }

      // Check if user document exists in Firestore
      final userDoc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Create user document if it doesn't exist (can happen if signup failed to create doc)
        final user = UserModel(
          uid: credential.user!.uid,
          email: credential.user!.email ?? email,
          displayName: credential.user!.displayName ?? email.split('@').first,
          photoUrl: credential.user!.photoURL,
          role: UserRole.user,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection(FirestoreCollections.users)
            .doc(user.uid)
            .set(user.toFirestore());

        return user;
      }

      return UserModel.fromFirestore(userDoc);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      // Handle any other exceptions (Firestore errors, etc.)
      throw AuthException.unknown(e);
    }
  }

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    UserRole role = UserRole.user,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException.unknown();
      }

      await credential.user!.updateDisplayName(displayName);

      final user = UserModel(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .set(user.toFirestore());

      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException.unknown(e);
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException(message: 'Google sign-in was cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw AuthException.unknown();
      }

      // Check if user exists in Firestore
      final userDoc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Create new user document
        final user = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName ?? '',
          photoUrl: userCredential.user!.photoURL,
          role: UserRole.user,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection(FirestoreCollections.users)
            .doc(user.uid)
            .set(user.toFirestore());

        return user;
      }

      return UserModel.fromFirestore(userDoc);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  Future<UserModel> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException(message: 'No authenticated user');
    }

    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }

    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (displayName != null) updates['displayName'] = displayName;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    await _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .update(updates);

    return await _getUserData(user.uid);
  }

  /// Updates the full user profile including preferences and creator bio.
  Future<UserModel> updateFullProfile({
    String? displayName,
    String? photoUrl,
    String? bio,
    UserPreferences? preferences,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException(message: 'No authenticated user');
    }

    // Update Firebase Auth profile
    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }

    // Build Firestore update map
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (displayName != null) {
      updates['displayName'] = displayName;
    }
    if (photoUrl != null) {
      updates['photoUrl'] = photoUrl;
    }
    if (bio != null) {
      updates['creatorProfile.bio'] = bio;
    }
    if (preferences != null) {
      updates['preferences'] = preferences.toJson();
    }

    await _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .update(updates);

    return await _getUserData(user.uid);
  }

  /// Deletes the current user's account and all associated data.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException(message: 'No authenticated user');
    }

    // Delete user document from Firestore
    await _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .delete();

    // Delete Firebase Auth account
    await user.delete();
  }

  Future<void> updateUserRole(String userId, UserRole role) async {
    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'role': role.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel> _getUserData(String uid) async {
    final doc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .get();

    if (!doc.exists) {
      throw AuthException.userNotFound();
    }

    return UserModel.fromFirestore(doc);
  }

  /// Dev login: tries sign-in first, creates account if it doesn't exist.
  Future<UserModel> devSignIn({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      return await signInWithEmailAndPassword(email: email, password: password);
    } catch (_) {
      // Account likely doesn't exist — create it
      try {
        return await signUpWithEmailAndPassword(
          email: email,
          password: password,
          displayName: displayName,
        );
      } on AuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Account exists but sign-in failed — password mismatch in Firebase
          // Delete and recreate by signing in fresh
          rethrow;
        }
        rethrow;
      }
    }
  }

  AuthException _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException.userNotFound();
      case 'wrong-password':
      case 'invalid-credential':
        return AuthException.invalidCredentials();
      case 'email-already-in-use':
        return AuthException.emailAlreadyInUse();
      case 'weak-password':
        return AuthException.weakPassword();
      case 'network-request-failed':
        return AuthException.networkError();
      default:
        return AuthException.unknown(e);
    }
  }
}

// Auth state notifier for UI state management
final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.watch(authServiceProvider));
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(const AuthState.initial());

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(user);
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    UserRole role = UserRole.user,
  }) async {
    state = const AuthState.loading();
    try {
      final user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      state = AuthState.authenticated(user);
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();
    try {
      final user = await _authService.signInWithGoogle();
      state = AuthState.authenticated(user);
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState.unauthenticated();
  }

  Future<void> devSignIn({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AuthState.loading();
    try {
      final user = await _authService.devSignIn(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AuthState.authenticated(user);
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  void clearError() {
    if (state is AuthStateError) {
      state = const AuthState.initial();
    }
  }
}

// Auth state sealed class
sealed class AuthState {
  const AuthState();

  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.authenticated(UserModel user) = AuthStateAuthenticated;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.error(String message) = AuthStateError;

  // Helper getters for type checking
  bool get isLoading => this is AuthStateLoading;
  bool get isAuthenticated => this is AuthStateAuthenticated;
  bool get isError => this is AuthStateError;
  bool get isInitial => this is AuthStateInitial;

  // Helper to get user if authenticated
  UserModel? get user {
    if (this is AuthStateAuthenticated) {
      return (this as AuthStateAuthenticated).user;
    }
    return null;
  }

  // Helper to get error message
  String? get errorMessage {
    if (this is AuthStateError) {
      return (this as AuthStateError).message;
    }
    return null;
  }
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  final UserModel _user;
  const AuthStateAuthenticated(this._user);

  @override
  UserModel? get user => _user;
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateError extends AuthState {
  final String message;
  const AuthStateError(this.message);

  @override
  String? get errorMessage => message;
}
