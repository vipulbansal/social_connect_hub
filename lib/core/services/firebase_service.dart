import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import 'local_notification_service.dart';
import '../di/service_locator.dart';

/// A service class that provides access to Firebase services and handles
/// Firebase initialization.
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
          _showLocalNotificationForPushMessage(message);
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
      // First check if the user document exists
      final userDoc = await firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        // Update existing document
        await firestore.collection('users').doc(userId).update({
          'fcmTokens': FieldValue.arrayUnion([token]),
        });
      } else {
        // Handle the case where user document might not exist yet
        // by using set with merge option instead of update
        await firestore.collection('users').doc(userId).set({
          'fcmTokens': [token],
          'lastActive': FieldValue.serverTimestamp(),
        },SetOptions(merge: true));
      }
      
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
  
  /// Show a local notification for a received push message
  Future<void> _showLocalNotificationForPushMessage(RemoteMessage message) async {
    try {
      final localNotificationService = locator<LocalNotificationService>();
      
      // Extract notification details
      final title = message.notification?.title ?? 'New Notification';
      final body = message.notification?.body ?? '';
      
      // Extract notification type from data payload
      final notificationType = message.data['type'] ?? 'unknown';
      final senderId = message.data['senderId'] ?? '';
      final senderName = message.data['senderName'] ?? 'Someone';
      final chatId = message.data['chatId'];
      
      // Show the appropriate type of notification
      switch (notificationType) {
        case 'friend_request':
          await localNotificationService.showFriendRequestNotification(
            senderId: senderId,
            senderName: senderName,
          );
          break;
        
        case 'friend_accept':
          await localNotificationService.showNotification(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            title: 'Friend Request Accepted',
            body: '$senderName accepted your friend request',
            payload: 'friend_accepted_$senderId',
          );
          break;
          
        case 'message':
          await localNotificationService.showMessageNotification(
            senderId: senderId,
            senderName: senderName,
            message: body,
            chatId: chatId,
          );
          break;
          
        default:
          // For any other type, just show a generic notification
          await localNotificationService.showNotification(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            title: title,
            body: body,
            payload: notificationType,
          );
      }
    } catch (e) {
      print('Error showing local notification for push message: $e');
    }
  }
}

/// Background message handler
/// Background message handler
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Important: Firebase must be initialized
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('Handling a background message: ${message.messageId}');
    print('Message data: ${message.data}');

    final localNotificationService = locator<LocalNotificationService>();

    // Extract notification details
    final title = message.notification?.title ?? 'New Notification';
    final body = message.notification?.body ?? '';
    final notificationType = message.data['type'] ?? 'unknown';
    final senderId = message.data['senderId'] ?? '';
    final senderName = message.data['senderName'] ?? 'Someone';
    final chatId = message.data['chatId'];

    switch (notificationType) {
      case 'friend_request':
        await localNotificationService.showFriendRequestNotification(
          senderId: senderId,
          senderName: senderName,
        );
        break;

      case 'friend_accept':
        await localNotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          title: 'Friend Request Accepted',
          body: '$senderName accepted your friend request',
          payload: 'friend_accepted_$senderId',
        );
        break;

      case 'message':
        await localNotificationService.showMessageNotification(
          senderId: senderId,
          senderName: senderName,
          message: body,
          chatId: chatId,
        );
        break;

      default:
        await localNotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          title: title,
          body: body,
          payload: notificationType,
        );
    }
  } catch (e) {
    print('Error in background handler: $e');
  }
}
