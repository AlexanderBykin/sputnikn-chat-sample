import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sputnikn_chat_client/model/response/responses.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/models/models.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/view/widgets/chat_thread_message_list_item.dart';

class ChatThreadMessageList extends StatelessWidget {
  const ChatThreadMessageList({
    required this.currentUser,
    required this.messages,
    required this.firstMessageBottomPadding,
    required this.scrollController,
    required this.positionsListener,
    required this.onActionTap,
    required this.onDownloadMedia,
    required this.onOpenImagePreviewTap,
    super.key,
  });

  final UserDetail? currentUser;
  final List<ChatThreadUIMessageModelBase> messages;
  final double firstMessageBottomPadding;
  final ItemScrollController scrollController;
  final ItemPositionsListener positionsListener;
  final ValueChanged<ChatThreadUIEventMessage> onActionTap;
  final Future<Uint8List> Function(String) onDownloadMedia;
  final ValueChanged<Uint8List> onOpenImagePreviewTap;

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.builder(
      itemScrollController: scrollController,
      itemPositionsListener: positionsListener,
      reverse: true,
      itemCount: messages.length,
      minCacheExtent: 50,
      itemBuilder: (_, itemIndex) {
        final msgItem = messages[itemIndex];
        if (itemIndex == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: firstMessageBottomPadding),
            child: ChatThreadMessageListItem(
              key: ObjectKey(msgItem),
              currentUser: currentUser,
              model: msgItem,
              onActionTap: onActionTap,
              onDownloadMedia: onDownloadMedia,
              onOpenImagePreviewTap: onOpenImagePreviewTap,
            ),
          );
        }
        return ChatThreadMessageListItem(
          key: ObjectKey(msgItem),
          currentUser: currentUser,
          model: msgItem,
          onActionTap: onActionTap,
          onDownloadMedia: onDownloadMedia,
          onOpenImagePreviewTap: onOpenImagePreviewTap,
        );
      },
    );
  }
}
