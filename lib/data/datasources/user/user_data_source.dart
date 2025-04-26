import '../../../domain/core/result.dart';
import '../../models/user.dart';

/// Interface for user data source
abstract class UserDataSource {
  /// Get a user by ID
  Future<User?> getUserById(String userId);

  /// Search users by name or email
  Future<List<User>> searchUsers(String query);



}