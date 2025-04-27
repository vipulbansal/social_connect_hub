// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppNotificationAdapter extends TypeAdapter<AppNotification> {
  @override
  final int typeId = 4;

  @override
  AppNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppNotification(
      id: fields[0] as String,
      title: fields[1] as String,
      body: fields[2] as String,
      userId: fields[3] as String,
      senderId: fields[4] as String?,
      type: fields[5] as String,
      objectId: fields[6] as String?,
      isRead: fields[7] as bool,
      timestamp: fields[8] as DateTime,
      readAt: fields[9] as DateTime?,
      receiverFcmToken: fields[10] as String?,
      data: (fields[11] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AppNotification obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.userId)
      ..writeByte(4)
      ..write(obj.senderId)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.objectId)
      ..writeByte(7)
      ..write(obj.isRead)
      ..writeByte(8)
      ..write(obj.timestamp)
      ..writeByte(9)
      ..write(obj.readAt)
      ..writeByte(10)
      ..write(obj.receiverFcmToken)
      ..writeByte(11)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      userId: json['userId'] as String,
      senderId: json['senderId'] as String?,
      type: json['type'] as String,
      objectId: json['objectId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      timestamp: AppNotification._dateTimeFromJson(json['timestamp']),
      readAt: AppNotification._nullableDateTimeFromJson(json['readAt']),
      receiverFcmToken: json['receiverFcmToken'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AppNotificationToJson(AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'userId': instance.userId,
      'senderId': instance.senderId,
      'type': instance.type,
      'objectId': instance.objectId,
      'isRead': instance.isRead,
      'timestamp': AppNotification._dateTimeToJson(instance.timestamp),
      'readAt': AppNotification._nullableDateTimeToJson(instance.readAt),
      'receiverFcmToken': instance.receiverFcmToken,
      'data': instance.data,
    };
