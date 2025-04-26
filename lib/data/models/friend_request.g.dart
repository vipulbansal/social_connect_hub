// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendRequest _$FriendRequestFromJson(Map<String, dynamic> json) =>
    FriendRequest(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      status: json['status'] == null
          ? FriendRequestStatus.pending
          : FriendRequest._requestStatusFromJson(json['status']),
      createdAt: FriendRequest._dateTimeFromJson(json['createdAt']),
      updatedAt: FriendRequest._dateTimeFromJson(json['updatedAt']),
      timestamp: FriendRequest._dateTimeFromJson(json['timestamp']),
    );

Map<String, dynamic> _$FriendRequestToJson(FriendRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'status': FriendRequest._requestStatusToJson(instance.status),
      'createdAt': FriendRequest._dateTimeToJson(instance.createdAt),
      'updatedAt': FriendRequest._dateTimeToJson(instance.updatedAt),
      'timestamp': FriendRequest._dateTimeToJson(instance.timestamp),
    };
