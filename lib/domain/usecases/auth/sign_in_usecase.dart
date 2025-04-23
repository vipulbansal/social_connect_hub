
import '../../core/result.dart';
import '../../core/usecase.dart';
import '../../entities/user/user_entity.dart';
import '../../repositories/auth/auth_repository.dart';

/// Parameters for the sign in use case
class SignInParams {
  final String email;
  final String password;

  /// Constructor
  const SignInParams({
    required this.email,
    required this.password,
  });
}

/// Use case to sign in a user with email and password
class SignInUseCase implements UseCase<UserEntity, SignInParams> {
  final AuthRepository _authRepository;

  /// Constructor
  const SignInUseCase(this._authRepository);

  @override
  Future<Result<UserEntity>> call(SignInParams params) async {
    return await _authRepository.signInWithEmailAndPassword(
      params.email,
      params.password,
    );
  }
}