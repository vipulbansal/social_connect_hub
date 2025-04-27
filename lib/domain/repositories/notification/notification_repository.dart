import '../../../domain/core/result.dart';
import '../../entities/notification/notification_entity.dart';



/// Abstract repository for notification operations
/// 
/// This interface defines the contract for how the application interacts with
/// notification data, regardless of where that data is stored. This follows the
/// dependency inversion principle of clean architecture.
abstract class NotificationRepository {
  /// Get all notifications for a user
  Future<Result<List<NotificationEntity>>> getUserNotifications(String userId);
  
  /// Stream notifications for a user
  Stream<List<NotificationEntity>> watchUserNotifications(String userId);
  
  /// Mark a notification as read
  Future<Result<void>> markNotificationAsRead(String notificationId);
  
  /// Mark all notifications for a user as read
  Future<Result<void>> markAllNotificationsAsRead(String userId);
  
  /// Delete a notification
  Future<Result<void>> deleteNotification(String notificationId);
  
  /// Send a push notification to a user
  Future<Result<void>> sendPushNotification(String userId, String title, String body, Map<String, dynamic> data);
  
  /// Register a device token for push notifications
  Future<Result<void>> registerDeviceToken(String userId, String deviceToken);
  
  /// Unregister a device token
  Future<Result<void>> unregisterDeviceToken(String userId, String deviceToken);
}