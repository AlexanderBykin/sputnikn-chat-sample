import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:flutter/foundation.dart';
import 'package:sputnikn_chatsample/constants/constants.dart';
import 'package:sputnikn_chatsample/model/room_last_message_model.dart';
import 'chat_room_member_vm.dart';

class ChatRoomVM with ChangeNotifier {
  final String roomId;
  String _title;
  String? _avatar;
  List<ChatRoomMemberVM> _members;
  RoomLastMessageModel? _lastMessage;
  int _eventMessageUnreadCount = 0;
  int _eventSystemUnreadCount = 0;
  DateTime _lastActivity = Constants.defaultLastReadMarkerDate;

  String get title => _title;
  String? get avatar => _avatar;
  List<ChatRoomMemberVM> get members => List.of(_members);
  RoomLastMessageModel? get lastMessage => _lastMessage;
  int get eventMessageUnreadCount => _eventMessageUnreadCount;
  int get eventSystemUnreadCount => _eventSystemUnreadCount;
  DateTime get lastActivity => _lastActivity;

  ChatRoomVM({
    required this.roomId,
    required String title,
    String? avatar,
    required List<ChatRoomMemberVM> members,
    required int eventMessageUnreadCount,
    required int eventSystemUnreadCount,
    DateTime? lastActivity,
  })  : _title = title,
        _avatar = avatar,
        _members = members,
        _eventMessageUnreadCount = eventMessageUnreadCount,
        _eventSystemUnreadCount = eventSystemUnreadCount,
        _lastActivity = lastActivity ?? Constants.defaultLastReadMarkerDate;

  void update({
    String? title,
    String? avatar,
    List<ChatRoomMemberVM>? members,
    RoomLastMessageModel? lastMessage,
    int? eventMessageUnreadCount,
    int? eventSystemUnreadCount,
  }) {
    if (_title != _title ||
        _avatar != avatar ||
        _members != members ||
        _lastMessage != lastMessage ||
        _eventMessageUnreadCount != eventMessageUnreadCount ||
        _eventSystemUnreadCount != eventSystemUnreadCount) {
      _lastActivity = DateTime.now();
    }
    _title = title ?? _title;
    _avatar = avatar ?? _avatar;
    _members = members ?? _members;
    _lastMessage = lastMessage ?? _lastMessage;
    _eventMessageUnreadCount =
        eventMessageUnreadCount ?? _eventMessageUnreadCount;
    _eventSystemUnreadCount = eventSystemUnreadCount ?? _eventSystemUnreadCount;
    notifyListeners();
  }

  static ChatRoomVM fromResponse(
    RoomDetail response, [
    DateTime? lastActivity,
  ]) {
    return ChatRoomVM(
      roomId: response.roomId,
      title: response.title,
      avatar: response.avatar,
      members: response.members
          .map((e) => ChatRoomMemberVM.fromResponse(e))
          .toList(),
      eventMessageUnreadCount: response.eventMessageUnreadCount,
      eventSystemUnreadCount: response.eventSystemUnreadCount,
      lastActivity: lastActivity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatRoomVM &&
          runtimeType == other.runtimeType &&
          hashCode == other.hashCode;

  @override
  int get hashCode => roomId.hashCode ^ (lastMessage?.hashCode ?? 0);
}
