part of 'chat_thread_bloc.dart';

enum ChatThreadLoadingStatus {
  loading,
  success,
  failed,
}

@immutable
class ChatThreadState extends Equatable {
  const ChatThreadState({
    required this.chatId,
    this.messages = const [],
    this.chatDetail,
    this.unreadMarkerIndex = -1,
    this.lastUnreadTime,
    this.loadingStatus = ChatThreadLoadingStatus.success,
  });

  final String chatId;
  final List<ChatThreadUIMessageModelBase> messages;
  final RoomDetail? chatDetail;
  final int unreadMarkerIndex;
  final DateTime? lastUnreadTime;
  final ChatThreadLoadingStatus loadingStatus;

  ChatThreadState copyWith({
    List<ChatThreadUIMessageModelBase>? messages,
    RoomDetail? chatDetail,
    int? unreadMarkerIndex,
    DateTime? lastUnreadTime,
    ChatThreadLoadingStatus? loadingStatus,
  }) {
    return ChatThreadState(
      chatId: chatId,
      messages: messages?.toList() ?? this.messages,
      chatDetail: chatDetail ?? this.chatDetail,
      unreadMarkerIndex: unreadMarkerIndex ?? this.unreadMarkerIndex,
      lastUnreadTime: lastUnreadTime ?? this.lastUnreadTime,
      loadingStatus: loadingStatus ?? this.loadingStatus,
    );
  }

  @override
  List<Object?> get props => [
        chatId,
        chatDetail,
        messages,
        unreadMarkerIndex,
      ];
}
