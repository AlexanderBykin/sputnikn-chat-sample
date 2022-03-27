import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sputnikn_chatsample/core/core.dart';
import 'package:sputnikn_chatsample/screens/chat_thread/models/models.dart';
import 'package:sputnikn_chatsample/screens/chat_thread/view/widgets/widgets.dart';

class ChatThreadOtherMessage extends StatefulWidget {
  const ChatThreadOtherMessage({
    required this.model,
    required this.onActionTap,
    required this.onDownloadMedia,
    required this.onOpenImagePreviewTap,
    Key? key,
  }) : super(key: key);

  final ChatThreadUIEventMessage model;
  final Function(ChatThreadUIEventMessage)? onActionTap;
  final Future<Uint8List> Function(String) onDownloadMedia;
  final Function(Uint8List) onOpenImagePreviewTap;

  @override
  State<ChatThreadOtherMessage> createState() => _ChatThreadOtherMessageState();
}

class _ChatThreadOtherMessageState extends State<ChatThreadOtherMessage> {
  final _avatarSize = 40.0;
  final _dateFormat = DateFormat.Hm();

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
          mainAxisAlignment: MainAxisAlignment.start,
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
                Flexible(child: _messageContent()),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _messageContent() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        color: Palette.color1,
      ),
      padding: const EdgeInsets.only(
        left: 8,
        top: 8,
        right: 8,
        bottom: 4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _contentAttachment(),
          Text(
            widget.model.messageContent.content,
            softWrap: true,
          ),
          Text(
            _dateFormat.format(widget.model.timestamp),
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentAttachment() {
    return Visibility(
      visible: widget.model.attachment.isNotEmpty,
      child: SizedBox(
        height: 200,
        child: ChatThreadMessageAttachment(
          attachments: widget.model.attachment,
          onDownloadAttachment: widget.onDownloadMedia,
          onOpenImagePreviewTap: widget.onOpenImagePreviewTap,
        ),
      ),
    );
  }
}
