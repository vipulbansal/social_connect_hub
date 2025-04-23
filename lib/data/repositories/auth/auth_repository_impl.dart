import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../domain/core/failures.dart';
import '../../../domain/core/result.dart';
import '../../../domain/entities/user/user_entity.dart';
import '../../../domain/repositories/auth/auth_repository.dart';
import '../../../features/auth/services/auth_service.dart';
import '../../datasources/auth/auth_data_source.dart';
import '../../models/user.dart' as app_models;

/// Implementation of the auth repository interface
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _authDataSource;

  /// Constructor
  const AuthRepositoryImpl({
    required AuthDataSource authDataSource,
  }) : _authDataSource = authDataSource;

  @override
  Future<Result<UserEntity>> signInWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      // Call data source to perform sign in
      final userCredential = await _authDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final userId = userCredential.user!.uid;
        final userData = await _authDataSource.getUserData(userId);

        if (userData != null) {
          return Result.success(_mapToUserEntity(userData));
        }
      }

      return Result.failure(
        AuthFailure('Failed to sign in. Please try again.'),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure(_getErrorMessage(e.code)));
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> signUpWithEmailAndPassword(
      String email,
      String password,
      String name,
      ) async {
    try {
      // Call data source to perform registration
      final userCredential = await _authDataSource.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final userId = userCredential.user!.uid;

        // Update profile
        await _authDataSource.updateUserProfile(
          displayName: name,
        );

        // Create user document
        final newUser = app_models.User(
          id: userId,
          name: name,
          email: email,
          friendIds: [],
          fcmTokens: [],
          createdAt: DateTime.now(),
          pendingFriendRequestIds: [],
        );

        await _authDataSource.createUserDocument(newUser);

        return Result.success(_mapToUserEntity(newUser));
      }

      return Result.failure(
        AuthFailure('Failed to create account. Please try again.'),);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure(_getErrorMessage(e.code)));
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _authDataSource.signOut();
      return  Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    try {
      await _authDataSource.sendPasswordResetEmail(email);
      return  Result.success(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure(_getErrorMessage(e.code)));
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> changePassword(
      String currentPassword,
      String newPassword,
      ) async {
    // This functionality requires reauthentication which we'll
    // need to implement in the data source
    return Result.failure(
       AuthFailure('Change password functionality not implemented'),
    );
  }

  @override
  Future<Result<bool>> isAuthenticated() async {
    try {
      final isAuthenticated = _authDataSource.currentUserId != null;
      return Result.success(isAuthenticated);
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<String>> getCurrentUserId() async {
    try {
      final userId = _authDataSource.currentUserId;
      if (userId != null) {
        return Result.success(userId);
      }
      return Result.failure(
         AuthFailure('No authenticated user found'),
      );
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Stream<bool> watchAuthState() {
    return _authDataSource.authStateChanges;
  }

  // Helper method to map app_models.User to UserEntity
  UserEntity _mapToUserEntity(app_models.User user) {
    return UserEntity(
      id: user.id,
      name: user.name,
      email: user.email,
      avatarUrl: user.profilePicUrl,
      bio: user.bio,
      isOnline: user.status == app_models.UserStatus.online,
      lastSeen: user.lastActive,
      fcmToken: user.fcmTokens.isNotEmpty ? user.fcmTokens.first : null,
      createdAt: user.createdAt,
      updatedAt: user.lastActive ?? user.createdAt,
    );
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Account creation is disabled.';
      default:
        return 'Authentication failed. Please try again later.';
    }
  }
}