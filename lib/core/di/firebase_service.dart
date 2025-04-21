import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../firebase_options.dart';

class FirebaseService{
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseMessaging messaging;

  // Constructor
  FirebaseService({
    required this.firebaseAuth,
    required this.firestore,
    required this.storage,
    required this.messaging,
  });

  /// Initialize Firebase services
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      print('Firebase initialized successfully');
      // Set up messaging permissions
      await _setupMessaging();
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
  }

  /// Set up Firebase Messaging for push notifications
  Future<void> _setupMessaging() async {
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

      // Set up message handlers
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
        }
      });

    } catch (e) {
      print('Error setting up messaging: $e');
    }
  }

  /// Update FCM token for the current user in Firestore
  Future<void> updateFcmToken(String userId, String token) async {
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