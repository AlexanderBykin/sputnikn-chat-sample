import 'package:sputnikn_chatsample/screens/chat_list/chat_room_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputnikn_chatsample/screens/widgets/user_avatar.dart';

typedef OnChatItemTap = Function(String);

class ChatListItemWidget extends StatelessWidget {
  final _avatarSize = 40.0;
  final OnChatItemTap onChatItemTap;

  const ChatListItemWidget({
    required this.onChatItemTap,
    Key? key,
  }) : super(key: key);

  static Widget builder(ChatRoomVM viewModel, OnChatItemTap onChatItemTap) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      builder: (_, __) => ChatListItemWidget(
        onChatItemTap: onChatItemTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatRoomVM>(
      builder: (_, viewModel, __) {
        final memberChars = viewModel.members
            .take(2)
            .map((e) => e.fullName.characters.first.toUpperCase())
            .toList()
            .join();
        return ListTile(
          onTap: () {
            onChatItemTap(viewModel.roomId);
          },
          tileColor: Colors.transparent,
          leading: UserAvatar(
            userName: memberChars,
            avatarPath: viewModel.avatar,
            avatarSize: _avatarSize,
          ),
          title: Text(
            viewModel.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(viewModel.lastMessage?.message.content ?? ""),
          trailing: _unreadCount(viewModel.eventMessageUnreadCount),
        );
      },
    );
  }

  Widget _unreadCount(int unreadCount) {
    final unreadString = (unreadCount > 99) ? "99+" : unreadCount.toString();
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
