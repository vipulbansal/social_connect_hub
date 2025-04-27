import 'package:social_connect_hub/domain/core/result.dart';
import 'package:social_connect_hub/domain/entities/notification/notification_entity.dart';
import 'package:social_connect_hub/domain/repositories/notification/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository{

  @override
  Future<Result<void>> deleteNotification(String notificationId) {
    // TODO: implement deleteNotification
    throw UnimplementedError();
  }

  @override
  Future<Result<List<NotificationEntity>>> getUserNotifications(String userId) {
    // TODO: implement getUserNotifications
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> markAllNotificationsAsRead(String userId) {
    // TODO: implement markAllNotificationsAsRead
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> markNotificationAsRead(String notificationId) {
    // TODO: implement markNotificationAsRead
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> registerDeviceToken(String userId, String deviceToken) {
    // TODO: implement registerDeviceToken
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> sendPushNotification(String userId, String title, String body, Map<String, dynamic> data) {
    // TODO: implement sendPushNotification
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> unregisterDeviceToken(String userId, String deviceToken) {
    // TODO: implement unregisterDeviceToken
    throw UnimplementedError();
  }

  @override
  Stream<Result<List<NotificationEntity>>> watchUserNotifications(String userId) {
    // TODO: implement watchUserNotifications
    throw UnimplementedError();
  }

}