

import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/services/local_notification_service.dart';
import '../../../domain/entities/notification/notification_entity.dart';
import '../../../domain/repositories/auth/auth_repository.dart';
import '../../../domain/repositories/notification/notification_repository.dart';
import '../../../domain/usecases/notification/mark_notification_as_read_usecase.dart';
import '../../../domain/usecases/notification/send_push_notification_usecase.dart';
import '../../../domain/usecases/notification/watch_user_notifications_usecase.dart';

/// Notification service that manages notification operations
/// using the Provider pattern and clean architecture principles.
class NotificationService extends ChangeNotifier {
  // Core repositories
  final NotificationRepository _notificationRepository;
  final AuthRepository _authRepository;
  
  // Notification state
  List<NotificationEntity> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;
  
  // Getters for state
  List<NotificationEntity> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  
  // Constructor
  NotificationService({
    required NotificationRepository notificationRepository,
    required AuthRepository authRepository,
    this.sendPushNotificationUseCase,
    this.markNotificationAsReadUseCase,
    this.watchUserNotificationsUseCase,
  }) : _notificationRepository = notificationRepository,
       _authRepository = authRepository {
    // Initialize notifications
    loadNotifications();
  }
  
  // Use cases
  final SendPushNotificationUseCase? sendPushNotificationUseCase;
  final MarkNotificationAsReadUseCase? markNotificationAsReadUseCase;
  final WatchUserNotificationsUseCase? watchUserNotificationsUseCase;
  
  // Stream notifications for the current user
  Stream<List<NotificationEntity>> watchUserNotifications() async* {
    final currentUserResult = await _authRepository.getCurrentUserId();
    
    if (currentUserResult.isFailure) {
      yield [];
      return;
    }
    
    final userId = currentUserResult.fold(
      onSuccess: (id) => id,
      onFailure: (_) => '',
    );
    
    if (userId.isEmpty) {
      yield [];
      return;
    }
    
    yield* _notificationRepository.watchUserNotifications(userId);
  }
  
  // Load notifications for the current user
  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final currentUserResult = await _authRepository.getCurrentUserId();
    
    if (currentUserResult.isFailure) {
      _errorMessage = 'Failed to get current user';
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    final userId = currentUserResult.fold(
      onSuccess: (id) => id,
      onFailure: (_) => '',
    );
    
    if (userId.isEmpty) {
      _errorMessage = 'Current user ID is empty';
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    // Using the stream method directly to get notifications in real-time
    final notificationsStream = _notificationRepository.watchUserNotifications(userId);
    notificationsStream.listen((notificationsList) {
      _notifications = notificationsList;
      _calculateUnreadCount();
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
    });
  }
  
  // Mark a notification as read
  Future<bool> markAsRead(String notificationId) async {
    final notificationIndex = _notifications.indexWhere(
      (notification) => notification.id == notificationId
    );
    
    if (notificationIndex == -1) {
      _errorMessage = 'Notification not found';
      notifyListeners();
      return false;
    }
    
    final notification = _notifications[notificationIndex];
    
    // Skip if already read
    if (notification.read) {
      return true;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _notificationRepository.markNotificationAsRead(notificationId);
    
    _isLoading = false;
    
    return result.fold(
      onSuccess: (_) {
        // Update local state
        _notifications[notificationIndex] = notification.copyWith(read: true);
        _calculateUnreadCount();
        notifyListeners();
        return true;
      },
      onFailure: (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      }
    );
  }
  
  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final currentUserResult = await _authRepository.getCurrentUserId();
    
    if (currentUserResult.isFailure) {
      _errorMessage = 'Failed to get current user';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    
    final userId = currentUserResult.fold(
      onSuccess: (id) => id,
      onFailure: (_) => '',
    );
    
    if (userId.isEmpty) {
      _errorMessage = 'Current user ID is empty';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    
    final result = await _notificationRepository.markAllNotificationsAsRead(userId);
    
    _isLoading = false;
    
    return result.fold(
      onSuccess: (_) {
        // Update local state
        _notifications = _notifications.map(
          (notification) => notification.copyWith(read: true)
        ).toList();
        _unreadCount = 0;
        notifyListeners();
        return true;
      },
      onFailure: (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      }
    );
  }
  
  // Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _notificationRepository.deleteNotification(notificationId);
    
    _isLoading = false;
    
    return result.fold(
      onSuccess: (_) {
        // Update local state
        _notifications.removeWhere((notification) => notification.id == notificationId);
        _calculateUnreadCount();
        notifyListeners();
        return true;
      },
      onFailure: (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      }
    );
  }
  
  // Clear all notifications
  // Future<bool> clearAllNotifications() async {
  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();
  //
  //   final currentUserResult = await _authRepository.getCurrentUserId();
  //
  //   if (currentUserResult.isFailure) {
  //     _errorMessage = 'Failed to get current user';
  //     _isLoading = false;
  //     notifyListeners();
  //     return false;
  //   }
  //
  //   final userId = currentUserResult.fold(
  //     onSuccess: (id) => id,
  //     onFailure: (_) => '',
  //   );
  //
  //   if (userId.isEmpty) {
  //     _errorMessage = 'Current user ID is empty';
  //     _isLoading = false;
  //     notifyListeners();
  //     return false;
  //   }
  //
  //   final result = await _notificationRepository.clearAllNotifications(userId);
  //
  //   _isLoading = false;
  //
  //   return result.fold(
  //     onSuccess: (_) {
  //       // Update local state
  //       _notifications = [];
  //       _unreadCount = 0;
  //       notifyListeners();
  //       return true;
  //     },
  //     onFailure: (failure) {
  //       _errorMessage = failure.message;
  //       notifyListeners();
  //       return false;
  //     }
  //   );
  // }
  
  // Register device for push notifications
  Future<bool> registerDeviceForPushNotifications(String deviceToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final currentUserResult = await _authRepository.getCurrentUserId();
    
    if (currentUserResult.isFailure) {
      _errorMessage = 'Failed to get current user';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    
    final userId = currentUserResult.fold(
      onSuccess: (id) => id,
      onFailure: (_) => '',
    );
    
    if (userId.isEmpty) {
      _errorMessage = 'Current user ID is empty';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    
    final result = await _notificationRepository.registerDeviceToken(userId, deviceToken);
    
    _isLoading = false;
    
    return result.fold(
      onSuccess: (_) {
        notifyListeners();
        return true;
      },
      onFailure: (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      }
    );
  }
  
  // Unregister device from push notifications
  Future<bool> unregisterDeviceFromPushNotifications(String deviceToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final currentUserResult = await _authRepository.getCurrentUserId();
    
    if (currentUserResult.isFailure) {
      _errorMessage = 'Failed to get current user';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    
    final userId = currentUserResult.fold(
      onSuccess: (id) => id,
      onFailure: (_) => '',
    );
    
    if (userId.isEmpty) {
      _errorMessage = 'Current user ID is empty';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    
    final result = await _notificationRepository.unregisterDeviceToken(userId, deviceToken);
    
    _isLoading = false;
    
    return result.fold(
      onSuccess: (_) {
        notifyListeners();
        return true;
      },
      onFailure: (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      }
    );
  }
  
  // Calculate the number of unread notifications
  void _calculateUnreadCount() {
    _unreadCount = _notifications.where((notification) => !notification.read).length;
  }
  
  // Clear any error messages
  void clearErrors() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Show a local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      final localNotificationService = locator<LocalNotificationService>();
      await localNotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: title,
        body: body,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }
  
  // Show a local notification for a new message
  Future<void> showMessageNotification({
    required String senderId,
    required String senderName,
    required String message,
    String? chatId,
  }) async {
    try {
      final localNotificationService = locator<LocalNotificationService>();
      await localNotificationService.showMessageNotification(
        senderId: senderId,
        senderName: senderName,
        message: message,
        chatId: chatId,
      );
    } catch (e) {
      debugPrint('Error showing message notification: $e');
    }
  }
  
  // Show a local notification for a new friend request
  Future<void> showFriendRequestNotification({
    required String senderId,
    required String senderName,
  }) async {
    try {
      final localNotificationService = locator<LocalNotificationService>();
      await localNotificationService.showFriendRequestNotification(
        senderId: senderId,
        senderName: senderName,
      );
    } catch (e) {
      debugPrint('Error showing friend request notification: $e');
    }
  }
  
  // Show a friend request accepted notification
  Future<void> showFriendRequestAcceptedNotification({
    required String userId,
    required String userName,
  }) async {
    try {
      final localNotificationService = locator<LocalNotificationService>();
      await localNotificationService.showFriendRequestAcceptedNotification(
        userId: userId,
        userName: userName,
      );
    } catch (e) {
      debugPrint('Error showing friend request accepted notification: $e');
    }
  }
  
  // Show a friend request declined notification
  Future<void> showFriendRequestDeclinedNotification({
    required String userId,
    required String userName,
  }) async {
    try {
      final localNotificationService = locator<LocalNotificationService>();
      await localNotificationService.showFriendRequestDeclinedNotification(
        userId: userId,
        userName: userName,
      );
    } catch (e) {
      debugPrint('Error showing friend request declined notification: $e');
    }
  }
  
  // Show a friend request canceled notification
  Future<void> showFriendRequestCanceledNotification({
    required String userId,
    required String userName,
  }) async {
    try {
      final localNotificationService = locator<LocalNotificationService>();
      await localNotificationService.showFriendRequestCanceledNotification(
        userId: userId,
        userName: userName,
      );
    } catch (e) {
      debugPrint('Error showing friend request canceled notification: $e');
    }
  }
  
  // Show a friend removed notification
  Future<void> showFriendRemovedNotification({
    required String userId,
    required String userName,
  }) async {
    try {
      final localNotificationService = locator<LocalNotificationService>();
      await localNotificationService.showFriendRemovedNotification(
        userId: userId,
        userName: userName,
      );
    } catch (e) {
      debugPrint('Error showing friend removed notification: $e');
    }
  }
  
  // Request notification permissions
  Future<void> requestNotificationPermissions() async {
    try {
      final localNotificationService = locator<LocalNotificationService>();
      await localNotificationService.requestPermissions();
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }
}