part of 'chat_create_bloc.dart';

@immutable
abstract class ChatCreateEvent {}

class FetchUsersSubmitted extends ChatCreateEvent {}

class ChangeRoomNameSubmitted extends ChatCreateEvent {
  ChangeRoomNameSubmitted(this.roomName);

  final String roomName;
}

class MemberChangeSelectionSubmitted extends ChatCreateEvent {
  MemberChangeSelectionSubmitted(this.member);

  final UserDetail member;
}

class CreateChatSubmitted extends ChatCreateEvent {}
