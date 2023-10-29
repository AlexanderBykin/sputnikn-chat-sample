import 'package:flutter/material.dart';
import 'package:sputnikn_chat_client/model/response/responses.dart';
import 'package:sputnikn_chatsample/pages/chat_create/view/widget/chat_member_item_widget.dart';

class ChatMemberList extends StatelessWidget {
  const ChatMemberList({
    required this.selectedMemberIds,
    required this.members,
    required this.onUserTap,
    super.key,
  });

  final List<String> selectedMemberIds;
  final List<UserDetail> members;
  final ValueChanged<UserDetail> onUserTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (_, itemIndex) {
        return ChatMemberItemWidget(
          member: members[itemIndex],
          isSelected: selectedMemberIds.any(
            (e) => members[itemIndex].userId == e,
          ),
          onItemTap: onUserTap,
        );
      },
    );
  }
}
