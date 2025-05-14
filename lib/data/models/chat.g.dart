// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatAdapter extends TypeAdapter<Chat> {
  @override
  final int typeId = 0;

  @override
  Chat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Chat(
      id: fields[0] as String,
      participants: (fields[1] as List).cast<String>(),
      lastMessage: fields[2] as String,
      lastMessageSenderId: fields[3] as String,
      hasUnreadMessages: fields[4] as bool,
      lastMessageTime: fields[5] as DateTime?,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Chat obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.participants)
      ..writeByte(2)
      ..write(obj.lastMessage)
      ..writeByte(3)
      ..write(obj.lastMessageSenderId)
      ..writeByte(4)
      ..write(obj.hasUnreadMessages)
      ..writeByte(5)
      ..write(obj.lastMessageTime)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat(
      id: json['id'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageSenderId: json['lastMessageSenderId'] as String? ?? '',
      hasUnreadMessages: json['hasUnreadMessages'] as bool? ?? false,
      lastMessageTime: Chat._dateTimeFromJson(json['lastMessageTime']),
      createdAt: Chat._dateTimeFromJson(json['createdAt']),
      updatedAt: Chat._dateTimeFromJson(json['updatedAt']),
    );

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
      'id': instance.id,
      'participants': instance.participants,
      'lastMessage': instance.lastMessage,
      'lastMessageSenderId': instance.lastMessageSenderId,
      'hasUnreadMessages': instance.hasUnreadMessages,
      'lastMessageTime': Chat._dateTimeToJson(instance.lastMessageTime),
      'createdAt': Chat._dateTimeToJson(instance.createdAt),
      'updatedAt': Chat._dateTimeToJson(instance.updatedAt),
    };
