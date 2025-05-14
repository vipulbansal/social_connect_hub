import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/entities/chat/message_entity.dart';
import '../../../domain/entities/user/user_entity.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isFromMe;
  final bool showTime;
  final bool showAvatar;
  final UserEntity? sender;
  
  const MessageBubble({
    super.key,
    required this.message,
    required this.isFromMe,
    required this.showTime,
    required this.showAvatar,
    this.sender,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showTime)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.surfaceVariant
                        : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatDateTime(message.timestamp ?? message.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          
          Row(
            mainAxisAlignment: isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar (for received messages)
              if (!isFromMe && showAvatar)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  backgroundImage: sender?.profilePicUrl != null
                      ? NetworkImage(sender!.profilePicUrl!)
                      : null,
                  child: sender?.profilePicUrl == null
                      ? Text(
                          sender?.name.isNotEmpty == true
                              ? sender!.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 8,
                          ),
                        )
                      : null,
                )
              else if (!isFromMe)
                const SizedBox(width: 24),
              
              const SizedBox(width: 4),
              
              // Message bubble
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isFromMe 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.surfaceVariant
                          : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isFromMe ? const Radius.circular(0) : null,
                      bottomLeft: !isFromMe ? const Radius.circular(0) : null,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message content based on contentType
                      if (message.contentType == 'text')
                        Text(
                          message.content,
                          style: TextStyle(
                            color: isFromMe 
                              ? Theme.of(context).colorScheme.onPrimary 
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        )
                      else if (message.contentType == 'image')
                        _buildImageMessage(context)
                      else if (message.contentType == 'video')
                        _buildVideoMessage(context)
                      else if (message.contentType == 'file')
                        _buildFileMessage(context)
                      else if (message.contentType == 'audio')
                        _buildAudioMessage(context),
                        
                      // Time and status
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(message.timestamp ?? message.createdAt),
                              style: TextStyle(
                                fontSize: 9,
                                color: isFromMe 
                                  ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                                  : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(width: 4),
                            if (isFromMe)
                              Icon(
                                message.isRead ? Icons.done_all : Icons.done,
                                size: 12,
                                color: message.isRead 
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (dateToCheck == today) {
      return 'Today at ${DateFormat.jm().format(dateTime)}';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday at ${DateFormat.jm().format(dateTime)}';
    } else {
      return DateFormat.yMMMd().add_jm().format(dateTime);
    }
  }
  
  String _formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }
  
  // Display an image message
  Widget _buildImageMessage(BuildContext context) {
    return InkWell(
      onTap: () {
        _openImage(context, message.content);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              message.content,
              width: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50, color: Colors.red),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Photo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isFromMe
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  // Display a video message
  Widget _buildVideoMessage(BuildContext context) {
    return InkWell(
      onTap: () {
        _launchUrl(message.content);
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black54
              : Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ),
                const Icon(
                  Icons.play_circle_filled,
                  size: 50,
                  color: Colors.white,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Video',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isFromMe
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Tap to open',
                    style: TextStyle(
                      fontSize: 12,
                      color: (isFromMe
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant)
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Display a file message
  Widget _buildFileMessage(BuildContext context) {
    try {
      // Parse the file info from content
      Map<String, dynamic> fileInfo;
      String fileName = 'File';
      String fileUrl = message.content;
      
      // Try to parse JSON
      if (message.content.contains('{') && message.content.contains('}')) {
        try {
          // Clean up string if needed
          String cleanContent = message.content
              .replaceAll('{url: ', '{"url":"')
              .replaceAll(', name: ', '","name":"')
              .replaceAll('}', '"}');
          fileInfo = json.decode(cleanContent);
          fileName = fileInfo['name'] ?? 'File';
          fileUrl = fileInfo['url'] ?? message.content;
        } catch (e) {
          // Fallback to simple string parsing if JSON parsing fails
          final urlStart = message.content.indexOf('url') + 6;
          final urlEnd = message.content.indexOf(',', urlStart) - 1;
          if (urlEnd > urlStart) {
            fileUrl = message.content.substring(urlStart, urlEnd);
          }
          
          final nameStart = message.content.indexOf('name') + 7;
          final nameEnd = message.content.indexOf('}', nameStart) - 1;
          if (nameEnd > nameStart) {
            fileName = message.content.substring(nameStart, nameEnd);
          }
        }
      }
      
      return InkWell(
        onTap: () {
          _launchUrl(fileUrl);
        },
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 200,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue.shade900
                      : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.insert_drive_file,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isFromMe
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Tap to download',
                      style: TextStyle(
                        fontSize: 12,
                        color: (isFromMe
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant)
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return Text(
        'File: ${message.content}',
        style: TextStyle(
          color: isFromMe
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
      );
    }
  }
  
  // Display an audio message
  Widget _buildAudioMessage(BuildContext context) {
    try {
      // Parse the audio info from content
      Map<String, dynamic> audioInfo;
      String fileName = 'Audio';
      String audioUrl = message.content;
      
      // Try to parse JSON
      if (message.content.contains('{') && message.content.contains('}')) {
        try {
          // Clean up string if needed
          String cleanContent = message.content
              .replaceAll('{url: ', '{"url":"')
              .replaceAll(', name: ', '","name":"')
              .replaceAll('}', '"}');
          audioInfo = json.decode(cleanContent);
          fileName = audioInfo['name'] ?? 'Audio';
          audioUrl = audioInfo['url'] ?? message.content;
        } catch (e) {
          // Fallback to simple string parsing if JSON parsing fails
          final urlStart = message.content.indexOf('url') + 6;
          final urlEnd = message.content.indexOf(',', urlStart) - 1;
          if (urlEnd > urlStart) {
            audioUrl = message.content.substring(urlStart, urlEnd);
          }
          
          final nameStart = message.content.indexOf('name') + 7;
          final nameEnd = message.content.indexOf('}', nameStart) - 1;
          if (nameEnd > nameStart) {
            fileName = message.content.substring(nameStart, nameEnd);
          }
        }
      }
      
      return InkWell(
        onTap: () {
          _launchUrl(audioUrl);
        },
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.orange.shade900.withOpacity(0.3)
                : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.orange.shade900
                      : Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.headphones,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isFromMe
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Tap to play',
                      style: TextStyle(
                        fontSize: 12,
                        color: (isFromMe
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant)
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return Text(
        'Audio: ${message.content}',
        style: TextStyle(
          color: isFromMe
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
      );
    }
  }
  
  // Open an image in full screen
  void _openImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(8),
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 3,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 100, color: Colors.red),
                    ),
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
  
  // Launch a URL
  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $url');
    }
  }
}