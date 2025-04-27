import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// LocalNotificationService handles all platform-specific local notification functionality
/// This service is responsible for showing notifications when the app is in the foreground
/// and for handling notification permissions.
class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  /// Initialize the notification service
  Future<void> initialize() async {
    try {
      // Android initialization settings
      final AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
          
      // iOS initialization settings
      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: false, // We'll request permissions separately
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      
      // Initialization settings for both platforms
      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      
      // Initialize the plugin
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTapped,
      );
      
      debugPrint('Local notification service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing local notification service: $e');
    }
  }
  
  /// Request permissions for notifications (handles runtime permissions)
  Future<void> requestPermissions() async {
    try {
      // Request permissions for iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }
      
      // Request permissions for Android 13+ (runtime permissions)
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }
      
      debugPrint('Notification permissions requested');
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }
  
  /// Check if notification permissions are granted
  Future<bool> checkPermissions() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>();
                    
        final bool? granted = await androidImplementation?.areNotificationsEnabled();
        return granted ?? false;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        // iOS doesn't have a direct way to check permissions through the plugin
        // We'll assume true for iOS and handle failures gracefully
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking notification permissions: $e');
      return false;
    }
  }

  /// Show a basic notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // Check permissions before showing notification
      final bool permissionsGranted = await checkPermissions();
      if (!permissionsGranted) {
        debugPrint('Notification permissions not granted');
        // Request permissions if not granted
        await requestPermissions();
        // Check again after requesting
        final bool permissionsGrantedAfterRequest = await checkPermissions();
        if (!permissionsGrantedAfterRequest) {
          debugPrint('User declined notification permissions');
          return;
        }
      }
      
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'socialconnecthub_channel',
        'SocialConnectHub Notifications',
        channelDescription: 'Notifications from SocialConnectHub',
        importance: Importance.max,
        priority: Priority.high,
      );
      
      final DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails();
          
      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      
      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }
  
  /// Show a message notification
  Future<void> showMessageNotification({
    required String senderId,
    required String senderName,
    required String message,
    String? chatId,
  }) async {
    try {
      final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      final String title = senderName;
      final String body = message;
      final String payload = chatId ?? senderId;
      
      await showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing message notification: $e');
    }
  }
  
  /// Show a friend request notification
  Future<void> showFriendRequestNotification({
    required String senderId,
    required String senderName,
  }) async {
    try {
      final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      final String title = 'New Friend Request';
      final String body = '$senderName sent you a friend request';
      final String payload = 'friend_request_$senderId';
      
      await showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing friend request notification: $e');
    }
  }
  
  /// Show a friend request accepted notification
  Future<void> showFriendRequestAcceptedNotification({
    required String userId,
    required String userName,
  }) async {
    try {
      final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      final String title = 'Friend Request Accepted';
      final String body = '$userName accepted your friend request';
      final String payload = 'friend_request_accepted_$userId';
      
      await showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing friend request accepted notification: $e');
    }
  }
  
  /// Show a friend request declined notification
  Future<void> showFriendRequestDeclinedNotification({
    required String userId,
    required String userName,
  }) async {
    try {
      final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      final String title = 'Friend Request Update';
      final String body = '$userName declined your friend request';
      final String payload = 'friend_request_declined_$userId';
      
      await showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing friend request declined notification: $e');
    }
  }
  
  /// Show a friend request canceled notification
  Future<void> showFriendRequestCanceledNotification({
    required String userId,
    required String userName,
  }) async {
    try {
      final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      final String title = 'Friend Request Canceled';
      final String body = '$userName canceled their friend request';
      final String payload = 'friend_request_canceled_$userId';
      
      await showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing friend request canceled notification: $e');
    }
  }
  
  /// Show a friend removed notification
  Future<void> showFriendRemovedNotification({
    required String userId,
    required String userName,
  }) async {
    try {
      final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      final String title = 'Friend Connection Update';
      final String body = '$userName is no longer connected with you';
      final String payload = 'friend_removed_$userId';
      
      await showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing friend removed notification: $e');
    }
  }
  
  /// Handle notification tap
  void onNotificationTapped(NotificationResponse details) {
    // Handle notification tap based on payload
    debugPrint('Notification tapped with payload: ${details.payload}');
    // You can navigate to specific screens based on the payload
    // This will be expanded when we implement deep linking
  }
}