import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:flutter/foundation.dart';

class ChatRoomMemberVM with ChangeNotifier {
  final String userId;
  String _fullName;
  bool _isOnline;
  String? _avatar;
  DateTime? _lastReadMarker;

  String get fullName => _fullName;
  bool get isOnline => _isOnline;
  String? get avatar => _avatar;
  DateTime? get lastReadMarker => _lastReadMarker;

  ChatRoomMemberVM(
    this.userId,
    String fullName,
    bool isOnline,
    String? avatar,
    DateTime? lastReadMarker,
  )   : _fullName = fullName,
        _isOnline = isOnline,
        _avatar = avatar,
        _lastReadMarker = lastReadMarker;

  void update({
    String? fullName,
    bool? isOnline,
    String? avatar,
    DateTime? lastReadMarker,
  }) {
    _fullName = fullName ?? _fullName;
    _isOnline = isOnline ?? _isOnline;
    _avatar = avatar ?? _avatar;
    _lastReadMarker = lastReadMarker ?? _lastReadMarker;
    notifyListeners();
  }

  static ChatRoomMemberVM fromResponse(RoomMemberDetail response) {
    return ChatRoomMemberVM(
      response.userId,
      response.fullName,
      response.isOnline,
      response.avatar,
      (response.lastReadMarker == null) ? null : response.lastReadMarker!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatRoomMemberVM &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}
