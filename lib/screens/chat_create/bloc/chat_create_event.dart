part of 'chat_create_bloc.dart';

@immutable
abstract class ChatCreateEvent {}

class FetchUsersSubmitted extends ChatCreateEvent {}

class MemberChangeSelectionSubmitted extends ChatCreateEvent {
  MemberChangeSelectionSubmitted(this.member);

  final UserDetail member;
}

class CreateChatSubmitted extends ChatCreateEvent {
  CreateChatSubmitted({
    required this.title,
    this.avatar,
  });

  final String title;
  final String? avatar;
}
