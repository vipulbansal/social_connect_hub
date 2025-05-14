

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_connect_hub/domain/core/usecase.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/firebase_service.dart';
import '../../../data/models/user.dart' as app_user;
import '../../../domain/entities/user/user_entity.dart';
import '../../../domain/repositories/auth/auth_repository.dart';
import '../../../domain/repositories/user/user_repository.dart';
import '../../../domain/usecases/auth/reset_password_usecase.dart';
import '../../../domain/usecases/auth/sign_in_usecase.dart';
import '../../../domain/usecases/auth/sign_out_usecase.dart';
import '../../../domain/usecases/auth/sign_up_usecase.dart';
import '../../../domain/usecases/user/get_user_by_id_usecase.dart';

/// Authentication service that manages user authentication state
/// using the Provider pattern and clean architecture principles.
enum AuthStatus { initial, authenticated, unauthenticated }
class AuthService extends ChangeNotifier {
  // Core repositories and use cases
  late AuthRepository _authRepository;
  late UserRepository _userRepository;
  late SignInUseCase _signInUseCase;
  late SignUpUseCase _signUpUseCase;
  late SignOutUseCase _signOutUseCase;
  late ResetPasswordUseCase _resetPasswordUseCase;

  // Authentication state
  UserEntity? _currentUser;
  bool _isAuthenticated = false;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters for state
  UserEntity? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserRepository get userRepository =>
      _userRepository; // Constructor - can be called without dependencies which will be
  // fetched from service locator, or with explicit dependencies for testing
  AuthService({
    AuthRepository? authRepository,
    UserRepository? userRepository,
    SignInUseCase? signInUseCase,
    SignUpUseCase? signUpUseCase,
    SignOutUseCase? signOutUseCase,
    ResetPasswordUseCase? resetPasswordUseCase,
  }) {
    _authRepository = authRepository ?? locator<AuthRepository>();
    _userRepository = userRepository ?? locator<UserRepository>();
    _signInUseCase = signInUseCase ?? locator<SignInUseCase>();
    _signUpUseCase = signUpUseCase ?? locator<SignUpUseCase>();
    _signOutUseCase = signOutUseCase ?? locator<SignOutUseCase>();
    _resetPasswordUseCase = resetPasswordUseCase ?? locator<ResetPasswordUseCase>();

    // Initialize authentication state
    _initializeAuthState();
  }

  // Initialize authentication state
  Future<void> _initializeAuthState() async {
    _isLoading = true;
    notifyListeners();

    final authResult = await _authRepository.isAuthenticated();

    if (authResult.isSuccess && authResult.fold(
      onSuccess: (isAuthenticated) => isAuthenticated,
      onFailure: (_) => false,
    )) {
      // User is authenticated, get the current user ID
      final userIdResult = await _authRepository.getCurrentUserId();

      if (userIdResult.isSuccess) {
        final userId = userIdResult.fold(
          onSuccess: (id) => id,
          onFailure: (_) => '',
        );

        if (userId.isNotEmpty) {
          // Get user details using the ID
          _isAuthenticated = true;
          final userResult = await _userRepository.getUserById(userId);

          userResult.fold(
              onSuccess: (user) async {
                _currentUser = user;

                // Register FCM token for existing authenticated user on app start
                try {
                  final firebaseService = locator<FirebaseService>();
                  final fcmToken = await firebaseService.messaging.getToken();
                  if (fcmToken != null) {
                    await firebaseService.updateFcmToken(user.id, fcmToken);
                  }
                } catch (e) {
                  print('Error registering FCM token on app initialization: $e');
                  // Continue even if token registration fails
                }

                _isInitialized = true;
                _isLoading = false;
                notifyListeners();
              },
              onFailure: (failure) {
                _errorMessage = failure.message;
                _isAuthenticated = false;
                _isInitialized = true;
                _isLoading = false;
                notifyListeners();
              }
          );
        } else {
          // Invalid user ID
          _isAuthenticated = false;
          _currentUser = null;
          _isInitialized = true;
          _isLoading = false;
          notifyListeners();
        }
      } else {
        // Failed to get user ID
        _isAuthenticated = false;
        _currentUser = null;
        _isInitialized = true;
        _isLoading = false;
        notifyListeners();
      }
    } else {
      // Not authenticated
      _isAuthenticated = false;
      _currentUser = null;
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Using the repository directly to ensure GoRouter's auth stream is triggered
    final result = await _authRepository.signInWithEmailAndPassword(email, password);

    return result.fold(
      onSuccess: (user) async {
        _currentUser = user;
        _isAuthenticated = true;

        // Register the FCM token for the user
        try {
          final firebaseService = locator<FirebaseService>();
          final fcmToken = await firebaseService.messaging.getToken();
          if (fcmToken != null) {
            await firebaseService.updateFcmToken(user.id, fcmToken);
          }
        } catch (e) {
          print('Error registering FCM token: $e');
          // Continue even if token registration fails
        }

        _isLoading = false;
        notifyListeners();
        return true;
      },
      onFailure: (failure) {
        _errorMessage = failure.message;
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return false;
      },
    );
  }

  // Sign up with name, email and password
  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Using the repository directly to ensure GoRouter's auth stream is triggered
    final result = await _authRepository.signUpWithEmailAndPassword(email, password, name);

    return result.fold(
      onSuccess: (user) async {
        _currentUser = user;
        _isAuthenticated = true;

        // Register the FCM token for the newly created user
        try {
          final firebaseService = locator<FirebaseService>();
          final fcmToken = await firebaseService.messaging.getToken();
          if (fcmToken != null) {
            await firebaseService.updateFcmToken(user.id, fcmToken);
          }
        } catch (e) {
          print('Error registering FCM token for new user: $e');
          // Continue even if token registration fails
        }

        _isLoading = false;
        notifyListeners();
        return true;
      },
      onFailure: (failure) {
        _errorMessage = failure.message;
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return false;
      },
    );
  }

  // Sign out the current user
  Future<bool> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Unregister the FCM token before signing out if we have a current user
    if (_currentUser != null) {
      try {
        final firebaseService = locator<FirebaseService>();
        final fcmToken = await firebaseService.messaging.getToken();
        if (fcmToken != null) {
          await firebaseService.removeFcmToken(_currentUser!.id, fcmToken);
        }
      } catch (e) {
        print('Error unregistering FCM token: $e');
        // Continue with signout even if token unregistration fails
      }
    }

    // Using the repository directly to ensure GoRouter's auth stream is triggered
    final result = await _authRepository.signOut();

    return result.fold(
      onSuccess: (_) {
        _currentUser = null;
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return true;
      },
      onFailure: (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
    );
  }

  // Reset password for an email
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.resetPassword(email);

    _isLoading = false;

    return result.fold(
      onSuccess: (_) {
        notifyListeners();
        return true;
      },
      onFailure: (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
    );
  }

  // Get current user ID
  Future<String?> getCurrentUserId() async {
    final result = await _authRepository.getCurrentUserId();

    return result.fold(
      onSuccess: (id) => id,
      onFailure: (_) => null,
    );
  }

  // Clear any error messages
  void clearErrors() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get user by ID
  /// Returns the user entity if found, null otherwise
  Future<UserEntity?> getUserById(String userId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _userRepository.getUserById(userId);

    _isLoading = false;
    notifyListeners();

    return result.fold(
      onSuccess: (user) => user,
      onFailure: (_) => null,
    );
  }

  /// Update user profile with the provided information
  /// Returns true on success, false on failure
  Future<bool> updateUserProfile({
    String? name,
    String? displayName,
    String? bio,
    String? location,
    String? website,
    String? phoneNumber,
    String? profilePictureUrl,
    String? bannerImageUrl,
  }) async {
    if (_currentUser == null) {
      _errorMessage = 'No authenticated user found';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Create an updated user entity with the new values
    final updatedUser = UserEntity(
      id: _currentUser!.id,
      name: name ?? _currentUser!.name,
      email: _currentUser!.email,
      photoUrl: profilePictureUrl ?? _currentUser!.photoUrl,
      bio: bio ?? _currentUser!.bio,
      phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
      createdAt: _currentUser!.createdAt,
      updatedAt: DateTime.now(),
      isOnline: _currentUser!.isOnline,
      lastSeen: _currentUser!.lastSeen,
    );

    final result = await _userRepository.updateUserProfile(updatedUser);

    return result.fold(
      onSuccess: (updatedUserEntity) {
        _currentUser = updatedUserEntity;
        _isLoading = false;
        notifyListeners();
        return true;
      },
      onFailure: (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
    );
  }
}