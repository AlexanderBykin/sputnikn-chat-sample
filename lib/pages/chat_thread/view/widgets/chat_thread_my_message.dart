import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sputnikn_chatsample/core/core.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/models/models.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/view/widgets/widgets.dart';

class ChatThreadMyMessage extends StatefulWidget {
  const ChatThreadMyMessage({
    required this.model,
    required this.onActionTap,
    required this.onDownloadMedia,
    required this.onOpenImagePreviewTap,
    super.key,
  });

  final ChatThreadUIEventMessage model;
  final ValueChanged<ChatThreadUIEventMessage>? onActionTap;
  final Future<Uint8List> Function(String) onDownloadMedia;
  final ValueChanged<Uint8List> onOpenImagePreviewTap;

  @override
  State<ChatThreadMyMessage> createState() => _ChatThreadMyMessageState();
}

class _ChatThreadMyMessageState extends State<ChatThreadMyMessage> {
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
          left: _avatarSize + 16.0,
          top: 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: _avatarSize + 16.0,
              ),
              child: Text(
                widget.model.senderName,
                textAlign: TextAlign.end,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: ChatThreadMessageContent(
                    isMyMessage: true,
                    model: widget.model,
                    onDownloadMedia: widget.onDownloadMedia,
                    onOpenImagePreviewTap: widget.onOpenImagePreviewTap,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: UserAvatar(
                    userName: widget.model.senderName,
                    avatarPath: widget.model.senderAvatar,
                    avatarSize: _avatarSize,
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
