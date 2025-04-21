

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_connect_hub/core/di/firebase_service.dart';
import '../../../data/models/user.dart' as app_user;

enum AuthStatus {
  uninitialized,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}



class AuthService extends ChangeNotifier {
  final FirebaseService firebaseService;
  String? _errorMessage;
  User? _firebaseUser;

  AuthStatus get status => _status;

  String? get errorMessage => _errorMessage;

  // Auth state
  AuthStatus _status = AuthStatus.uninitialized;

  AuthService({required this.firebaseService});

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      await firebaseService.firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;

      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          _errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          _errorMessage = 'Email address is not valid.';
          break;
        case 'user-disabled':
          _errorMessage = 'This account has been disabled.';
          break;
        default:
          _errorMessage = 'Authentication failed. Please try again later.';
          break;
      }

      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'An unexpected error occurred.';
      notifyListeners();
      return false;
    }
  }

  // Register with email and password
  Future<bool> registerWithEmailAndPassword(
      String name,
      String email,
      String password,
      ) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      // Create user in Firebase Auth
      final userCredential = await firebaseService.firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(name);

        // Create user document in Firestore
        final newUser = app_user.User(
          id: user.uid,
          name: name,
          email: email,
          friendIds: [],
          profilePicUrl: null,
          fcmTokens: [],
          createdAt: DateTime.now(),
        );

        await firebaseService.firestore.collection('users').doc(user.uid).set(
          newUser.toJson(),
        );

        // Update FCM token if available
        final fcmToken = await firebaseService.messaging.getToken();
        if (fcmToken != null) {
          await firebaseService.updateFcmToken(user.uid, fcmToken);
        }

        return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = 'Failed to create user account.';
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;

      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage = 'This email is already registered.';
          break;
        case 'invalid-email':
          _errorMessage = 'Email address is not valid.';
          break;
        case 'weak-password':
          _errorMessage = 'Password is too weak.';
          break;
        case 'operation-not-allowed':
          _errorMessage = 'Account creation is disabled.';
          break;
        default:
          _errorMessage = 'Registration failed. Please try again later.';
          break;
      }

      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'An unexpected error occurred.';
      notifyListeners();
      return false;
    }
  }


  // Sign out
  Future<void> signOut() async {
    try {
      // Remove FCM token
      if (_firebaseUser != null) {
        final fcmToken = await firebaseService.messaging.getToken();
        if (fcmToken != null) {
          await firebaseService.removeFcmToken(_firebaseUser!.uid, fcmToken);
        }
      }

      await firebaseService.firebaseAuth.signOut();
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to sign out.';
      notifyListeners();
    }
  }

  // Password reset
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await firebaseService.firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send password reset email.';
      return false;
    }
  }


}

