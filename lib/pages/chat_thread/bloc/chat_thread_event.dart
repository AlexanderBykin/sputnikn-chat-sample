part of 'chat_thread_bloc.dart';

@immutable
abstract class ChatThreadEvent {}

class FetchChatDetailSubmitted extends ChatThreadEvent {}

class SyncChatMessagesSubmitted extends ChatThreadEvent {
  SyncChatMessagesSubmitted({
    this.lastMessageTimestamp,
  });

  final DateTime? lastMessageTimestamp;
}

class ReceiveChatMessageSubmitted extends ChatThreadEvent {
  ReceiveChatMessageSubmitted(this.message);

  final ChatThreadUIMessageModelBase message;
}

class ReceiveChatDetailSubmitted extends ChatThreadEvent {
  ReceiveChatDetailSubmitted(this.roomDetail);

  final RoomDetail roomDetail;
}

class ChangeScrollPositionSubmitted extends ChatThreadEvent {
  ChangeScrollPositionSubmitted(this.position);

  final Iterable<ItemPosition> position;
}

class AddNewChatMessageSubmitted extends ChatThreadEvent {
  AddNewChatMessageSubmitted(
    this.message,
    this.attachments,
  );

  final EventMessageContentModelV1 message;
  final List<MediaFileModel> attachments;
}

class EventOpenChatMessageAction {
  EventOpenChatMessageAction({
    required this.message,
    required this.isMyMessage,
    required this.onDownloadMedia,
    required this.onForward,
    required this.onReply,
    required this.onCopy,
    required this.onDelete,
  });

  final ChatThreadUIEventMessage message;
  final bool isMyMessage;
  final Future<Uint8List> Function(String) onDownloadMedia;
  final VoidCallback onForward;
  final VoidCallback onReply;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
}
