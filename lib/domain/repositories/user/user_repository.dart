import '../../core/result.dart';
import '../../entities/user/user_entity.dart';

/// Repository interface for User operations
abstract class UserRepository {
  /// Get a user by ID
  Future<Result<UserEntity>> getUserById(String userId);
}