import 'package:equatable/equatable.dart';
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';

class ChatRoomMemberModel extends Equatable {
  const ChatRoomMemberModel({
    required this.userId,
    required this.fullName,
    required this.isOnline,
    this.avatar,
    this.lastReadMarker,
  });

  final String userId;
  final String fullName;
  final bool isOnline;
  final String? avatar;
  final DateTime? lastReadMarker;

  ChatRoomMemberModel copyWith({
    String? fullName,
    bool? isOnline,
    String? avatar,
    DateTime? lastReadMarker,
  }) {
    return ChatRoomMemberModel(
      userId: userId,
      fullName: fullName ?? this.fullName,
      isOnline: isOnline ?? this.isOnline,
      avatar: avatar ?? this.avatar,
      lastReadMarker: lastReadMarker ?? lastReadMarker,
    );
  }

  static ChatRoomMemberModel fromResponse(RoomMemberDetail response) {
    return ChatRoomMemberModel(
      userId: response.userId,
      fullName: response.fullName,
      isOnline: response.isOnline,
      avatar: response.avatar,
      lastReadMarker:
          (response.lastReadMarker == null) ? null : response.lastReadMarker!,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        fullName,
        isOnline,
        avatar,
        lastReadMarker,
      ];
}
