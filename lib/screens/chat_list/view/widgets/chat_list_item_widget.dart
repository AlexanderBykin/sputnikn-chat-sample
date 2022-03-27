import 'package:flutter/material.dart';
import 'package:sputnikn_chatsample/core/widgets/user_avatar.dart';
import 'package:sputnikn_chatsample/screens/chat_list/models/models.dart';

class ChatListItemWidget extends StatelessWidget {
  const ChatListItemWidget({
    required this.room,
    required this.onChatItemTap,
    Key? key,
  }) : super(key: key);

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
      trailing: _unreadCount(room.eventMessageUnreadCount),
    );
  }

  Widget _unreadCount(int unreadCount) {
    final unreadString = (unreadCount > 99) ? '99+' : unreadCount.toString();
    return Visibility(
      visible: unreadCount > 0,
      child: Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Text(
          unreadString,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
