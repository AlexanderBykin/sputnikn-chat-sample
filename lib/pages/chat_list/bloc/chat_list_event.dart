part of 'chat_list_bloc.dart';

abstract class ChatListEvent {}

class FetchRoomListSubmitted extends ChatListEvent {}

class ChangeRoomSubmitted extends ChatListEvent {
  ChangeRoomSubmitted(this.room);

  final ChatRoomModel room;
}

class NewRoomSubmitted extends ChatListEvent {
  NewRoomSubmitted(this.room);

  final ChatRoomModel room;
}
