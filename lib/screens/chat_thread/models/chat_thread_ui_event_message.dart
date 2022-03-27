import 'package:chat_client_repository/chat_client_repository.dart';
import 'package:collection/collection.dart';
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:sputnikn_chatsample/screens/chat_thread/models/models.dart';

class ChatThreadUIEventMessage extends ChatThreadUIMessageModelBase {
  const ChatThreadUIEventMessage({
    required String eventId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.messageContent,
    required this.attachment,
    required DateTime timestamp,
  }) : super(eventId, timestamp);

  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final List<ChatAttachmentDetail> attachment;
  final EventMessageContentModelV1 messageContent;

  static ChatThreadUIEventMessage fromEventMessage(
      RoomEventMessageDetail event,
      RoomDetail chatDetail,
      ) {
    final member =
    chatDetail.members.firstWhereOrNull((e) => e.userId == event.senderId);
    return ChatThreadUIEventMessage(
      eventId: event.eventId,
      senderId: event.senderId,
      senderName: member?.fullName ?? '',
      senderAvatar: member?.avatar,
      attachment: event.attachment,
      messageContent: EventMessageContentModelV1.deserialize(event.content),
      timestamp: event.updateTimestamp,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'event_id': eventId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'content': messageContent.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
