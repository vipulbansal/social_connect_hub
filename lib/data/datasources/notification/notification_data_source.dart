
import '../../models/app_notification.dart';

/// Interface for notification data source
abstract class NotificationDataSource {
  /// Get notifications for a user with pagination
  Future<List<AppNotification>> getUserNotifications(
      String userId, {
        int limit = 20,
        String? lastNotificationId,
      });

  /// Get all FCM tokens for a user
  Future<List<String>> getUserTokens(String userId);

  /// Send a push notification
  Future<bool> sendPushNotification(
      AppNotification notification, {
        required List<String> recipientTokens,
      });

  /// Save notification to database
  Future<void> saveNotification(AppNotification notification);

  /// Mark a notification as read
  Future<bool> markNotificationAsRead(String notificationId);

  /// Mark all notifications as read for a user
  Future<bool> markAllNotificationsAsRead(String userId);

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId);

  /// Stream notifications for a user
  Stream<List<AppNotification>> streamUserNotifications(
      String userId, {
        int limit = 20,
      });

  /// Get unread notification count for a user
  Future<int> getUnreadNotificationCount(String userId);

  /// Stream unread notification count for a user
  Stream<int> streamUnreadNotificationCount(String userId);

  /// Register device token for push notifications
  Future<void> registerDeviceToken(String userId, String token);

  /// Unregister device token
  Future<void> unregisterDeviceToken(String userId, String token);
}