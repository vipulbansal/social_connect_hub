import '../../../domain/core/result.dart';
import '../../../domain/entities/notification/notification_entity.dart';
import '../../../domain/repositories/notification/notification_repository.dart';

/// Use case for watching user notifications in real-time
///
/// This use case is responsible for providing a stream of notifications
/// for a specific user, updating in real-time when notifications change.
class WatchUserNotificationsUseCase {
  final NotificationRepository _repository;

  /// Creates a new [WatchUserNotificationsUseCase] with the given repository
  WatchUserNotificationsUseCase(this._repository);

  /// Execute the use case with the given user ID
  /// 
  /// Returns a stream of notifications for the user
  Stream<List<NotificationEntity>> call(String userId) {
    return _repository.watchUserNotifications(userId);
  }
}