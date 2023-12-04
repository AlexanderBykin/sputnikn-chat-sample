part of 'chat_login_bloc.dart';

@immutable
abstract class ChatLoginEvent {}

class ChangeLoginSubmitted extends ChatLoginEvent {
  ChangeLoginSubmitted(this.login);

  final String login;
}

class ChangePasswordSubmitted extends ChatLoginEvent {
  ChangePasswordSubmitted(this.password);

  final String password;
}

class SignInSubmitted extends ChatLoginEvent {}
