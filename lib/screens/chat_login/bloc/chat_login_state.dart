part of 'chat_login_bloc.dart';

enum ChatLoginAuthStatus {
  success,
  failed,
}

enum ChatLoginLoadingStatus {
  loading,
  success,
  failed,
}

@immutable
class ChatLoginState extends Equatable {
  const ChatLoginState({
    required this.login,
    required this.password,
    this.loadingStatus = ChatLoginLoadingStatus.success,
    this.authStatus = ChatLoginAuthStatus.failed,
  });

  final String login;
  final String password;
  final ChatLoginLoadingStatus loadingStatus;
  final ChatLoginAuthStatus authStatus;

  ChatLoginState copyWith({
    String? login,
    String? password,
    ChatLoginLoadingStatus? loadingStatus,
    ChatLoginAuthStatus? authStatus,
  }) {
    return ChatLoginState(
      login: login ?? this.login,
      password: password ?? this.password,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      authStatus: authStatus ?? this.authStatus,
    );
  }

  @override
  List<Object?> get props => [
        login,
        password,
        loadingStatus,
      ];
}
