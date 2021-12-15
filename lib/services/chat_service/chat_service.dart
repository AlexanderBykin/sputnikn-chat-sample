import 'package:flutter/widgets.dart';
import 'package:sputnikn_chatsample/di/app_config.dart';
import 'package:sputnikn_chatsample/services/chat_service/chat_service_base.dart';
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';

class ChatService implements ChatServiceBase {
  final WebsocketChatClient _chatClient;

  @override
  Stream<BaseResponse> get outChatMessages => _chatClient.outMessage;
  @override
  Stream<SocketState> get outChatSocketState => _chatClient.outSocketState;
  @override
  Stream<ChatError> get outChatError => _chatClient.outError;

  SocketStateType _lastSocketState =
      SocketStateType.socketStateTypeDisconnected;

  UserDetail? _authenticatedUser;
  @override
  UserDetail? get authenticatedUser => _authenticatedUser;

  @override
  bool get isSocketReady =>
      _lastSocketState == SocketStateType.socketStateTypeReady ||
      _lastSocketState == SocketStateType.socketStateTypeConnected;

  @override
  bool get isSocketConnected =>
      _lastSocketState == SocketStateType.socketStateTypeConnected;

  @override
  bool get isAuthenticated => authenticatedUser != null;

  @override
  WebsocketChatClient get chatClient => _chatClient;

  ChatService({
    required AppConfig appConfig,
    required WebsocketChatClient chatClient,
  }) : _chatClient = chatClient {
    outChatSocketState.listen((event) {
      _lastSocketState = event.state;
      if (event.state == SocketStateType.socketStateTypeReady) {
        _chatClient.connect();
      }
    });
    outChatError.listen((event) {
      debugPrint(
        "[$runtimeType] ${event.message}\n${event.stackTrace}",
        wrapWidth: 1000,
      );
    });
    outChatMessages.listen((event) {
      debugPrint(">>> [$runtimeType] receive message $event");
    });
  }

  @override
  Future<UserDetail> authUser(String login, String password) {
    if (!isSocketConnected) {
      return Future.error(Exception("Not connected to server."));
    }
    return _chatClient.authUser(login, password).then((value) {
      _authenticatedUser = value.detail;
      return value.detail;
    });
  }
}
