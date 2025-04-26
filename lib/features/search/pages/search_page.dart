import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_connect_hub/features/friends/services/friend_service.dart';
import 'package:social_connect_hub/features/search/services/search_service.dart';

import '../../auth/services/auth_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late SearchService _searchService;

  @override
  void initState() {
    super.initState();
    // Auto focus the search field
    _searchService = context.read<SearchService>();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _searchService.searchedUsers = [];
      return;
    }

    try {
      final results = await _searchService.searchUsers(query);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search by name or email',
            border: InputBorder.none,
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _searchService.searchedUsers = [];
                      },
                    )
                    : null,
          ),
          onChanged: (value) {
            setState(() {});
          },
          onSubmitted: (value) {
            _performSearch();
          },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _performSearch),
        ],
      ),
      body: Consumer2<SearchService,FriendService>(
        builder: (context, searchService,friendService, child) {
          return Column(
            children: [
              if (searchService.isLoading)
                const LinearProgressIndicator()
              else if (searchService.errorMessage?.isNotEmpty ?? false)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.red.shade100,
                  width: double.infinity,
                  child: Text(
                    searchService.errorMessage!,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              searchService.searchedUsers.isEmpty
                  ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No users found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try searching for a different name or email',
                            style: TextStyle(color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                  : Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        final user =searchService.searchedUsers[index];
                        // Don't show current user in search results
                        if (currentUser != null && user.id == currentUser.id) {
                          return const SizedBox.shrink();
                        }
                        // Check if user is already a friend
                        final isFriend = currentUser != null &&
                            currentUser.friendIds.contains(user.id);
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
                          trailing: isFriend
                              ? ElevatedButton(
                            onPressed: () async {
                              try {
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Message'),
                          )
                              : OutlinedButton(
                            onPressed: () async {
                              // Send friend request
                              if (mounted) {
                                bool sendFriendRequest=await friendService.sendFriendRequest(user.id);
                                if(sendFriendRequest){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Friend Request Sent Successfully'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Add Friend'),
                          ),
                          onTap: () async {
                            // View user profile or start chat
                            if (isFriend) {
                              try {
                                // Navigate to chat
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        );
                      },
                      itemCount: searchService.searchedUsers.length,
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
