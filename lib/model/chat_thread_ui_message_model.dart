import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:sputnikn_chat_client/model/response/room_event_system_detail.dart';
import 'package:collection/collection.dart';
import 'event_message_content_model_v1.dart';
import 'event_system_content_model_v1.dart';

abstract class ChatThreadUIMessageModelBase {
  final String eventId;
  final DateTime timestamp;

  ChatThreadUIMessageModelBase(
    this.eventId,
    this.timestamp,
  );

  Map<String, dynamic> toMap();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatThreadUIMessageModelBase &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode ^ timestamp.hashCode;

  static ChatThreadUIEventSystem fromEventSystem(
    RoomEventSystemDetail event,
    RoomDetail chatDetail,
  ) {
    return ChatThreadUIEventSystem(
      eventId: event.eventId,
      messageContent: EventSystemContentModelV1.deserialize(event.content),
      timestamp: event.createTimestamp,
    );
  }

  static ChatThreadUIEventMessage fromEventMessage(
    RoomEventMessageDetail event,
    RoomDetail chatDetail,
  ) {
    final member =
        chatDetail.members.firstWhereOrNull((e) => e.userId == event.senderId);
    return ChatThreadUIEventMessage(
      eventId: event.eventId,
      senderId: event.senderId,
      senderName: member?.fullName ?? "",
      senderAvatar: member?.avatar,
      attachment: event.attachment,
      messageContent: EventMessageContentModelV1.deserialize(event.content),
      timestamp: event.updateTimestamp,
    );
  }

  static ChatThreadUIEventUnread fromUnread(DateTime unreadTimestamp) {
    return ChatThreadUIEventUnread(timestamp: unreadTimestamp);
  }
}

class ChatThreadUIEventMessage extends ChatThreadUIMessageModelBase {
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final List<ChatAttachmentDetail> attachment;
  final EventMessageContentModelV1 messageContent;

  ChatThreadUIEventMessage({
    required String eventId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.messageContent,
    required this.attachment,
    required DateTime timestamp,
  }) : super(eventId, timestamp);

  @override
  int get hashCode => eventId.hashCode;

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "event_id": eventId,
      "sender_id": senderId,
      "sender_name": senderName,
      "sender_avatar": senderAvatar,
      "content": messageContent.toJson(),
      "timestamp": timestamp.toIso8601String(),
    };
  }
}

class ChatThreadUIEventSystem extends ChatThreadUIMessageModelBase {
  final EventSystemContentModelV1 messageContent;

  ChatThreadUIEventSystem({
    required String eventId,
    required this.messageContent,
    required DateTime timestamp,
  }) : super(eventId, timestamp);

  @override
  int get hashCode => eventId.hashCode;

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "event_id": eventId,
      "content": messageContent.toJson(),
      "timestamp": timestamp.toIso8601String(),
    };
  }
}

class ChatThreadUIEventUnread extends ChatThreadUIMessageModelBase {
  static const keyEventId = "unread_marker";

  ChatThreadUIEventUnread({
    required DateTime timestamp,
  }) : super(keyEventId, timestamp);

  @override
  Map<String, dynamic> toMap() {
    return {
      "event_id": eventId,
      "timestamp": timestamp.toIso8601String(),
    };
  }
}
