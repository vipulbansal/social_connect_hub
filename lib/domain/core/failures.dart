import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  /// Error message to display
  final String message;

  /// Constructor
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Authentication failures
class AuthFailure extends Failure {
  /// Constructor
   AuthFailure(String message) : super(message);
}

/// User related failures
class UserFailure extends Failure {
  /// Constructor
  const UserFailure(String message) : super(message);
}

/// Chat related failures
class ChatFailure extends Failure {
  /// Constructor
  const ChatFailure(String message) : super(message);
}

/// Friend related failures
class FriendFailure extends Failure {
  /// Constructor
  const FriendFailure(String message) : super(message);
}

/// Group related failures
class GroupFailure extends Failure {
  /// Constructor
  const GroupFailure(String message) : super(message);
}

/// Message related failures
class MessageFailure extends Failure {
  /// Constructor
  const MessageFailure(String message) : super(message);
}

/// Notification related failures
class NotificationFailure extends Failure {
  /// Constructor
  const NotificationFailure(String message) : super(message);
}

/// Network related failures
class NetworkFailure extends Failure {
  /// Constructor
  const NetworkFailure(String message) : super(message);
}

/// Server related failures
class ServerFailure extends Failure {
  /// Constructor
  const ServerFailure(String message) : super(message);
}

/// Cache related failures
class CacheFailure extends Failure {
  /// Constructor
  const CacheFailure(String message) : super(message);
}

/// Permission related failures
class PermissionFailure extends Failure {
  /// Constructor
  const PermissionFailure(String message) : super(message);
}

/// Unknown failures
class UnknownFailure extends Failure {
  /// Constructor
  const UnknownFailure(String message) : super(message);
}