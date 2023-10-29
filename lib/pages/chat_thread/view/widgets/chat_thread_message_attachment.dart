import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:sputnikn_chatsample/core/themes/palette.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/view/widgets/chat_thread_other_message.dart';

typedef TAttachmentDownloadAttachment = Future<Uint8List> Function(String);
typedef TAttachmentOpenImagePreviewTap = ValueChanged<Uint8List>;

class ChatThreadMessageAttachment extends StatefulWidget {
  const ChatThreadMessageAttachment({
    required this.attachments,
    required this.onDownloadAttachment,
    required this.onOpenImagePreviewTap,
    super.key,
  });

  final List<ChatAttachmentDetail> attachments;
  final TAttachmentDownloadAttachment onDownloadAttachment;
  final TAttachmentOpenImagePreviewTap onOpenImagePreviewTap;

  @override
  State<StatefulWidget> createState() {
    return _ChatThreadMessageAttachmentState();
  }
}

class _ChatThreadMessageAttachmentState
    extends State<ChatThreadMessageAttachment> {
  @override
  Widget build(BuildContext context) {
    if (widget.attachments.isEmpty) {
      return const SizedBox.shrink();
    }
    if (widget.attachments.length == 1) {
      return _MediaChildContainer(
        attachment: widget.attachments.first,
        onDownloadAttachment: widget.onDownloadAttachment,
        onOpenImagePreviewTap: widget.onOpenImagePreviewTap,
      );
    } else if (widget.attachments.length == 2) {
      return Row(
        children: [
          Expanded(
            child: _MediaChildContainer(
              attachment: widget.attachments.first,
              onDownloadAttachment: widget.onDownloadAttachment,
              onOpenImagePreviewTap: widget.onOpenImagePreviewTap,
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            child: _MediaChildContainer(
              attachment: widget.attachments.last,
              onDownloadAttachment: widget.onDownloadAttachment,
              onOpenImagePreviewTap: widget.onOpenImagePreviewTap,
            ),
          ),
        ],
      );
    } else {
      final firstThree = widget.attachments.take(3);
      final other = widget.attachments.skip(3);
      return Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _MediaChildContainer(
                    attachment: firstThree.elementAt(0),
                    onDownloadAttachment: widget.onDownloadAttachment,
                    onOpenImagePreviewTap: widget.onOpenImagePreviewTap,
                  ),
                ),
                const SizedBox(height: 1),
                Expanded(
                  child: _MediaChildContainer(
                    attachment: firstThree.elementAt(1),
                    onDownloadAttachment: widget.onDownloadAttachment,
                    onOpenImagePreviewTap: widget.onOpenImagePreviewTap,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            child: _MediaChildContainer(
              attachment: firstThree.elementAt(2),
              overlayAmount: other.length,
              onDownloadAttachment: widget.onDownloadAttachment,
              onOpenImagePreviewTap: widget.onOpenImagePreviewTap,
            ),
          ),
        ],
      );
    }
  }
}

class _MediaChildContainer extends StatelessWidget {
  const _MediaChildContainer({
    required this.attachment,
    required this.onDownloadAttachment,
    required this.onOpenImagePreviewTap,
    this.overlayAmount = 0,
    super.key,
  });

  final ChatAttachmentDetail attachment;
  final int overlayAmount;
  final TAttachmentDownloadAttachment onDownloadAttachment;
  final TAttachmentOpenImagePreviewTap onOpenImagePreviewTap;

  @override
  Widget build(BuildContext context) {
    Widget? result;
    if (attachment.mimeType.startsWith('image')) {
      result = FutureBuilder<Uint8List>(
        future: onDownloadAttachment(attachment.attachmentId),
        builder: (_, snapshot) {
          final data = snapshot.data ?? Uint8List(0);
          return InkWell(
            onTap: () {
              onOpenImagePreviewTap(data);
            },
            child: _imageWidget(data),
          );
        },
      );
    }
    return SizedBox(
      key: ValueKey(attachment.attachmentId),
      child: (result != null && overlayAmount > 0)
          ? Stack(
              fit: StackFit.expand,
              children: [
                result,
                Container(
                  color: Colors.white.withOpacity(0.5),
                  alignment: Alignment.center,
                  child: Text(
                    '$overlayAmount+',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Palette.color1,
                    ),
                  ),
                )
              ],
            )
          : result,
    );
  }

  Widget _imageWidget(Uint8List data) {
    return data.isNotEmpty
        ? SizedBox.expand(
            child: Image(
              image: MemoryImage(data),
              fit: BoxFit.cover,
            ),
          )
        : const SizedBox.shrink();
  }
}
