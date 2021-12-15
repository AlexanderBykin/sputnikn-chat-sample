import 'dart:typed_data';
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:flutter/material.dart';
import 'package:sputnikn_chatsample/constants/palette.dart';

class ChatThreadMessageAttachment extends StatefulWidget {
  final List<ChatAttachmentDetail> attachments;
  final Future<Uint8List> Function(String) onDownloadAttachment;
  final Function(Uint8List) onOpenImagePreviewTap;

  const ChatThreadMessageAttachment({
    required this.attachments,
    required this.onDownloadAttachment,
    required this.onOpenImagePreviewTap,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChatThreadMessageAttachmentState();
  }
}

class _ChatThreadMessageAttachmentState
    extends State<ChatThreadMessageAttachment> {
  @override
  Widget build(BuildContext context) {
    return _mediaParentContainer();
  }

  Widget _mediaParentContainer() {
    if (widget.attachments.isEmpty) {
      return const SizedBox(width: 0, height: 0);
    }
    if (widget.attachments.length == 1) {
      return _mediaChildContainer(widget.attachments.first);
    } else if (widget.attachments.length == 2) {
      return Row(
        children: [
          Expanded(
            child: _mediaChildContainer(widget.attachments.first),
          ),
          const SizedBox(width: 1),
          Expanded(
            child: _mediaChildContainer(widget.attachments.last),
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
                  child: _mediaChildContainer(firstThree.elementAt(0)),
                ),
                const SizedBox(height: 1),
                Expanded(
                  child: _mediaChildContainer(firstThree.elementAt(1)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            child: _mediaChildContainer(
              firstThree.elementAt(2),
              overlayAmount: other.length,
            ),
          ),
        ],
      );
    }
  }

  Widget _mediaChildContainer(
    ChatAttachmentDetail attachment, {
    int overlayAmount = 0,
  }) {
    Widget? result;
    if (attachment.mimeType.startsWith("image")) {
      result = FutureBuilder<Uint8List>(
        future: widget.onDownloadAttachment(attachment.attachmentId),
        builder: (_, snapshot) {
          final data = snapshot.data ?? Uint8List(0);
          return InkWell(
            onTap: () {
              widget.onOpenImagePreviewTap(data);
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
                    "${overlayAmount}+",
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
        : const SizedBox(
            width: 0,
            height: 0,
          );
  }
}
