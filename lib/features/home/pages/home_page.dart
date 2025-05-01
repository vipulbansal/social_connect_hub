import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_connect_hub/domain/entities/friend/friend_request_entity.dart';
import 'package:social_connect_hub/domain/entities/user/user_entity.dart';
import 'package:social_connect_hub/features/friends/services/friend_service.dart';
import '../../../domain/core/result.dart';
import '../../auth/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _signOut() async {
    final authService = context.read<AuthService>();
    await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vipul\'s Connect Hub',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          Consumer<FriendService>(
            builder: (context, friendService, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.people_alt_outlined),
                    onPressed: () => context.push('/friend-requests'),
                  ),
                  if (friendService.pendingReceivedRequests.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          friendService.pendingReceivedRequests.length > 9 ? '9+' : friendService.pendingReceivedRequests.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _signOut();
              } else if (value == 'profile') {
                context.push('/profile');
              } else if (value == 'friend_requests') {
                context.push('/friend-requests');
              } else if (value == 'settings') {
                context.push('/settings');
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'friend_requests',
                child: Row(
                  children: [
                    Icon(Icons.person_add),
                    SizedBox(width: 8),
                    Text('Friend Requests'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Friends'),
          ],
        ),
      ),

      body: SafeArea(
        child: Container(
          child: Consumer2<AuthService,FriendService>(
            builder: (context, provider,friendService, child) {

              if (provider.isLoading) {
                return Center(child: CircularProgressIndicator());
              } else {
                return Center(
                  child: Text('Home ${provider.currentUser?.name}'),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0) {
            // New chat
            context.push('/search');
          } else {
            // Add friend
            context.push('/search');
          }
        },
        child: Icon(_selectedIndex == 0 ? Icons.chat : Icons.person_add),
      ),
    );
  }
}


class _FriendsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final friendService = Provider.of<FriendService>(context);

    return StreamBuilder<List<UserEntity>>(
      stream: friendService.watchUserFriends(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final friends = snapshot.data ?? [];

        if (friends.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No friends yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add friends to start chatting',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/search'),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Friends'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Friend requests
            _FriendRequestsSection(),

            // Divider
            const Divider(height: 1),

            // Friends list
            Expanded(
              child: ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return _FriendListItem(friend: friend);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FriendListItem extends StatelessWidget {
  final UserEntity friend;

  const _FriendListItem({required this.friend});

  @override
  Widget build(BuildContext context) {
   // final chatService = Provider.of<ChatService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    return Text('FriendListItem');
    // return ListTile(
    //   leading: CircleAvatar(
    //     backgroundColor: Colors.blue.shade100,
    //     backgroundImage: friend.profilePicUrl != null
    //         ? NetworkImage(friend.profilePicUrl!)
    //         : null,
    //     child: friend.profilePicUrl == null
    //         ? Text(
    //       friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?',
    //       style: const TextStyle(color: Colors.blue),
    //     )
    //         : null,
    //   ),
    //   title: Text(friend.name),
    //   subtitle: Text(
    //     friend.email,
    //     maxLines: 1,
    //     overflow: TextOverflow.ellipsis,
    //   ),
    //   trailing: IconButton(
    //     icon: const Icon(Icons.chat_bubble_outline),
    //     onPressed: () async {
    //       final chatId = await chatService.createOrGetChat(friend.id);
    //       if (context.mounted) {
    //         context.push('/chat/$chatId');
    //       }
    //     },
    //   ),
    //   onTap: () async {
    //     final chatId = await chatService.createOrGetChat(friend.id);
    //     if (context.mounted) {
    //       context.push('/chat/$chatId');
    //     }
    //   },
    // );
  }
}

class _FriendRequestsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final friendService = Provider.of<FriendService>(context);

    return StreamBuilder<List<FriendRequestEntity>>(
      stream: friendService.watchReceivedFriendRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Friend Requests (${requests.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/friend-requests'),
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: requests.length,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _FriendRequestItem(request: request);
                },
              ),
            ),
            const Divider(height: 1),
          ],
        );
      },
    );
  }
}

class _FriendRequestItem extends StatelessWidget {
  final FriendRequestEntity request;

  const _FriendRequestItem({required this.request});

  @override
  Widget build(BuildContext context) {
    final friendService = Provider.of<FriendService>(context, listen: false);

    return FutureBuilder<Result<UserEntity>?>(
      future: Provider.of<AuthService>(context, listen: false).userRepository.getUserById(request.fromUserId),
      builder: (context, snapshot) {
        final sender = snapshot.data;

        if (sender?.isFailure??true) {
          return const SizedBox();
        }

        return Container(
          width: 80,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue.shade100,
                backgroundImage: sender?.getOrNull?.profilePicUrl != null
                    ? NetworkImage(sender!.getOrNull!.profilePicUrl!)
                    : null,
                child: sender?.getOrNull?.profilePicUrl == null
                    ? Text(
                  sender?.getOrNull?.name.isNotEmpty??false ? sender!.getOrNull!.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.blue),
                )
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                "${sender?.getOrNull?.name}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await friendService.acceptFriendRequest(request.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      await friendService.rejectFriendRequest(request.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
