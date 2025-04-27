import 'package:social_connect_hub/data/datasources/notification/notification_data_source.dart';
import 'package:social_connect_hub/domain/core/result.dart';
import 'package:social_connect_hub/domain/entities/notification/notification_entity.dart';
import 'package:social_connect_hub/domain/repositories/notification/notification_repository.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/entities/notification/notification_type.dart';
import '../../models/app_notification.dart';

/// Implementation of [NotificationRepository] following clean architecture
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource _notificationDataSource;

  /// Constructor
  const NotificationRepositoryImpl({
    required NotificationDataSource notificationDataSource,
  }) : _notificationDataSource = notificationDataSource;

  @override
  Future<Result<List<NotificationEntity>>> getUserNotifications(
      String userId, {
        int limit = 20,
        NotificationEntity? lastNotification,
      }) async {
    try {
      final lastNotificationId = lastNotification?.id;
      final notifications = await _notificationDataSource.getUserNotifications(
        userId,
        limit: limit,
        lastNotificationId: lastNotificationId,
      );
      return Result.success(notifications.map(_mapToNotificationEntity).toList());
    } catch (e) {
      return Result.failure(NotificationFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendPushNotification(
      String userId,
      String title,
      String body,
      Map<String, dynamic> data,
      ) async {
    try {
      // Get the user document to fetch FCM tokens
      final userDoc = await _notificationDataSource.getUserTokens(userId);

      if (userDoc == null || userDoc.isEmpty) {
        return Result.failure(const NotificationFailure('User has no registered FCM tokens'));
      }

      // Send the push notification to all of the user's tokens
      final success = await _notificationDataSource.sendPushNotification(
        AppNotification(
          id: '',
          userId: userId,
          title: title,
          body: body,
          type: _mapToNotificationTypeString(NotificationType.system),
          isRead: false,
          data: data,
          timestamp: DateTime.now(),
          senderId: '',
        ),
        recipientTokens: userDoc,
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure(NotificationFailure(e.toString()));
    }
  }

  // This is an internal method that allows specifying recipient tokens directly
  // Used by other methods that already have the tokens
  Future<Result<void>> _sendPushNotificationWithTokens({
    required List<String> recipientTokens,
    required String title,
    required String body,
    NotificationType? type,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      final success = await _notificationDataSource.sendPushNotification(
        AppNotification(
          id: '',
          userId: '',
          title: title,
          body: body,
          type: _mapToNotificationTypeString(type ?? NotificationType.system),
          isRead: false,
          data: data,
          timestamp: DateTime.now(),
          senderId: '',
        ),
        recipientTokens: recipientTokens,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(NotificationFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationDataSource.markNotificationAsRead(notificationId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(NotificationFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> markAllNotificationsAsRead(String userId) async {
    try {
      await _notificationDataSource.markAllNotificationsAsRead(userId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(NotificationFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteNotification(String notificationId) async {
    try {
      await _notificationDataSource.deleteNotification(notificationId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(NotificationFailure(e.toString()));
    }
  }

  @override
  Stream<List<NotificationEntity>> watchUserNotifications(
      String userId, {
        int limit = 20,
      }) {
    return _notificationDataSource.streamUserNotifications(userId, limit: limit)
        .map((notifications) => notifications.map(_mapToNotificationEntity).toList());
  }

  @override
  Future<Result<void>> saveNotification(NotificationEntity notification) async {
    try {
      final notificationModel = _mapToNotificationModel(notification);
      await _notificationDataSource.saveNotification(notificationModel);
      return Result.success(null);
    } catch (e) {
      return Result.failure(NotificationFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> getUnreadNotificationCount(String userId) async {
    try {
      final count = await _notificationDataSource.getUnreadNotificationCount(userId);
      return Result.success(count);
    } catch (e) {
      return Result.failure(NotificationFailure(e.toString()));
    }
  }

  @override
  Stream<int> streamUnreadNotificationCount(String userId) {
    return _notificationDataSource.streamUnreadNotificationCount(userId);
  }

  // Helper method to map model to entity
  NotificationEntity _mapToNotificationEntity(AppNotification notification) {
    return NotificationEntity(
      id: notification.id,
      userId: notification.userId,
      senderId: notification.senderId,
      title: notification.title,
      body: notification.body,
      type: notification.type,
      data: notification.data,
      read: notification.isRead,
      createdAt: notification.timestamp,
      imageUrl: null, // Add if available in model
    );
  }

  // Helper method to map string to NotificationType
  NotificationType _mapToNotificationTypeEntity(String type) {
    switch (type) {
      case 'friendRequest':
        return NotificationType.friendRequest;
      case 'friendRequestAccepted':
        return NotificationType.friendRequestAccepted;
      case 'message':
        return NotificationType.message;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.custom;
    }
  }

  // Helper method to map entity to model
  AppNotification _mapToNotificationModel(NotificationEntity entity) {
    return AppNotification(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      body: entity.body,
      type: entity.type,
      data: entity.data,
      isRead: entity.read,
      timestamp: entity.createdAt,
      senderId: entity.senderId,
    );
  }

  // Helper method to map NotificationType to string
  String _mapToNotificationTypeString(NotificationType type) {
    switch (type) {
      case NotificationType.friendRequest:
        return 'friendRequest';
      case NotificationType.friendRequestAccepted:
        return 'friendRequestAccepted';
      case NotificationType.message:
        return 'message';
      case NotificationType.system:
        return 'system';
      case NotificationType.custom:
        return 'custom';
    }
  }

  @override
  Future<Result<void>> registerDeviceToken(String userId, String token) async {
    try {
      await _notificationDataSource.registerDeviceToken(userId, token);
      return Result.success(null);
    } catch (e) {
      return Result.failure(NotificationFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> unregisterDeviceToken(String userId, String token) async {
    try {
      await _notificationDataSource.unregisterDeviceToken(userId, token);
      return Result.success(null);
    } catch (e) {
      return Result.failure(NotificationFailure(e.toString()));
    }
  }
}