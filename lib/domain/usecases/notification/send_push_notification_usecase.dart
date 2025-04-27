import '../../../domain/core/result.dart';
import '../../../domain/repositories/notification/notification_repository.dart';

/// Parameters for sending a push notification
class SendPushNotificationParams {
  final String userId;
  final String title;
  final String body;
  final Map<String, dynamic> data;

  /// Creates a new set of parameters for sending a push notification
  SendPushNotificationParams({
    required this.userId,
    required this.title,
    required this.body,
    required this.data,
  });
}

/// Use case for sending a push notification to a user
///
/// This use case is responsible for sending a push notification to a specific user.
class SendPushNotificationUseCase {
  final NotificationRepository _repository;

  /// Creates a new [SendPushNotificationUseCase] with the given repository
  SendPushNotificationUseCase(this._repository);

  /// Execute the use case with the given parameters
  /// 
  /// Returns a Result indicating success or failure
  Future<Result<void>> call(SendPushNotificationParams params) async {
    return await _repository.sendPushNotification(
      params.userId,
      params.title,
      params.body,
      params.data,
    );
  }
}