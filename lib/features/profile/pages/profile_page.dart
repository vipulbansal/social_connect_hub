import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:social_connect_hub/features/chat/services/chat_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/entities/user/user_entity.dart';
import '../../../features/auth/services/auth_service.dart';
import '../../../features/friends/services/friend_service.dart';

class ProfilePage extends StatefulWidget {
  final String? userId; // If null, display current user profile

  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserEntity? _user;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      // If userId is provided, fetch that user, otherwise use current user
      if (widget.userId != null) {
        final userEntity = await authService.userRepository.getUserById(
          widget.userId!,
        );
        userEntity.fold(
          onSuccess: (entity) => _user = entity,
          onFailure: (abc) => _user = null,
        );
      } else {
        _user = authService.currentUser;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while loading
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error if loading failed
    if (_errorMessage != null || _user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'User not found',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final isCurrentUser =
        widget.userId == null ||
        (Provider.of<AuthService>(context).currentUser?.id == widget.userId);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              actions:
                  isCurrentUser
                      ? [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => context.push('/profile/edit').then((_)=> _loadUserData()),
                        ),
                      ]
                      : null,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Banner image
                    _user!.bannerImageUrl != null
                        ? Image.network(
                          _user!.bannerImageUrl!,
                          fit: BoxFit.cover,
                        )
                        : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primaryContainer,
                              ],
                            ),
                          ),
                        ),

                    // Gradient overlay for text visibility
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile image and basic info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Profile image
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                          backgroundImage:
                              _user!.photoUrl != null
                                  ? NetworkImage(_user!.photoUrl!)
                                  : null,
                          child:
                              _user!.photoUrl == null
                                  ? Text(
                                    _user!.name.isNotEmpty
                                        ? _user!.name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                  : null,
                        ),

                        const SizedBox(width: 16),

                        // Name and username
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _user!.displayName ?? _user!.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_user!.displayName != null &&
                                  _user!.displayName != _user!.name)
                                Text(
                                  _user!.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.copyWith(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Bio
                    if (_user!.bio != null && _user!.bio!.isNotEmpty)
                      Text(
                        _user!.bio!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                    if (_user!.bio != null && _user!.bio!.isNotEmpty)
                      const SizedBox(height: 16),

                    // User info row (location, website, joined date)
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        // Location
                        if (_user!.location != null &&
                            _user!.location!.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _user!.location!,
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),

                        // Website
                        if (_user!.website != null &&
                            _user!.website!.isNotEmpty)
                          GestureDetector(
                            onTap: () => _launchUrl(_user!.website!),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.link,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _user!.website!,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                        // Joined date
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Joined ${_formatDate(_user!.createdAt)}',
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Friends count
                    Row(
                      children: [
                        Text(
                          // Using null-aware operator in case friends list is not available
                          '${_user!.friends?.length ?? 0} Friends',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [Tab(text: 'About'), Tab(text: 'Friends')],
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // About tab
            _AboutTab(user: _user!),

            // Friends tab
            _FriendsTab(user: _user!),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _AboutTab extends StatelessWidget {
  final UserEntity user;

  const _AboutTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Bio section
        if (user.bio != null && user.bio!.isNotEmpty) ...[
          _buildSectionHeader(context, 'Bio'),
          Text(user.bio!),
          const SizedBox(height: 24),
        ],

        // Contact Information
        _buildSectionHeader(context, 'Contact Information'),

        // Email
        _buildInfoRow(
          context,
          icon: Icons.email,
          title: 'Email',
          value: user.email,
        ),

        // Phone
        if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
          _buildInfoRow(
            context,
            icon: Icons.phone,
            title: 'Phone',
            value: user.phoneNumber!,
          ),

        // Website
        if (user.website != null && user.website!.isNotEmpty)
          _buildInfoRow(
            context,
            icon: Icons.link,
            title: 'Website',
            value: user.website!,
            isLink: true,
          ),

        const SizedBox(height: 24),

        // Basic Information
        _buildSectionHeader(context, 'Basic Information'),

        // Location
        if (user.location != null && user.location!.isNotEmpty)
          _buildInfoRow(
            context,
            icon: Icons.location_on,
            title: 'Location',
            value: user.location!,
          ),

        // Joined
        _buildInfoRow(
          context,
          icon: Icons.calendar_today,
          title: 'Joined',
          value: _formatDate(user.createdAt),
        ),

        // Last active
        if (user.lastSeen != null)
          _buildInfoRow(
            context,
            icon: Icons.access_time,
            title: 'Last Active',
            value: _formatDate(user.lastSeen!),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                isLink
                    ? GestureDetector(
                      onTap: () => _launchUrl(value),
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                    : Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}

class _FriendsTab extends StatelessWidget {
  final UserEntity user;

  const _FriendsTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final friendService = Provider.of<FriendService>(context);
    final currentUser = authService.currentUser;

    return StreamBuilder<List<UserEntity>>(
      stream: friendService.watchUserFriends(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading friends: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final friends = snapshot.data ?? [];

        if (friends.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  user.id == currentUser?.id
                      ? 'You don\'t have any friends yet'
                      : '${user.name} doesn\'t have any friends yet',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (user.id == currentUser?.id)
                  ElevatedButton.icon(
                    onPressed: () => context.push('/search'),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Find Friends'),
                  ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.2),
                backgroundImage:
                    friend.photoUrl != null
                        ? NetworkImage(friend.photoUrl!)
                        : null,
                child:
                    friend.photoUrl == null
                        ? Text(
                          friend.name.isNotEmpty
                              ? friend.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                        : null,
              ),
              title: Text(friend.displayName ?? friend.name),
              subtitle: Text(friend.location ?? 'No location'),
              onTap: () => context.push('/profile/${friend.id}'),
              trailing:
                  currentUser?.id == user.id
                      ? IconButton(
                        icon: const Icon(Icons.chat),
                        onPressed: ()async {
                          // Navigate to chat
                          final chatService = Provider.of<ChatService>(context, listen: false);
                          final chatId = await chatService.createOrGetChat(friend.id);
                          context.push('/chat/${friend.id}');
                        },
                      )
                      : null,
            );
          },
        );
      },
    );
  }
}
