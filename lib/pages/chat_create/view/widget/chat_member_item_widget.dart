import 'package:flutter/material.dart';
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:sputnikn_chatsample/core/widgets/user_avatar.dart';

class ChatMemberItemWidget extends StatelessWidget {
  const ChatMemberItemWidget({
    required this.member,
    required this.isSelected,
    required this.onItemTap,
    Key? key,
  }) : super(key: key);

  final UserDetail member;
  final bool isSelected;
  final ValueChanged<UserDetail> onItemTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(
        userName: member.fullName,
        avatarPath: member.avatar,
      ),
      title: Text(
        member.fullName,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (value) {
          onItemTap(member);
        },
      ),
    );
  }
}
