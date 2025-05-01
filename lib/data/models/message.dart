import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 3)
enum MessageType {
  @HiveField(0)
  text,
  @HiveField(1)
  image,
  @HiveField(2)
  video,
  @HiveField(3)
  file,
  @HiveField(4)
  audio,
  @HiveField(5)
  location,
  @HiveField(6)
  system
}

@HiveType(typeId: 4)
enum MessageStatus {
  @HiveField(0)
  sending,
  @HiveField(1)
  sent,
  @HiveField(2)
  delivered,
  @HiveField(3)
  read,
  @HiveField(4)
  failed
}

@JsonSerializable()
@HiveType(typeId: 1)
class Message {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String chatId;
  
  @HiveField(2)
  String senderId;
  
  @HiveField(3)
  String receiverId;
  
  @HiveField(4)
  String content;
  
  @HiveField(5)
  @JsonKey(fromJson: _messageTypeFromJson, toJson: _messageTypeToJson)
  MessageType type;
  
  @HiveField(6)
  @JsonKey(fromJson: _messageStatusFromJson, toJson: _messageStatusToJson)
  MessageStatus status;
  
  @HiveField(7)
  bool isRead;
  
  @HiveField(8)
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime timestamp;
  
  @HiveField(9)
  String? mediaUrl;
  
  @HiveField(10)
  String? thumbnailUrl;
  
  @HiveField(11)
  @JsonKey(fromJson: _metadataFromJson, toJson: _metadataToJson)
  Map<String, dynamic>? metadata;
  
  @HiveField(12)
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? createdAt;
  
  @HiveField(13)
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? updatedAt;
  
  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    String? receiverId,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.isRead = false,
    required this.timestamp,
    this.mediaUrl,
    this.thumbnailUrl,
    this.metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.receiverId = receiverId ?? '',
    this.createdAt = createdAt ?? timestamp,
    this.updatedAt = updatedAt ?? timestamp;
  
  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  
  Map<String, dynamic> toJson() => _$MessageToJson(this);
  
  // Timestamp <-> DateTime conversion
  static DateTime _dateTimeFromJson(dynamic timestamp) {
    if (timestamp is DateTime) return timestamp;
    
    if (timestamp != null) {
      try {
        // Handle Firestore Timestamp
        return timestamp.toDate();
      } catch (e) {
        // Handle ISO date string
        return DateTime.parse(timestamp.toString());
      }
    }
    
    return DateTime.now();
  }
  
  static dynamic _dateTimeToJson(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
  
  // MessageType conversion
  static MessageType _messageTypeFromJson(dynamic type) {
    if (type is MessageType) return type;
    
    if (type is String) {
      return MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.$type',
        orElse: () => MessageType.text,
      );
    }
    
    if (type is int) {
      return MessageType.values[type];
    }
    
    return MessageType.text;
  }
  
  static String _messageTypeToJson(MessageType type) {
    return type.toString().split('.').last;
  }
  
  // MessageStatus conversion
  static MessageStatus _messageStatusFromJson(dynamic status) {
    if (status is MessageStatus) return status;
    
    if (status is String) {
      return MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.$status',
        orElse: () => MessageStatus.sent,
      );
    }
    
    if (status is int) {
      return MessageStatus.values[status];
    }
    
    return MessageStatus.sent;
  }
  
  static String _messageStatusToJson(MessageStatus status) {
    return status.toString().split('.').last;
  }
  
  // Metadata conversions
  static Map<String, dynamic>? _metadataFromJson(dynamic metadata) {
    if (metadata == null) return null;
    if (metadata is Map<String, dynamic>) return metadata;
    
    try {
      if (metadata is String) {
        // Try to parse from JSON string
        final Map<String, dynamic> parsed = Map<String, dynamic>.from(
          metadata.startsWith('{') && metadata.endsWith('}')
              ? Map<String, dynamic>.from(json.decode(metadata))
              : {'text': metadata}
        );
        return parsed;
      }
      
      if (metadata is Map) {
        // Convert generic Map to Map<String, dynamic>
        return Map<String, dynamic>.from(metadata.map((k, v) => MapEntry(k.toString(), v)));
      }
    } catch (e) {
      print('Error parsing metadata: $e');
    }
    
    return null;
  }
  
  static dynamic _metadataToJson(Map<String, dynamic>? metadata) {
    if (metadata == null) return null;
    return metadata;
  }
}