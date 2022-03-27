import 'package:chat_client_repository/chat_client_repository.dart';
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:sputnikn_chatsample/screens/chat_thread/models/models.dart';

class ChatThreadUIEventSystem extends ChatThreadUIMessageModelBase {
  const ChatThreadUIEventSystem({
    required String eventId,
    required this.messageContent,
    required DateTime timestamp,
  }) : super(eventId, timestamp);

  final EventSystemContentModelV1 messageContent;

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

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'event_id': eventId,
      'content': messageContent.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
