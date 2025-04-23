import '../../core/result.dart';
import '../../core/usecase.dart';
import '../../entities/user/user_entity.dart';
import '../../repositories/user/user_repository.dart';

/// Use case to get a user by their ID
class GetUserByIdUseCase implements UseCase<UserEntity, String> {
  final UserRepository _userRepository;

  /// Constructor
  const GetUserByIdUseCase(this._userRepository);

  @override
  Future<Result<UserEntity>> call(String userId) async {
    return await _userRepository.getUserById(userId);
  }
}