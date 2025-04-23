

import '../../core/result.dart';
import '../../core/usecase.dart';
import '../../entities/user/user_entity.dart';
import '../../repositories/auth/auth_repository.dart';

/// Parameters for the sign up use case
class SignUpParams {
  final String email;
  final String password;
  final String name;

  /// Constructor
  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
  });
}

/// Use case to sign up a user with email and password
class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository _authRepository;

  /// Constructor
  const SignUpUseCase(this._authRepository);

  @override
  Future<Result<UserEntity>> call(SignUpParams params) async {
    return await _authRepository.signUpWithEmailAndPassword(
      params.email,
      params.password,
      params.name,
    );
  }
}