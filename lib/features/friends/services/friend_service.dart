import 'dart:async';

import 'package:flutter/material.dart';
import 'package:social_connect_hub/domain/usecases/friend/send_friend_request_usecase.dart';
import 'package:social_connect_hub/domain/usecases/friend/watch_received_friend_requests_usecase.dart';
import 'package:social_connect_hub/domain/usecases/friend/watch_sent_friend_requests_usecase.dart';

import '../../../domain/entities/friend/friend_request_entity.dart';
import '../../../domain/entities/user/user_entity.dart';
import '../../../domain/repositories/auth/auth_repository.dart';
import '../../../domain/repositories/friend/friend_repository.dart';
import '../../../domain/repositories/user/user_repository.dart';
import '../../../domain/usecases/notification/send_push_notification_usecase.dart';
import '../../notification/services/notification_service.dart';

class FriendService extends ChangeNotifier {
  // Core repositories
  final FriendRepository _friendRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final NotificationService? _notificationService;
  final SendFriendRequestUseCase sendFriendRequestUseCase;
  final WatchSentFriendRequestsUseCase watchSentFriendRequestsUseCase;
  final WatchReceivedFriendRequestsUsecase watchReceivedFriendRequestsUseCase;
  List<FriendRequestEntity> _pendingSentRequests = [];
  List<FriendRequestEntity> _pendingReceivedRequests = [];
  List<UserEntity> _friends = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _sentRequestsSubscription;
  StreamSubscription? _receivedRequestsSubscription;
  StreamSubscription? _userFriendsSubscription;


  StreamSubscription? get sentRequestsSubscription => _sentRequestsSubscription;

  List<FriendRequestEntity> get pendingRequests => _pendingSentRequests;

  List<FriendRequestEntity> get pendingReceivedRequests =>
      _pendingReceivedRequests;


  String? get errorMessage => _errorMessage;

  FriendService(
    this._friendRepository,
    this._userRepository,
    this._authRepository,
    this.sendFriendRequestUseCase,
    this.watchSentFriendRequestsUseCase,
    this.watchReceivedFriendRequestsUseCase,
    this._notificationService,
  ) {
    init();
  }

  init() {
    _sentRequestsSubscription = watchSentFriendRequests().listen((requests) {
      _pendingSentRequests = requests;
      notifyListeners();
    });

    _receivedRequestsSubscription = watchReceivedFriendRequests().listen((
      requests,
    ) {
      _pendingReceivedRequests = requests;
      notifyListeners();
    });

    _userFriendsSubscription = watchUserFriends().listen((
        requests,
        ) {
      _friends = requests;
      notifyListeners();
    });

    loadFriends();
  }

  @override
  void dispose() {
    _sentRequestsSubscription?.cancel();
    _receivedRequestsSubscription?.cancel();
    _userFriendsSubscription?.cancel();
    super.dispose();
  }

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
    final result = await sendFriendRequestUseCase.call(
      SendFriendRequestParams(senderId: fromUserId, receiverId: toUserId),
    );

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
        if (_notificationService != null) {
          await _notificationService.sendPushNotificationUseCase!.call(
            SendPushNotificationParams(
              userId: toUserId,
              title: 'New Friend Request',
              body: '$senderName sent you a friend request',
              data: {
                'type': 'friend_request',
                'senderId': fromUserId,
                'senderName': senderName,
              },
            ),
          );
        }
        return true;
      },
      onFailure: (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
    );
  }

  // Stream Sent friend requests for the current user
  Stream<List<FriendRequestEntity>> watchSentFriendRequests() async* {
    final currentUserResult = await _authRepository.getCurrentUserId();
    if (currentUserResult.isFailure) {
      yield [];
      return;
    }
    final userId = currentUserResult.fold(
      onSuccess: (id) => id,
      onFailure: (_) => '',
    );

    if (userId.isEmpty) {
      yield [];
      return;
    }

    final requestsStream = watchSentFriendRequestsUseCase(userId);

    await for (final result in requestsStream) {
      // Use fold to handle success and failure cases
      yield result.fold(
        onSuccess: (requests) {
          // Store the pending requests for future use if needed
          _pendingSentRequests = requests;
          return requests;
        },
        onFailure: (_) => <FriendRequestEntity>[],
      );
    }
  }

  // Stream Sent friend requests for the current user
  Stream<List<FriendRequestEntity>> watchReceivedFriendRequests() async* {
    final currentUserResult = await _authRepository.getCurrentUserId();
    if (currentUserResult.isFailure) {
      yield [];
      return;
    }
    final userId = currentUserResult.fold(
      onSuccess: (id) => id,
      onFailure: (_) => '',
    );

    if (userId.isEmpty) {
      yield [];
      return;
    }

    final requestsStream = watchReceivedFriendRequestsUseCase(userId);

    await for (final result in requestsStream) {
      // Use fold to handle success and failure cases
      yield result;
    }
  }

  Stream<List<UserEntity>> watchUserFriends() async* {
    final currentUserResult = await _authRepository.getCurrentUserId();
    if (currentUserResult.isFailure) {
      yield [];
      return;
    }
    final userId = currentUserResult.fold(
      onSuccess: (id) => id,
      onFailure: (_) => '',
    );

    if (userId.isEmpty) {
      yield [];
      return;
    }
    final requestsStream =_friendRepository.watchUserFriends(userId);
    await for (final result in requestsStream) {
      yield result;
    }
  }

  // Get all friends for the current user
  Future<void> loadFriends() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final currentUserResult = await _authRepository.getCurrentUserId();

    if (currentUserResult.isFailure) {
      _errorMessage = 'Failed to get current user';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final userId = currentUserResult.fold(
      onSuccess: (id) => id,
      onFailure: (_) => '',
    );

    if (userId.isEmpty) {
      _errorMessage = 'Current user ID is empty';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final result = await _friendRepository.getUserFriends(userId);

    result.fold(
        onSuccess: (friends) {
          _friends = friends;
          _isLoading = false;
          notifyListeners();
        },
        onFailure: (failure) {
          _errorMessage = failure.message;
          _isLoading = false;
          notifyListeners();
        }
    );
  }

  // Accept a friend request
  Future<bool> acceptFriendRequest(String requestId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _friendRepository.acceptFriendRequest(requestId);

    _isLoading = false;

    return result.fold(
        onSuccess: (_) async {
          // Update local state
          final requestIndex = _pendingReceivedRequests.indexWhere((req) => req.id == requestId);
          if (requestIndex != -1) {
            final request = _pendingReceivedRequests[requestIndex];
            _pendingReceivedRequests.removeAt(requestIndex);

            // Get current user's info
            final currentUserResult = await _authRepository.getCurrentUserId();
            final currentUserId = currentUserResult.fold(
              onSuccess: (id) => id,
              onFailure: (_) => '',
            );

            // Load the user who sent the request and add to friends
            final userResult = await _userRepository.getUserById(request.fromUserId);

            userResult.fold(
                onSuccess: (user) async {
                  if (!_friends.any((friend) => friend.id == user.id)) {
                    _friends.add(user);
                    notifyListeners();
                  }

                  // Get current user's name for the notification
                  if (currentUserId.isNotEmpty && _notificationService!= null) {
                    final currentUserDetailsResult = await _userRepository.getUserById(currentUserId);
                    final currentUserName = currentUserDetailsResult.fold(
                      onSuccess: (user) => user.displayName,
                      onFailure: (_) => 'Someone',
                    );

                    // Send push notification to the request sender
                    await _notificationService.sendPushNotificationUseCase!.call(
                      SendPushNotificationParams(
                        userId: request.fromUserId,
                        title: 'Friend Request Accepted',
                        body: '$currentUserName accepted your friend request',
                        data: {
                          'type': 'friend_request_accepted',
                          'userId': currentUserId,
                          'userName': currentUserName,
                        },
                      ),
                    );
                  }
                },
                onFailure: (_) {} // Silently fail
            );
          }
          notifyListeners();
          return true;
        },
        onFailure: (failure) {
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        }
    );
  }

  // Reject a friend request
  Future<bool> rejectFriendRequest(String requestId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Get the request details before rejecting it
    final requestIndex = _pendingReceivedRequests.indexWhere((req) => req.id == requestId);
    final FriendRequestEntity? request =
    requestIndex != -1 ? _pendingReceivedRequests[requestIndex] : null;

    final result = await _friendRepository.rejectFriendRequest(requestId);

    _isLoading = false;

    return result.fold(
        onSuccess: (_) async {
          // Update local state
          _pendingReceivedRequests.removeWhere((req) => req.id == requestId);
          notifyListeners();

          // Send notification if we have the request details and notification service
          if (request != null && _notificationService != null) {
            // Get current user's info
            final currentUserResult = await _authRepository.getCurrentUserId();
            final currentUserId = currentUserResult.fold(
              onSuccess: (id) => id,
              onFailure: (_) => '',
            );

            if (currentUserId.isNotEmpty) {
              final currentUserDetailsResult = await _userRepository.getUserById(currentUserId);
              final currentUserName = currentUserDetailsResult.fold(
                onSuccess: (user) => user.displayName,
                onFailure: (_) => 'Someone',
              );

              // We don't always need to notify about rejections, but it can be useful
              // for the sender to know their request wasn't accepted
              await _notificationService.sendPushNotificationUseCase!.call(
                SendPushNotificationParams(
                  userId: request.fromUserId,
                  title: 'Friend Request Update',
                  body: '$currentUserName declined your friend request',
                  data: {
                    'type': 'friend_request_declined',
                    'userId': currentUserId,
                  },
                ),
              );

            }
          }

          return true;
        },
        onFailure: (failure) {
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        }
    );
  }

  StreamSubscription? get receivedRequestsSubscription =>
      _receivedRequestsSubscription;
}
