import '../../core/result.dart';
import '../../entities/user/user_entity.dart';


/// Repository interface for Authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Result<UserEntity>> signInWithEmailAndPassword(
      String email,
      String password,
      );

  /// Sign up with email and password
  Future<Result<UserEntity>> signUpWithEmailAndPassword(
      String email,
      String password,
      String name,
      );

  /// Sign out
  Future<Result<void>> signOut();

  /// Reset password
  Future<Result<void>> resetPassword(String email);

  /// Change password
  Future<Result<void>> changePassword(
      String currentPassword,
      String newPassword,
      );

  /// Check if user is authenticated
  Future<Result<bool>> isAuthenticated();

  /// Get current user ID
  Future<Result<String>> getCurrentUserId();

  /// Get auth state changes (stream)
  Stream<bool> watchAuthState();
}