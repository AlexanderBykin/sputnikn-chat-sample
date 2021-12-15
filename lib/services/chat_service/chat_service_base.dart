import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';

abstract class ChatServiceBase {
  Stream<BaseResponse> get outChatMessages;
  Stream<SocketState> get outChatSocketState;
  Stream<ChatError> get outChatError;

  UserDetail? get authenticatedUser;

  bool get isSocketReady;

  bool get isSocketConnected ;

  bool get isAuthenticated ;

  WebsocketChatClient get chatClient ;

  Future<UserDetail?> authUser(String login, String password);
}