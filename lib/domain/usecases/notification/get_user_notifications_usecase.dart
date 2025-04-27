import '../../../domain/core/result.dart';
import '../../../domain/entities/notification/notification_entity.dart';
import '../../../domain/repositories/notification/notification_repository.dart';

/// Use case for fetching user notifications
///
/// This use case is responsible for fetching all notifications for a specific user.
/// It implements a single responsibility from the application business logic.
class GetUserNotificationsUseCase {
  final NotificationRepository _repository;

  /// Creates a new [GetUserNotificationsUseCase] with the given repository
  GetUserNotificationsUseCase(this._repository);

  /// Execute the use case with the given user ID
  /// 
  /// Returns a list of notifications for the user
  Future<Result<List<NotificationEntity>>> call(String userId) async {
    return await _repository.getUserNotifications(userId);
  }
}