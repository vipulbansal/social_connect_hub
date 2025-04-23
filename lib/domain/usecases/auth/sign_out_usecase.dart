
import '../../core/result.dart';
import '../../core/usecase.dart';
import '../../entities/user/user_entity.dart';
import '../../repositories/auth/auth_repository.dart';

/// Use case to sign out a user
class SignOutUseCase implements UseCase<void, NoParams> {
  final AuthRepository _authRepository;

  /// Constructor
  const SignOutUseCase(this._authRepository);

  @override
  Future<Result<void>> call(NoParams params) async {
    return await _authRepository.signOut();
  }
}