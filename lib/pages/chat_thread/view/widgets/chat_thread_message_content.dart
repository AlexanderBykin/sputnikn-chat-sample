import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:sputnikn_chatsample/core/core.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/models/models.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/view/widgets/chat_thread_message_attachment.dart';

typedef TMsgContentDownloadMedia = Future<Uint8List> Function(String);
typedef TMsgContentOpenImagePreviewTap = ValueChanged<Uint8List>;

class ChatThreadMessageContent extends StatelessWidget {
  const ChatThreadMessageContent({
    required this.isMyMessage,
    required this.model,
    required this.onDownloadMedia,
    required this.onOpenImagePreviewTap,
    super.key,
  });

  final bool isMyMessage;
  final ChatThreadUIEventMessage model;
  final TMsgContentDownloadMedia onDownloadMedia;
  final TMsgContentOpenImagePreviewTap onOpenImagePreviewTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: isMyMessage ? const Radius.circular(10) : Radius.zero,
          topRight: isMyMessage ? Radius.zero : const Radius.circular(10),
          bottomLeft: const Radius.circular(10),
          bottomRight: const Radius.circular(10),
        ),
        color: isMyMessage ? Palette.color4 : Palette.color1,
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
          if (model.attachment.isNotEmpty)
            _MessageContentAttachment(
              attachment: model.attachment,
              onDownloadMedia: onDownloadMedia,
              onOpenImagePreviewTap: onOpenImagePreviewTap,
            ),
          Text(
            model.messageContent.content,
            softWrap: true,
          ),
          Text(
            DateFormatter.dateFormatHm.format(model.timestamp),
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageContentAttachment extends StatelessWidget {
  const _MessageContentAttachment({
    required this.attachment,
    required this.onDownloadMedia,
    required this.onOpenImagePreviewTap,
    super.key,
  });

  final List<ChatAttachmentDetail> attachment;
  final TMsgContentDownloadMedia onDownloadMedia;
  final TMsgContentOpenImagePreviewTap onOpenImagePreviewTap;

  @override
  Widget build(BuildContext content) {
    return SizedBox(
      height: 200,
      child: ChatThreadMessageAttachment(
        attachments: attachment,
        onDownloadAttachment: onDownloadMedia,
        onOpenImagePreviewTap: onOpenImagePreviewTap,
      ),
    );
  }
}
