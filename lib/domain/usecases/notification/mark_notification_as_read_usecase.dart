import '../../../domain/core/result.dart';
import '../../../domain/repositories/notification/notification_repository.dart';

/// Use case for marking a notification as read
///
/// This use case is responsible for updating a notification's read status.
class MarkNotificationAsReadUseCase {
  final NotificationRepository _repository;

  /// Creates a new [MarkNotificationAsReadUseCase] with the given repository
  MarkNotificationAsReadUseCase(this._repository);

  /// Execute the use case with the given notification ID
  /// 
  /// Returns a Result indicating success or failure
  Future<Result<void>> call(String notificationId) async {
    return await _repository.markNotificationAsRead(notificationId);
  }
}