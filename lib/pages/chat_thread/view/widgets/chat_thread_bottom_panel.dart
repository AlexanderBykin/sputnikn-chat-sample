import 'package:chat_client_repository/chat_client_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sputnikn_chatsample/core/themes/palette.dart';

typedef TAddMessage = void Function(
  EventMessageContentModelV1,
  List<MediaFileModel>,
);
typedef TAddAttachment = Future<List<MediaFileModel>> Function();

class ChatThreadBottomPanel extends StatefulWidget {
  const ChatThreadBottomPanel({
    required this.height,
    required this.onAddMessage,
    required this.onAddAttachment,
    this.margin = const EdgeInsets.all(8),
    super.key,
  });

  final double height;
  final EdgeInsets margin;
  final TAddMessage onAddMessage;
  final TAddAttachment onAddAttachment;

  @override
  State<StatefulWidget> createState() => _ChatThreadBottomPanelState();
}

class _ChatThreadBottomPanelState extends State<ChatThreadBottomPanel> {
  final _messageController = TextEditingController(text: '');
  final _attachments = <MediaFileModel>[];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: widget.height,
        maxHeight: widget.height * 2,
      ),
      margin: widget.margin,
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: Palette.color1,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_attachments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AttachmentThumbnail(
                attachments: _attachments,
                onRemoveAttachment: onRemoveAttachment,
                onRemoveAllAttachment: onRemoveAllAttachment,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: onAddAttachmentTap,
                child: const Icon(
                  Icons.attach_file,
                  color: Palette.color6,
                ),
              ),
              Flexible(
                child: TextFormField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context)!.chat_thread_message_hint,
                  ),
                ),
              ),
              InkWell(
                onTap: onSendMessageTap,
                child: const Icon(
                  Icons.send,
                  color: Palette.color6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void onRemoveAttachment(MediaFileModel file) {
    setState(() {
      _attachments.remove(file);
    });
  }

  void onRemoveAllAttachment() {
    setState(_attachments.clear);
  }

  void onAddAttachmentTap() {
    FocusScope.of(context).unfocus();
    widget.onAddAttachment().then((value) {
      setState(() {
        _attachments.addAll(value);
      });
    });
  }

  void onSendMessageTap() {
    FocusScope.of(context).unfocus();
    widget.onAddMessage(
      EventMessageContentModelV1(
        content: _messageController.text,
      ),
      _attachments.toList(),
    );
    _messageController.text = '';
    onRemoveAllAttachment();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class AttachmentThumbnail extends StatelessWidget {
  const AttachmentThumbnail({
    required this.attachments,
    required this.onRemoveAttachment,
    required this.onRemoveAllAttachment,
    super.key,
  });

  final List<MediaFileModel> attachments;
  final ValueChanged<MediaFileModel> onRemoveAttachment;
  final VoidCallback onRemoveAllAttachment;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Row(
        children: [
          Expanded(
            child: _AttachmentList(
              attachments: attachments,
              onRemoveAttachment: onRemoveAttachment,
            ),
          ),
          InkWell(
            onTap: onRemoveAllAttachment,
            child: const Icon(
              Icons.highlight_remove,
              color: Palette.color6,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentList extends StatelessWidget {
  const _AttachmentList({
    required this.attachments,
    required this.onRemoveAttachment,
    super.key,
  });

  final List<MediaFileModel> attachments;
  final ValueChanged<MediaFileModel> onRemoveAttachment;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: attachments.length,
      itemBuilder: (_, itemIndex) {
        return Dismissible(
          key: ValueKey('AttachmentThumbnail$itemIndex'),
          background: Container(
            color: Colors.red,
          ),
          onDismissed: (_) {
            onRemoveAttachment(attachments[itemIndex]);
          },
          child: _AttachmentThumbnail(
            media: attachments[itemIndex],
            itemsCount: attachments.length,
            currentIndex: itemIndex,
          ),
        );
      },
    );
  }
}

class _AttachmentThumbnail extends StatelessWidget {
  const _AttachmentThumbnail({
    required this.media,
    required this.itemsCount,
    required this.currentIndex,
    super.key,
  });

  final MediaFileModel media;
  final int itemsCount;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final leftPadding =
        (currentIndex > 0 && itemsCount - 1 >= currentIndex) ? 8.0 : 0.0;
    return Container(
      width: 80,
      height: 60,
      padding: EdgeInsets.only(left: leftPadding),
      child: Image.file(
        media.file,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}
