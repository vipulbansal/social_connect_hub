import '../../models/user.dart';

/// Interface for user data source
abstract class UserDataSource {
  /// Get a user by ID
  Future<User?> getUserById(String userId);

}