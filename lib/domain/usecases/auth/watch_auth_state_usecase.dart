
import '../../core/result.dart';
import '../../core/usecase.dart';
import '../../entities/user/user_entity.dart';
import '../../repositories/auth/auth_repository.dart';

/// Use case to watch authentication state changes (stream)
class WatchAuthStateUseCase implements NoParamsStreamUseCase<bool> {
  final AuthRepository _authRepository;

  /// Constructor
  const WatchAuthStateUseCase(this._authRepository);

  @override
  Stream<bool> call() {
    return _authRepository.watchAuthState();
  }
}