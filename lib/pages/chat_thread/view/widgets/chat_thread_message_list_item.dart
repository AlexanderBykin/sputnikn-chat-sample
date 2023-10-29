import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sputnikn_chat_client/model/response/responses.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/models/models.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/view/widgets/widgets.dart';

class ChatThreadMessageListItem extends StatelessWidget {
  const ChatThreadMessageListItem({
    required this.model,
    required this.currentUser,
    required this.onActionTap,
    required this.onDownloadMedia,
    required this.onOpenImagePreviewTap,
    super.key,
  });

  final ChatThreadUIMessageModelBase model;
  final UserDetail? currentUser;
  final ValueChanged<ChatThreadUIEventMessage> onActionTap;
  final Future<Uint8List> Function(String) onDownloadMedia;
  final ValueChanged<Uint8List> onOpenImagePreviewTap;

  @override
  Widget build(BuildContext context) {
    if (model is ChatThreadUIEventMessage) {
      final isMyMessage =
          (model as ChatThreadUIEventMessage).senderId == currentUser?.userId;
      if (isMyMessage) {
        return ChatThreadMyMessage(
          model: model as ChatThreadUIEventMessage,
          onActionTap: onActionTap,
          onDownloadMedia: onDownloadMedia,
          onOpenImagePreviewTap: onOpenImagePreviewTap,
        );
      } else {
        return ChatThreadOtherMessage(
          model: model as ChatThreadUIEventMessage,
          onActionTap: onActionTap,
          onDownloadMedia: onDownloadMedia,
          onOpenImagePreviewTap: onOpenImagePreviewTap,
        );
      }
    } else if (model is ChatThreadUIEventSystem) {
      return ChatThreadSystemMessage(
        model: model as ChatThreadUIEventSystem,
      );
    } else if (model is ChatThreadUIEventUnread) {
      return ChatThreadUnreadMessage(
        model: model as ChatThreadUIEventUnread,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
