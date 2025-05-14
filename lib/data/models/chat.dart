import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'chat.g.dart';

enum ChatType {
  direct
}

@JsonSerializable()
@HiveType(typeId: 0)
class Chat {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  List<String> participants;
  
  @HiveField(2)
  String lastMessage;
  
  @HiveField(3)
  String lastMessageSenderId;
  
  @HiveField(4)
  bool hasUnreadMessages;
  
  @HiveField(5)
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime lastMessageTime;
  
  @HiveField(6)
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime createdAt;
  
  @HiveField(7)
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? updatedAt;

  Chat({
    required this.id,
    required this.participants,
    this.lastMessage = '',
    this.lastMessageSenderId = '',
    this.hasUnreadMessages = false,
    DateTime? lastMessageTime,
    required this.createdAt,
    this.updatedAt,
  }) : lastMessageTime = lastMessageTime ?? DateTime.now();

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  Map<String, dynamic> toJson() => _$ChatToJson(this);

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
  
  static dynamic _dateTimeToJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}