import '../../../domain/core/result.dart';
import '../../models/user.dart';

/// Interface for user data source
abstract class UserDataSource {
  /// Get a user by ID
  Future<User?> getUserById(String userId);

  /// Search users by name or email
  Future<List<User>> searchUsers(String query);

  /// Get current user
  Future<User?> getCurrentUser();

  /// Update user profile
  Future<User?> updateUserProfile(User user);

  /// Delete user account
  Future<void> deleteUserAccount(String userId);


  /// Get user online status
  Future<bool> getUserOnlineStatus(String userId);

  /// Update user online status
  Future<void> updateUserOnlineStatus(String userId, bool isOnline);

  /// Get user FCM tokens
  Future<List<String>> getUserFcmTokens(String userId);

  /// Add FCM token to user
  Future<void> addFcmToken(String userId, String token);

  /// Remove FCM token from user
  Future<void> removeFcmToken(String userId, String token);

  /// Watch user changes (stream)
  Stream<User?> watchUser(String userId);

  /// Watch current user changes (stream)
  Stream<User?> watchCurrentUser();

}