import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

class FirebaseService {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseMessaging messaging;
  bool isFirebaseInitialized = false;

  // Constructor
  FirebaseService({
    required this.firebaseAuth,
    required this.firestore,
    required this.storage,
    required this.messaging,
    this.isFirebaseInitialized=false,
  });

  /// Initialize Firebase services
  Future<void> initialize() async {
    try {
      // For web, we need to take a different approach due to compatibility issues
      if (kIsWeb) {
        print('Running in web mode with limited Firebase functionality');
        return;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      isFirebaseInitialized = true;
      print('Firebase initialized successfully');

      // Set up messaging permissions if not on web
      if (!kIsWeb) {
        await _setupMessaging();
      } else {
        print('Skipping messaging setup on web platform');
      }
    } catch (e) {
      print('Error initializing Firebase: $e');
      // Don't rethrow so app can continue without Firebase
      isFirebaseInitialized = false;
      print('Application will run without Firebase functionality');
    }
  }

  /// Set up Firebase Messaging for push notifications
  Future<void> _setupMessaging() async {
    if (!isFirebaseInitialized) return;

    try {
      // Request permission for notifications
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      print('User granted notification permission: ${settings.authorizationStatus}');

      // Get FCM token
      final token = await messaging.getToken();
      print('FCM Token: $token');

      // Save the token for the current user if they're logged in
      final currentUser = firebaseAuth.currentUser;
      if (currentUser != null && token != null) {
        await updateFcmToken(currentUser.uid, token);
      }

      // Listen for token refresh events
      messaging.onTokenRefresh.listen((newToken) async {
        print('FCM Token refreshed: $newToken');
        final user = firebaseAuth.currentUser;
        if (user != null) {
          await updateFcmToken(user.uid, newToken);
        }
      });

      // Set up message handlers
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
        }
      });

      if (!kIsWeb) {
        // Background handlers don't work on web
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      }

    } catch (e) {
      print('Error setting up messaging: $e');
    }
  }

  /// Update FCM token for the current user in Firestore
  Future<void> updateFcmToken(String userId, String token) async {
    if (!isFirebaseInitialized) return;

    try {
      await firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
      print('FCM token updated successfully for user: $userId');
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  /// Remove FCM token when user logs out
  Future<void> removeFcmToken(String userId, String token) async {
    if (!isFirebaseInitialized) return;

    try {
      await firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
      print('FCM token removed successfully for user: $userId');
    } catch (e) {
      print('Error removing FCM token: $e');
    }
  }
}



/// Background message handler
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Need to initialize Firebase in background handler as well
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');

  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
  }
}