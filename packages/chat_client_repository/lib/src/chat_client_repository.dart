import 'dart:developer';

import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';

/// {@template chat_client_repository}
/// Chat client repository
/// {@endtemplate}
class ChatClientRepository {
  /// {@macro chat_client_repository}
  ChatClientRepository({
    required String serverMediaUrl,
    required String serverChatWsUrl,
    required String dbPath,
    required String httpProxy,
  }) : _chatClient = WebsocketChatClient(
          serverChatWsUrl,
          serverMediaUrl,
          dbPath,
          httpProxy,
        ) {
    outChatSocketState.listen((event) {
      _lastSocketState = event.state;
      if (event.state == SocketStateType.socketStateTypeReady) {
        _chatClient.connect();
      }
    });
    outChatError.listen((event) {
      log(
        '[$runtimeType] ${event.message}\n${event.stackTrace}',
      );
    });
    outChatMessages.listen((event) {
      log('[$runtimeType] receive message $event');
    });
  }

  final WebsocketChatClient _chatClient;

  Stream<BaseResponse> get outChatMessages => _chatClient.outMessage;
  Stream<SocketState> get outChatSocketState => _chatClient.outSocketState;
  Stream<ChatError> get outChatError => _chatClient.outError;

  SocketStateType _lastSocketState =
      SocketStateType.socketStateTypeDisconnected;

  UserDetail? _authenticatedUser;
  UserDetail? get authenticatedUser => _authenticatedUser;

  bool get isSocketReady =>
      _lastSocketState == SocketStateType.socketStateTypeReady ||
      _lastSocketState == SocketStateType.socketStateTypeConnected;

  bool get isSocketConnected =>
      _lastSocketState == SocketStateType.socketStateTypeConnected;

  bool get isAuthenticated => authenticatedUser != null;

  Future<UserDetail> authUser({
    required String login,
    required String password,
  }) {
    if (!isSocketConnected) {
      return Future.error(Exception('Not connected to server.'));
    }
    return _chatClient.authUser(login, password).then((value) {
      _authenticatedUser = value.detail;
      return value.detail;
    });
  }

  Future<List<UserDetail>> listUsers() async {
    final result = await _chatClient.listUsers();
    return result.users;
  }

  Future<RoomDetail> createRoom({
    required String title,
    required String? avatar,
    required List<String> memberIds,
  }) async {
    final result = await _chatClient.createRoom(title, avatar, memberIds);
    return result.detail;
  }

  Future<SyncRoomsResponse> smartSyncRooms() async {
    final result = await _chatClient.smartSyncRooms();
    return result;
  }

  Future<List<RoomDetail>> listRooms({
    Set<String> roomIds = const {},
  }) async {
    final result = await _chatClient.listRooms(roomIds);
    return result.detail;
  }

  Future<MediaContent> downloadMedia(String contentId) async {
    final result = await _chatClient.downloadMedia(contentId);
    return result.content;
  }

  Future<SyncRoomsResponse> syncRooms(List<SyncRoomFilter> filters) async {
    final result = await _chatClient.syncRooms(filters);
    return result;
  }

  Future<List<String>> uploadMedia(List<MediaContent> files) async {
    final result = await _chatClient.uploadMedia(files, timeoutMillis: 10000);
    return result.mediaIds;
  }

  Future<RoomEventMessageDetail> addRoomEventMessage(
    String roomId,
    List<String> attachment,
    String content,
    int version,
  ) async {
    final result = await _chatClient.addRoomEventMessage(
      roomId,
      attachment,
      content,
      version,
    );
    return result.detail;
  }
}
