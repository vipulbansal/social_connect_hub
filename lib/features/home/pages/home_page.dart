import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_connect_hub/domain/entities/friend/friend_request_entity.dart';
import 'package:social_connect_hub/domain/entities/user/user_entity.dart';
import 'package:social_connect_hub/features/friends/services/friend_service.dart';
import '../../../domain/core/result.dart';
import '../../../domain/entities/chat/chat_entity.dart';
import '../../auth/services/auth_service.dart';
import '../../chat/services/chat_service.dart';

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
              // const PopupMenuItem<String>(
              //   value: 'settings',
              //   child: Row(
              //     children: [
              //       Icon(Icons.settings),
              //       SizedBox(width: 8),
              //       Text('Settings'),
              //     ],
              //   ),
              // ),
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
                  child: Column(
                    children: [
                      Text('${provider.currentUser?.name}'),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Chats tab
                            _ChatsTab(),
                            // Friends tab
                            _FriendsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: false,
        child: FloatingActionButton(
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
      ),
    );
  }
}

class _ChatsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);

    return StreamBuilder<List<ChatEntity>>(
      stream: chatService.getChatListStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final chats = snapshot.data ?? [];

        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No chats yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start a conversation by searching for friends',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/search'),
                  icon: const Icon(Icons.search),
                  label: const Text('Find Friends'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return _ChatListItem(chat: chat);
          },
        );
      },
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final ChatEntity chat;

  const _ChatListItem({required this.chat});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.currentUser?.id ?? '';

    // Get other participant's ID
    final otherUserId = chat.participantIds.firstWhere(
          (id) => id != currentUserId,
      orElse: () => '',
    );

    return FutureBuilder<UserEntity?>(
      future: Provider.of<ChatService>(context, listen: false).getUserById(otherUserId),
      builder: (context, snapshot) {
        final otherUser = snapshot.data;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            backgroundImage: otherUser?.photoUrl != null
                ? NetworkImage(otherUser!.photoUrl!)
                : null,
            child: otherUser?.photoUrl == null
                ? Text(
              otherUser?.name.isNotEmpty == true
                  ? otherUser!.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(color: Colors.blue),
            )
                : null,
          ),
          title: Text(
            otherUser?.name ?? 'Unknown User',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            chat.lastMessageContent ?? 'No messages yet',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (chat.lastMessageTimestamp != null)
                Text(
                  _formatTime(chat.lastMessageTimestamp!),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              const SizedBox(height: 4),
              if (chat.lastMessageSenderId != null && chat.lastMessageSenderId != currentUserId)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () {
            context.push('/chat/${chat.id}');
          },
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.year == time.year && now.month == time.month && now.day == time.day) {
      // Today, show time
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (now.year == time.year) {
      // This year, show month and day
      return '${time.month}/${time.day}';
    } else {
      // Different year, show year
      return '${time.month}/${time.day}/${time.year}';
    }
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

    return FutureBuilder<UserEntity?>(
      future: Provider.of<ChatService>(context, listen: false).getUserById(request.fromUserId),
      builder: (context, snapshot) {
        final sender = snapshot.data;

        if (sender == null) {
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
                backgroundImage: sender.photoUrl != null
                    ? NetworkImage(sender.photoUrl!)
                    : null,
                child: sender.photoUrl == null
                    ? Text(
                  sender.name.isNotEmpty ? sender.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.blue),
                )
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                sender.name,
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

class _FriendListItem extends StatelessWidget {
  final UserEntity friend;

  const _FriendListItem({required this.friend});

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        backgroundImage: friend.photoUrl != null
            ? NetworkImage(friend.photoUrl!)
            : null,
        child: friend.photoUrl == null
            ? Text(
          friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.blue),
        )
            : null,
      ),
      title: Text(friend.name),
      subtitle: Text(
        friend.email,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.chat_bubble_outline),
        onPressed: () async {
          final chatId = await chatService.createOrGetChat(friend.id);
          if (context.mounted) {
            context.push('/chat/$chatId');
          }
        },
      ),
      onTap: () async {
        final chatId = await chatService.createOrGetChat(friend.id);
        if (context.mounted) {
          context.push('/chat/$chatId');
        }
      },
    );
  }
}