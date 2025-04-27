import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:social_connect_hub/domain/entities/user/user_entity.dart';
// Removed BLoC imports as we're using Provider for state management
import '../../../data/models/friend_request.dart' as model;
import '../../../data/models/user.dart';
import '../../../domain/entities/friend/friend_request_entity.dart' as entity;
import '../../../features/friends/services/friend_service.dart';
import '../../../features/auth/services/auth_service.dart';


// Helper method to convert FriendRequestEntity to FriendRequest
model.FriendRequest _convertToFriendRequest(entity.FriendRequestEntity entityObj) {
  return model.FriendRequest(
    id: entityObj.id,
    senderId: entityObj.senderId,
    receiverId: entityObj.recipientId,
    status: _convertStatus(entityObj.status),
    createdAt: entityObj.createdAt,
    updatedAt: entityObj.updatedAt,
  );
}

// Helper method to convert status
model.FriendRequestStatus _convertStatus(entity.FriendRequestStatus status) {
  switch (status) {
    case entity.FriendRequestStatus.pending:
      return model.FriendRequestStatus.pending;
    case entity.FriendRequestStatus.accepted:
      return model.FriendRequestStatus.accepted;
    case entity.FriendRequestStatus.rejected:
      return model.FriendRequestStatus.rejected;
    case entity.FriendRequestStatus.cancelled:
      return model.FriendRequestStatus.canceled;
    default:
      return model.FriendRequestStatus.pending;
  }
}

// Helper function to convert list of entities to list of models
List<model.FriendRequest> _convertFriendRequestList(List<entity.FriendRequestEntity> entities) {
  return entities.map(_convertToFriendRequest).toList();
}

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<User?> _getUserDetails(String userId) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userResult = await authService.userRepository.getUserById(userId);
      
      if (userResult.isFailure) {
        return null;
      }
      else {
        var userEntity;
        userResult.fold(
            onSuccess: (success) => userEntity=success, onFailure: (failure) => failure);
        // Convert UserEntity to User model
          return User(
            id: userEntity.id,
            email: userEntity.email,
            name: userEntity.name,
            profilePicUrl: userEntity.avatarUrl,
            bio: userEntity.bio ?? '',
            createdAt: userEntity.createdAt,
            lastActive: userEntity.lastSeen,
            status: userEntity.isOnline ? UserStatus.online : UserStatus
                .offline,
            phoneNumber: userEntity.phoneNumber,
            fcmTokens: userEntity.fcmToken != null ? [userEntity.fcmToken!] : [
            ],
            friendIds: userEntity.friends,
          );
      }
    } catch (e) {
      debugPrint('Error getting user details: $e');
      return null;
    }
  }

  Future<void> _acceptFriendRequest(model.FriendRequest request) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final friendService = Provider.of<FriendService>(context, listen: false);
      final success = await friendService.acceptFriendRequest(request.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Friend request accepted'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final errorMessage = friendService.errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to accept friend request: ${errorMessage ?? "Unknown error"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _rejectFriendRequest(model.FriendRequest request) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final friendService = Provider.of<FriendService>(context, listen: false);
      final success = await friendService.rejectFriendRequest(request.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Friend request rejected'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final errorMessage = friendService.errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reject friend request: ${errorMessage ?? "Unknown error"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Received requests tab
                _ReceivedRequestsTab(
                  onAccept: _acceptFriendRequest,
                  onReject: _rejectFriendRequest,
                  getUserDetails: _getUserDetails,
                ),
                
                // Sent requests tab
                _SentRequestsTab(
                  getUserDetails: _getUserDetails,
                ),
              ],
            ),
    );
  }
}

class _ReceivedRequestsTab extends StatelessWidget {
  final Function(model.FriendRequest) onAccept;
  final Function(model.FriendRequest) onReject;
  final Future<User?> Function(String) getUserDetails;

  const _ReceivedRequestsTab({
    required this.onAccept,
    required this.onReject,
    required this.getUserDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendService>(
      builder: (context, friendService, child) {
        // Stream the received requests from the service
        return StreamBuilder<List<model.FriendRequest>>(
          stream: friendService.getReceivedFriendRequests(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            
            final receivedRequests = snapshot.data ?? [];

            if (receivedRequests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_disabled,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No friend requests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'When someone sends you a friend request,\nit will appear here',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: receivedRequests.length,
              itemBuilder: (context, index) {
                final request = receivedRequests[index];
                
                return FutureBuilder<User?>(
                  future: getUserDetails(request.senderId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(
                        leading: CircleAvatar(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        title: Text('Loading...'),
                        subtitle: LinearProgressIndicator(),
                      );
                    }

                    final user = snapshot.data;
                    if (user == null) {
                      return const ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.error),
                        ),
                        title: Text('Unknown user'),
                        subtitle: Text('Could not load user details'),
                      );
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: user.profilePicUrl != null
                            ? NetworkImage(user.profilePicUrl!)
                            : null,
                        child: user.profilePicUrl == null
                            ? Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.blue),
                              )
                            : null,
                      ),
                      title: Text(user.name),
                      subtitle: Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => onReject(request),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Reject'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => onAccept(request),
                            child: const Text('Accept'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SentRequestsTab extends StatelessWidget {
  final Future<User?> Function(String) getUserDetails;

  const _SentRequestsTab({
    required this.getUserDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendService>(
      builder: (context, friendService, child) {
        return StreamBuilder<List<model.FriendRequest>>(
          stream: friendService.getSentFriendRequests(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            
            final sentRequests = snapshot.data ?? [];

            if (sentRequests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.send_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No sent requests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Friend requests you send will appear here',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/search');
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Find Friends'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: sentRequests.length,
              itemBuilder: (context, index) {
                final request = sentRequests[index];
                
                return FutureBuilder<User?>(
                  future: getUserDetails(request.receiverId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(
                        leading: CircleAvatar(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        title: Text('Loading...'),
                        subtitle: LinearProgressIndicator(),
                      );
                    }
    
                    final user = snapshot.data;
                    if (user == null) {
                      return const ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.error),
                        ),
                        title: Text('Unknown user'),
                        subtitle: Text('Could not load user details'),
                      );
                    }
    
                    String statusText;
                    Color statusColor;
                    IconData statusIcon;

                    switch (request.status) {
                      case model.FriendRequestStatus.pending:
                        statusText = 'Pending';
                        statusColor = Colors.orange;
                        statusIcon = Icons.hourglass_top;
                        break;
                      case model.FriendRequestStatus.accepted:
                        statusText = 'Accepted';
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle;
                        break;
                      case model.FriendRequestStatus.rejected:
                        statusText = 'Rejected';
                        statusColor = Colors.red;
                        statusIcon = Icons.cancel;
                        break;
                      case model.FriendRequestStatus.canceled:
                        statusText = 'Canceled';
                        statusColor = Colors.grey;
                        statusIcon = Icons.block;
                        break;
                    }
    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: user.profilePicUrl != null
                            ? NetworkImage(user.profilePicUrl!)
                            : null,
                        child: user.profilePicUrl == null
                            ? Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.blue),
                              )
                            : null,
                      ),
                      title: Text(user.name),
                      subtitle: Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Chip(
                        label: Text(statusText),
                        avatar: Icon(statusIcon, size: 16),
                        backgroundColor: statusColor.withOpacity(0.1),
                        labelStyle: TextStyle(color: statusColor),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}