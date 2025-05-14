import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/user.dart';
import '../../../domain/entities/chat/message_entity.dart';
import '../../../domain/entities/chat/message_type.dart';
import '../../../features/auth/services/auth_service.dart';
import '../../../features/chat/services/chat_service.dart';
import '../../../domain/entities/chat/chat_entity.dart';
import '../../../domain/entities/user/user_entity.dart';
import '../widgets/attachment_selector.dart';
import '../widgets/message_bubble.dart';



class ChatPage extends StatefulWidget {
  final String chatId;

  const ChatPage({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  UserEntity? _recipient;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChat();
    });

  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChat() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get chat details
      final chatService = Provider.of<ChatService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser == null) return;

      // Get the chat
      final chat = await chatService.getChatById(widget.chatId);
      if (chat == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat not found')),
          );
          Navigator.pop(context);
        }
        return;
      }

      // Get the other participant
      final otherUserId = chat.participantIds.firstWhere(
            (id) => id != currentUser.id,
        orElse: () => '',
      );

      final otherUser = await chatService.getUserById(otherUserId);

      if (mounted) {
        setState(() {
          _recipient = otherUser;
          _isLoading = false;
        });

        // Mark messages as read
        chatService.markMessagesAsRead(widget.chatId);
      }

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading chat: $e')),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    if (currentUser == null) return;

    _messageController.clear();

    try {
      final chatService = Provider.of<ChatService>(context, listen: false);

      await chatService.sendMessage(
        chatId: widget.chatId,
        text: message,
      );

      // Scroll to bottom after message is sent
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    if (_isLoading || currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: _recipient?.photoUrl != null
                  ? NetworkImage(_recipient!.photoUrl!)
                  : null,
              child: _recipient?.photoUrl == null
                  ? Text(
                _recipient?.name.isNotEmpty == true
                    ? _recipient!.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(color: Colors.blue, fontSize: 12),
              )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _recipient?.name ?? 'Unknown User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_recipient != null)
                    Text(
                      'Online', // TODO: Implement online/offline status
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade400,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Visibility(
            visible: false,
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show menu
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.delete),
                            title: const Text('Clear chat history'),
                            onTap: () {
                              // TODO: Implement clear chat
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.block),
                            title: const Text('Block user'),
                            onTap: () {
                              // TODO: Implement block user
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: Consumer<ChatService>(
              builder: (context, chatService, child) {
                return StreamBuilder<List<MessageEntity>>(
                  stream: chatService.getMessagesStream(widget.chatId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    final messages = snapshot.data ?? [];

                    if (messages.isEmpty) {
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
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start a conversation',
                              style: TextStyle(color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    // Scroll to bottom when new messages arrive
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: messages.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isFromMe = message.senderId == currentUser.id;

                        return MessageBubble(
                          message: message,
                          isFromMe: isFromMe,
                          showTime: _shouldShowTime(index, messages),
                          showAvatar: !isFromMe && _shouldShowAvatar(index, messages),
                          sender: UserEntity(
                            id: isFromMe ? currentUser.id : (_recipient?.id ?? ''),
                            name: isFromMe ? currentUser.name : (_recipient?.name ?? 'Unknown'),
                            email: isFromMe ? currentUser.email : (_recipient?.email ?? ''),
                            photoUrl: isFromMe ? currentUser.photoUrl : _recipient?.photoUrl,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment button
                  Visibility(
                    visible:false,
                    child: IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: () {
                        _showAttachmentOptions(context);
                      },
                    ),
                  ),

                  // Message text field
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: TextStyle(color: Theme.of(context).hintColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.surfaceVariant
                            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: 5,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),

                  // Send button
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowTime(int index, List<MessageEntity> messages) {
    // Show time for first message
    if (index == 0) return true;

    // Show time if more than 15 minutes since last message
    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];
    return currentMessage.createdAt.difference(previousMessage.createdAt).inMinutes > 15;
  }

  bool _shouldShowAvatar(int index, List<MessageEntity> messages) {
    // Show avatar for last message or if next message is from a different sender
    if (index == messages.length - 1) return true;

    final currentMessage = messages[index];
    final nextMessage = messages[index + 1];
    return currentMessage.senderId != nextMessage.senderId;
  }

  void _showAttachmentOptions(BuildContext context) {
    AttachmentSelector.show(context, (type) {
      switch (type) {
        case AttachmentType.image:
          _pickImage();
          break;
        case AttachmentType.video:
          _pickVideo();
          break;
        case AttachmentType.file:
          _pickFile();
          break;
        case AttachmentType.audio:
          _pickAudio();
          break;
        case AttachmentType.location:
        // TODO: Implement location sharing
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location sharing coming soon')),
          );
          break;
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      final chatService = Provider.of<ChatService>(context, listen: false);

      if (_recipient == null) return;

      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        final file = File(pickedFile.path);
        // For this example, we'll use a placeholder URL
        // In a real app, we would upload the file and get a real URL
        await chatService.sendMessage(
            chatId: widget.chatId,
            text: "Image",
            mediaUrl: "image_url_placeholder",
            type: MessageType.image
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // Hide loading indicator
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false; // Ensure loading indicator is hidden on error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending image: $e')),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

      if (pickedFile == null) return;

      final chatService = Provider.of<ChatService>(context, listen: false);

      if (_recipient == null) return;

      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        final file = File(pickedFile.path);
        await chatService.sendMessage(
            chatId: widget.chatId,
            text: "Video",
            mediaUrl: "video_url_placeholder",  // Replace with actual upload logic
            type: MessageType.video
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // Hide loading indicator
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false; // Ensure loading indicator is hidden on error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending video: $e')),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final fileName = file.name;

      final chatService = Provider.of<ChatService>(context, listen: false);

      if (_recipient == null) return;

      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        if (file.path != null) {
          final fileObj = File(file.path!);
          await chatService.sendMessage(
            chatId: widget.chatId,
            text: fileName,
            mediaUrl: "file_url_placeholder",
            type: MessageType.file,
            metadata: {'fileName': fileName},
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // Hide loading indicator
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false; // Ensure loading indicator is hidden on error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending file: $e')),
        );
      }
    }
  }

  Future<void> _pickAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final fileName = file.name;

      final chatService = Provider.of<ChatService>(context, listen: false);

      if (_recipient == null) return;

      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        if (file.path != null) {
          final fileObj = File(file.path!);
          await chatService.sendMessage(
            chatId: widget.chatId,
            text: "Audio",
            mediaUrl: "audio_url_placeholder",
            type: MessageType.audio,
            metadata: {'duration': '30'}, // Replace with actual duration calculation
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // Hide loading indicator
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false; // Ensure loading indicator is hidden on error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending audio: $e')),
        );
      }
    }
  }
}

