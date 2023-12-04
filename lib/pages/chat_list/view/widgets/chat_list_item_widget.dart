import 'package:flutter/material.dart';
import 'package:sputnikn_chatsample/core/core.dart';
import 'package:sputnikn_chatsample/pages/chat_list/models/models.dart';

class ChatListItemWidget extends StatelessWidget {
  const ChatListItemWidget({
    required this.room,
    required this.onChatItemTap,
    super.key,
  });

  final VoidCallback onChatItemTap;
  final ChatRoomModel room;

  @override
  Widget build(BuildContext context) {
    final memberChars = room.members
        .take(2)
        .map((e) => e.fullName.characters.first.toUpperCase())
        .toList()
        .join();
    return ListTile(
      onTap: onChatItemTap,
      tileColor: Colors.transparent,
      leading: UserAvatar(
        userName: memberChars,
        avatarPath: room.avatar,
      ),
      title: Text(
        room.title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(room.lastMessage?.message.content ?? ''),
      trailing: room.eventMessageUnreadCount <= 0
          ? null
          : UnreadCounter(unreadCount: room.eventMessageUnreadCount),
    );
  }
}
