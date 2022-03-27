import 'package:chat_client_repository/chat_client_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:sputnikn_chatsample/core/core.dart';
import 'package:sputnikn_chatsample/screens/chat_list/models/models.dart';

class ChatRoomModel extends Equatable {
  ChatRoomModel({
    required this.roomId,
    required this.title,
    this.avatar,
    this.members = const [],
    this.lastMessage,
    this.eventMessageUnreadCount = 0,
    this.eventSystemUnreadCount = 0,
    DateTime? lastActivity,
  }) : lastActivity = lastActivity ?? AppParams.defaultLastReadMarkerDate;

  final String roomId;
  final String title;
  final String? avatar;
  final List<ChatRoomMemberModel> members;
  final RoomLastMessageModel? lastMessage;
  final int eventMessageUnreadCount;
  final int eventSystemUnreadCount;
  final DateTime lastActivity;

  ChatRoomModel copyWith({
    String? title,
    String? avatar,
    List<ChatRoomMemberModel>? members,
    RoomLastMessageModel? lastMessage,
    int? eventMessageUnreadCount,
    int? eventSystemUnreadCount,
  }) {
    return ChatRoomModel(
      roomId: roomId,
      title: title ?? this.title,
      avatar: avatar ?? this.avatar,
      members: members??this.members,
      lastMessage: lastMessage??this.lastMessage,
      eventMessageUnreadCount: eventMessageUnreadCount ?? this.eventMessageUnreadCount,
      eventSystemUnreadCount: eventSystemUnreadCount??this.eventSystemUnreadCount,
      lastActivity: DateTime.now(),
    );
  }

  static ChatRoomModel fromResponse(
    RoomDetail response, [
    DateTime? lastActivity,
  ]) {
    return ChatRoomModel(
      roomId: response.roomId,
      title: response.title,
      avatar: response.avatar,
      members: response.members.map(ChatRoomMemberModel.fromResponse).toList(),
      eventMessageUnreadCount: response.eventMessageUnreadCount,
      eventSystemUnreadCount: response.eventSystemUnreadCount,
      lastActivity: lastActivity ?? AppParams.defaultLastReadMarkerDate,
    );
  }

  @override
  List<Object?> get props => [
        roomId,
        title,
        avatar,
        members,
        lastMessage,
        eventMessageUnreadCount,
        eventSystemUnreadCount,
        lastActivity,
      ];
}
