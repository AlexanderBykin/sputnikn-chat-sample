part of 'chat_list_bloc.dart';

enum ChatListLoadingStatus {
  loading,
  success,
  failed,
}

@immutable
class ChatListState extends Equatable {
  const ChatListState({
    this.rooms = const [],
    this.loadingStatus = ChatListLoadingStatus.success,
  });

  final List<ChatRoomModel> rooms;
  final ChatListLoadingStatus loadingStatus;

  ChatListState copyWith({
    List<ChatRoomModel>? rooms,
    ChatListLoadingStatus? loadingStatus,
  }) {
    return ChatListState(
      rooms: rooms ?? this.rooms,
      loadingStatus: loadingStatus ?? this.loadingStatus,
    );
  }

  @override
  List<Object?> get props => [
        rooms,
      ];
}

extension RoomListExtension on List<ChatRoomModel> {
  void sortRooms() {
    sort((roomA, roomB) {
      return roomB.lastActivity.compareTo(roomA.lastActivity);
    });
  }
}
