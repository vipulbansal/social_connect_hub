
import '../../core/result.dart';
import '../../core/usecase.dart';
import '../../repositories/auth/auth_repository.dart';

/// Parameters for the reset password use case
class ResetPasswordParams {
  final String email;

  /// Constructor
  const ResetPasswordParams({
    required this.email,
  });
}

/// Use case to reset user password
class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepository _authRepository;

  /// Constructor
  const ResetPasswordUseCase(this._authRepository);

  @override
  Future<Result<void>> call(ResetPasswordParams params) async {
    return await _authRepository.resetPassword(params.email);
  }
}