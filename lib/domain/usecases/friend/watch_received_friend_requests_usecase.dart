import 'package:social_connect_hub/domain/core/usecase_stream.dart';
import 'package:social_connect_hub/domain/entities/friend/friend_request_entity.dart';
import 'package:social_connect_hub/domain/repositories/friend/friend_repository.dart';

class WatchReceivedFriendRequestsUsecase implements UseCaseStream<List<FriendRequestEntity>,String>{
  FriendRepository friendRepository;

  WatchReceivedFriendRequestsUsecase(this.friendRepository);

  @override
  Stream<List<FriendRequestEntity>> call(String userId) async*{
    yield* friendRepository.streamReceivedFriendRequests(userId);
  }

}