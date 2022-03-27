import 'package:sputnikn_chatsample/screens/chat_thread/models/models.dart';

class ChatThreadUIEventUnread extends ChatThreadUIMessageModelBase {
  const ChatThreadUIEventUnread({
    required DateTime timestamp,
  }) : super(keyEventId, timestamp);

  static const keyEventId = 'unread_marker';

  static ChatThreadUIEventUnread fromUnread(DateTime unreadTimestamp) {
    return ChatThreadUIEventUnread(timestamp: unreadTimestamp);
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'event_id': eventId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
