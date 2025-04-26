import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_connect_hub/features/friends/services/friend_service.dart';
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
