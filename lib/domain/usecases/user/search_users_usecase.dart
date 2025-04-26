import 'package:social_connect_hub/domain/core/result.dart';
import 'package:social_connect_hub/domain/core/usecase.dart';
import 'package:social_connect_hub/domain/entities/user/user_entity.dart';
import 'package:social_connect_hub/domain/repositories/user/user_repository.dart';

class SearchUsersUsecase extends UseCase<List<UserEntity>,String>{
    UserRepository userRepository;


    SearchUsersUsecase({required this.userRepository});

  @override
  Future<Result<List<UserEntity>>> call(String params) async{
    return await userRepository.searchUsers(params);
  }

}