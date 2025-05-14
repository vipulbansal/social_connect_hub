import '../../core/result.dart';
import '../../entities/user/user_entity.dart';

/// Repository interface for User operations
abstract class UserRepository {
  /// Get a user by ID
  Future<Result<UserEntity>> getUserById(String userId);

  /// Search users by name or email
  Future<Result<List<UserEntity>>> searchUsers(String query);

  /// Get current user
  Future<Result<UserEntity>> getCurrentUser();

  /// Update user profile
  Future<Result<UserEntity>> updateUserProfile(UserEntity user);


  /// Get user online status
  Future<Result<bool>> getUserOnlineStatus(String userId);

  /// Update user online status
  Future<Result<void>> updateUserOnlineStatus(String userId, bool isOnline);

  /// Get user FCM tokens
  Future<Result<List<String>>> getUserFcmTokens(String userId);

  /// Add FCM token to user
  Future<Result<void>> addFcmToken(String userId, String token);

  /// Remove FCM token from user
  Future<Result<void>> removeFcmToken(String userId, String token);

  /// Watch user changes (stream)
  Stream<UserEntity> watchUser(String userId);

  /// Watch current user changes (stream)
  Stream<UserEntity?> watchCurrentUser();

  /// Delete user account
  Future<Result<void>> deleteUserAccount(String userId);
}