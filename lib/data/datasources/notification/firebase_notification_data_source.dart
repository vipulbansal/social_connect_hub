import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:jose/jose.dart';
import '../../../secrets.dart';
import '../../models/app_notification.dart';
import 'notification_data_source.dart';

/// Firebase implementation of [NotificationDataSource]
class FirebaseNotificationDataSource implements NotificationDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;
  String? _cachedAccessToken;
  int? _accessTokenExpiryEpoch;

  /// Constructor
  FirebaseNotificationDataSource({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required FirebaseMessaging messaging,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _messaging = messaging;
  
  @override
  Future<List<AppNotification>> getUserNotifications(
    String userId, {
    int limit = 20,
    String? lastNotificationId,
  }) async {
    try {
      var query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true);
//          .limit(limit)
      
      if (lastNotificationId != null) {
        final lastDoc = await _firestore
            .collection('notifications')
            .doc(lastNotificationId)
            .get();
            
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => AppNotification.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      print('Error getting user notifications: $e');
      return [];
    }
  }
  
  @override
  Future<List<String>> getUserTokens(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists || userDoc.data() == null) {
        return [];
      }
      
      final userData = userDoc.data()!;
      if (!userData.containsKey('fcmTokens') || userData['fcmTokens'] == null) {
        return [];
      }
      
      // Convert the Firestore array to a List<String>
      final List<dynamic> tokensDynamic = userData['fcmTokens'];
      final List<String> tokens = tokensDynamic.cast<String>();
      
      return tokens;
    } catch (e) {
      print('Error getting user FCM tokens: $e');
      return [];
    }
  }
  
  @override
  Future<bool> sendPushNotification(
    AppNotification notification, {
    required List<String> recipientTokens,
  }) async {
    try {
      // 1. Save the notification to Firestore
      await saveNotification(notification);
      
      // 2. Send push notifications to all recipient tokens
      for (final token in recipientTokens) {
        await _sendPushToDevice(
          token,
          notification.title,
          notification.body,
          notification.data,
        );
      }
      
      return true;
    } catch (e) {
      print('Error sending push notification: $e');
      return false;
    }
  }
  
  @override
  Future<void> saveNotification(AppNotification notification) async {
    try {
      await _firestore.collection('notifications').add(notification.toJson());
    } catch (e) {
      print('Error saving notification: $e');
      throw e;
    }
  }




  Future<void> _sendPushToDevice(
      String deviceToken,
      String title,
      String body,
      Map<String, dynamic>? data,
      ) async {
    try {
      // Your Firebase project ID
      String projectId = 'vipulconnecthub';
      final String fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      // Replace with your generated access token
       String? accessToken = await _generateAccessToken();

      final Map<String, dynamic> payload = {
        'message': {
          'token': deviceToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data?.map((key, value) => MapEntry(key, value.toString())) ?? {},
          'android': {
            'priority': 'high',
          },
          'apns': {
            'headers': {
              'apns-priority': '10',
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('✅ Push notification sent successfully to device: $deviceToken');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Push notification sent successfully! ✅'),
        //     backgroundColor: Colors.green,
        //   ),
        // );
      } else {
        print('❌ Failed to send push notification. Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Failed to send push notification. ❌'),
        //     backgroundColor: Colors.red,
        //   ),
        // );
      }
    } catch (e) {
      print('❗ Error sending FCM message: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Error sending FCM message. ❗'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    }
  }


  @override
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': DateTime.now(),
      });
      
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
  
  @override
  Future<bool> markAllNotificationsAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': DateTime.now(),
        });
      }
      
      await batch.commit();
      
      return true;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }
  
  @override
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }
  
  @override
  Stream<List<AppNotification>> streamUserNotifications(
    String userId, {
    int limit = 20,
  }) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }
  
  @override
  Future<void> registerDeviceToken(String userId, String token) async {
    try {
      // Check if the user document exists
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        // Update existing document
        await _firestore.collection('users').doc(userId).update({
          'fcmTokens': FieldValue.arrayUnion([token]),
        });
      } else {
        // Handle the case where user document might not exist yet
        // by using set with merge option instead of update
        await _firestore.collection('users').doc(userId).set({
          'fcmTokens': [token],
          'lastActive': DateTime.now(),
        },  SetOptions(merge: true));
      }
      
      print('Device token registered for user: $userId');
    } catch (e) {
      print('Error registering device token: $e');
      throw e;
    }
  }
  
  @override
  Future<void> unregisterDeviceToken(String userId, String token) async {
    try {
      // Remove token from fcmTokens array in the user document
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
      
      print('Device token unregistered for user: $userId');
    } catch (e) {
      print('Error unregistering device token: $e');
      throw e;
    }
  }
  
  /// Helper method to get the current platform
  String _getPlatform() {
    // Simple platform detection
    try {
      if (identical(0, 0.0)) {
        return 'web';
      }
      // In a real app, we would use Platform.isIOS, Platform.isAndroid, etc.
      return 'unknown';
    } catch (_) {
      return 'unknown';
    }
  }
  
  @override
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting unread notification count: $e');
      return 0;
    }
  }
  
  @override
  Stream<int> streamUnreadNotificationCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }


  Future<String?> _generateAccessToken() async {
    try {
      final currentEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      // Use cached token if it's still valid
      if (_cachedAccessToken != null &&
          _accessTokenExpiryEpoch != null &&
          currentEpoch < _accessTokenExpiryEpoch!) {
        return _cachedAccessToken;
      }

      final iat = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final exp = iat + 3600 ; // 1 hours validity

      final claims = {
        'iss': clientEmail,
        'scope': 'https://www.googleapis.com/auth/firebase.messaging',
        'aud': tokenUri,
        'exp': exp,
        'iat': iat,
      };

      final builder = JsonWebSignatureBuilder()
        ..jsonContent = claims
        ..addRecipient(
          JsonWebKey.fromPem(privateKey),
          algorithm: 'RS256',
        );

      final jwt = builder.build().toCompactSerialization();

      final response = await http.post(
        Uri.parse(tokenUri),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          'assertion': jwt,
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        _cachedAccessToken = body['access_token'];
        _accessTokenExpiryEpoch = exp; // store expiry to avoid regenerating
        return _cachedAccessToken;
      } else {
        print('Failed to generate access token. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error generating access token: $e');
      return null;
    }
  }

}