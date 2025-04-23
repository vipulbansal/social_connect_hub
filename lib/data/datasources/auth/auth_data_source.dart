import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../models/user.dart' as app_models;

/// Interface for authentication data source
abstract class AuthDataSource {
  /// Get current authentication state
  Stream<bool> get authStateChanges;

  /// Get current user ID if logged in
  String? get currentUserId;

  /// Sign in with email and password
  Future<firebase_auth.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Create new user with email and password
  Future<firebase_auth.UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Update user profile (display name, photo URL)
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  });

  /// Create a new user document in the database
  Future<void> createUserDocument(app_models.User user);

  /// Get user data from the database
  Future<app_models.User?> getUserData(String userId);

  /// Update user data in the database
  Future<void> updateUserData(String userId, Map<String, dynamic> data);

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Sign out user
  Future<void> signOut();

  /// Register device token for push notifications
  Future<void> registerDeviceToken(String userId, String token);

  /// Unregister device token
  Future<void> unregisterDeviceToken(String userId, String token);
}