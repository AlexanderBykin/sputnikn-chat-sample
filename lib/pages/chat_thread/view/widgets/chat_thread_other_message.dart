import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sputnikn_chatsample/core/core.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/models/models.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/view/widgets/widgets.dart';

typedef TOtherMsgDownloadMedia = Future<Uint8List> Function(String);
typedef TOtherMsgOpenImagePreviewTap = ValueChanged<Uint8List>;

class ChatThreadOtherMessage extends StatefulWidget {
  const ChatThreadOtherMessage({
    required this.model,
    required this.onActionTap,
    required this.onDownloadMedia,
    required this.onOpenImagePreviewTap,
    super.key,
  });

  final ChatThreadUIEventMessage model;
  final ValueChanged<ChatThreadUIEventMessage>? onActionTap;
  final TOtherMsgDownloadMedia onDownloadMedia;
  final TOtherMsgOpenImagePreviewTap onOpenImagePreviewTap;

  @override
  State<ChatThreadOtherMessage> createState() => _ChatThreadOtherMessageState();
}

class _ChatThreadOtherMessageState extends State<ChatThreadOtherMessage> {
  final _avatarSize = 40.0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      onLongPress: () {
        widget.onActionTap?.call(widget.model);
      },
      child: Padding(
        padding: EdgeInsets.only(
          right: _avatarSize + 16.0,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: _avatarSize + 16.0,
              ),
              child: Text(widget.model.senderName),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: UserAvatar(
                    userName: widget.model.senderName,
                    avatarPath: widget.model.senderAvatar,
                    avatarSize: _avatarSize,
                  ),
                ),
                Flexible(
                  child: ChatThreadMessageContent(
                    isMyMessage: false,
                    model: widget.model,
                    onDownloadMedia: widget.onDownloadMedia,
                    onOpenImagePreviewTap: widget.onOpenImagePreviewTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
