import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';
part 'app_notification.g.dart';

@JsonSerializable()
@HiveType(typeId: 4)
class AppNotification {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String body;
  
  @HiveField(3)
  String userId;
  
  @HiveField(4)
  String? senderId;
  
  @HiveField(5)
  String type;
  
  @HiveField(6)
  String? objectId;
  
  @HiveField(7)
  bool isRead;
  
  @HiveField(8)
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime timestamp;
  
  @HiveField(9)
  @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)
  DateTime? readAt;
  
  @HiveField(10)
  String? receiverFcmToken;
  
  @HiveField(11)
  Map<String, dynamic>? data;
  
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    this.senderId,
    required this.type,
    this.objectId,
    this.isRead = false,
    required this.timestamp,
    this.readAt,
    this.receiverFcmToken,
    this.data,
  });
  
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      userId: json['userId'] as String,
      senderId: json['senderId'] as String?,
      type: json['type'] as String,
      objectId: json['objectId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      timestamp: _dateTimeFromJson(json['timestamp']),
      readAt: _nullableDateTimeFromJson(json['readAt']),
      receiverFcmToken: json['receiverFcmToken'] as String?,
      data: json['data'] != null 
          ? Map<String, dynamic>.from(json['data'] as Map) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
      'senderId': senderId,
      'type': type,
      'objectId': objectId,
      'isRead': isRead,
      'timestamp': _dateTimeToJson(timestamp),
      'readAt': _nullableDateTimeToJson(readAt),
      'receiverFcmToken': receiverFcmToken,
      'data': data,
    };
  }
  
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
  
  // Nullable timestamp <-> DateTime conversion
  static DateTime? _nullableDateTimeFromJson(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is DateTime) return timestamp;
    
    try {
      // Handle Firestore Timestamp
      return timestamp.toDate();
    } catch (e) {
      // Handle ISO date string
      try {
        return DateTime.parse(timestamp.toString());
      } catch (e) {
        return null;
      }
    }
  }
  
  static dynamic _nullableDateTimeToJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}