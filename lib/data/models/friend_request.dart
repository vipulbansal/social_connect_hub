import 'package:json_annotation/json_annotation.dart';

part 'friend_request.g.dart';

enum FriendRequestStatus {
  pending,
  accepted,
  rejected,
  canceled
}

@JsonSerializable()
class FriendRequest {
  String id;
  String senderId;
  String receiverId;
  @JsonKey(fromJson: _requestStatusFromJson, toJson: _requestStatusToJson)
  FriendRequestStatus status;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime createdAt;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? updatedAt;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime timestamp;

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.status = FriendRequestStatus.pending,
    required this.createdAt,
    this.updatedAt,
    DateTime? timestamp,
  }) : this.timestamp = timestamp ?? createdAt;

  factory FriendRequest.fromJson(Map<String, dynamic> json) => _$FriendRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FriendRequestToJson(this);

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

  // FriendRequestStatus conversion
  static FriendRequestStatus _requestStatusFromJson(dynamic status) {
    if (status is FriendRequestStatus) return status;

    if (status is String) {
      return FriendRequestStatus.values.firstWhere(
            (e) => e.toString() == 'FriendRequestStatus.$status',
        orElse: () => FriendRequestStatus.pending,
      );
    }

    if (status is int) {
      return FriendRequestStatus.values[status];
    }

    return FriendRequestStatus.pending;
  }

  static String _requestStatusToJson(FriendRequestStatus status) {
    return status.toString().split('.').last;
  }
}