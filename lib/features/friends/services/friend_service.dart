import 'package:flutter/material.dart';
import 'package:social_connect_hub/domain/usecases/friend/send_friend_request_usecase.dart';

import '../../../domain/repositories/auth/auth_repository.dart';
import '../../../domain/repositories/friend/friend_repository.dart';
import '../../../domain/repositories/user/user_repository.dart';

class FriendService extends ChangeNotifier {
  // Core repositories
  final FriendRepository _friendRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final SendFriendRequestUseCase sendFriendRequestUseCase;
  bool _isLoading = false;
  String? _errorMessage;

  FriendService(this._friendRepository, this._userRepository,
      this._authRepository, this.sendFriendRequestUseCase);

  // Send a friend request
  Future<bool> sendFriendRequest(String toUserId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final currentUserResult = await _authRepository.getCurrentUserId();

    if (currentUserResult.isFailure) {
      _errorMessage = 'Failed to get current user';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final fromUserId = currentUserResult.fold(
      onSuccess: (id) => id,
      onFailure: (_) => '',
    );

    if (fromUserId.isEmpty) {
      _errorMessage = 'Current user ID is empty';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    final result = await sendFriendRequestUseCase.call(SendFriendRequestParams(senderId: fromUserId, receiverId: toUserId));

    _isLoading = false;

    return result.fold(
        onSuccess: (_) async {
          notifyListeners();

          // Get sender's name for the notification
          final senderResult = await _userRepository.getUserById(fromUserId);
          final senderName = senderResult.fold(
            onSuccess: (user) => user.displayName,
            onFailure: (_) => 'Someone',
          );

          // Send push notification
          return true;
        },
        onFailure: (failure) {
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        }
    );
  }


}