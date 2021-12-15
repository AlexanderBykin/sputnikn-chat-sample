import 'package:flutter/material.dart';
import 'package:sputnikn_chatsample/constants/palette.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sputnikn_chatsample/model/event_message_content_model_v1.dart';
import 'package:sputnikn_chatsample/model/media_file_model.dart';

class ChatThreadBottomPanel extends StatefulWidget {
  final double height;
  final EdgeInsets margin;
  final Function(EventMessageContentModelV1, List<MediaFileModel>) onAddMessage;
  final Future<List<MediaFileModel>> Function() onAddAttachment;

  const ChatThreadBottomPanel({
    required this.height,
    required this.onAddMessage,
    required this.onAddAttachment,
    this.margin = const EdgeInsets.all(8),
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatThreadBottomPanelState();
}

class _ChatThreadBottomPanelState extends State<ChatThreadBottomPanel> {
  final _messageController = TextEditingController(text: "");
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AttachmentThumbnail(
            attachments: _attachments,
            onRemoveAttachment: onRemoveAttachment,
            onRemoveAllAttachment: onRemoveAllAttachment,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _btnAddAttachment(),
              Flexible(
                child: TextFormField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context)!.chat_thread_message_hint,
                  ),
                ),
              ),
              _btnSendMessage(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btnAddAttachment() {
    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
        widget.onAddAttachment().then((value) {
          setState(() {
            _attachments.addAll(value);
          });
        });
      },
      child: const Icon(
        Icons.attach_file,
        color: Palette.color6,
      ),
    );
  }

  Widget _btnSendMessage() {
    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
        widget.onAddMessage(
          EventMessageContentModelV1(
            content: _messageController.text,
          ),
          _attachments.toList(),
        );
        _messageController.text = "";
        onRemoveAllAttachment();
      },
      child: const Icon(
        Icons.send,
        color: Palette.color6,
      ),
    );
  }

  void onRemoveAttachment(MediaFileModel file) {
    setState(() {
      _attachments.remove(file);
    });
  }

  void onRemoveAllAttachment() {
    setState(() {
      _attachments.clear();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class AttachmentThumbnail extends StatelessWidget {
  final List<MediaFileModel> attachments;
  final Function(MediaFileModel) onRemoveAttachment;
  final Function() onRemoveAllAttachment;

  const AttachmentThumbnail({
    required this.attachments,
    required this.onRemoveAttachment,
    required this.onRemoveAllAttachment,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: attachments.isNotEmpty,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        height: 60.0,
        child: Row(
          children: [
            Expanded(
              child: _attachmentList(),
            ),
            _btnCleanAttachments(),
          ],
        ),
      ),
    );
  }

  Widget _attachmentList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: attachments.length,
      itemBuilder: (_, itemIndex) {
        return Dismissible(
          key: ValueKey("AttachmentThumbnail$itemIndex"),
          child: _attachmentThumbnail(
            attachments[itemIndex],
            attachments.length,
            itemIndex,
          ),
          background: Container(
            color: Colors.red,
          ),
          onDismissed: (_) {
            onRemoveAttachment(attachments[itemIndex]);
          },
        );
      },
    );
  }

  Widget _attachmentThumbnail(MediaFileModel media, int itemsCount, int currentIndex) {
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

  Widget _btnCleanAttachments() {
    return InkWell(
      onTap: () {
        onRemoveAllAttachment();
      },
      child: const Icon(
        Icons.highlight_remove,
        color: Palette.color6,
      ),
    );
  }
}
