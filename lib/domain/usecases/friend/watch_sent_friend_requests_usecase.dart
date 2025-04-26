import 'package:social_connect_hub/domain/core/result.dart';
import 'package:social_connect_hub/domain/core/usecase.dart';
import 'package:social_connect_hub/domain/entities/friend/friend_request_entity.dart';
import 'package:social_connect_hub/domain/repositories/friend/friend_repository.dart';

import '../../../data/models/friend_request.dart';

class WatchSentFriendRequestsUseCase implements StreamUseCase<Result<List<FriendRequestEntity>>,String>{
  FriendRepository friendRepository;

  WatchSentFriendRequestsUseCase(this.friendRepository);

  @override
  Stream<Result<List<FriendRequestEntity>>> call(String params) {
    return friendRepository.streamSentFriendRequests(params);

  }

}