import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sputnikn_chatsample/core/themes/palette.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/models/models.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/view/widgets/widgets.dart';

class ChatThreadMessageAction extends StatelessWidget {
  const ChatThreadMessageAction({
    required this.message,
    required this.isMyMessage,
    required this.onDownloadMedia,
    required this.onForwardTap,
    required this.onReplyTap,
    required this.onCopyTap,
    required this.onDeleteTap,
    super.key,
  });

  final ChatThreadUIEventMessage message;
  final bool isMyMessage;
  final Future<Uint8List> Function(String) onDownloadMedia;
  final VoidCallback onForwardTap;
  final VoidCallback onReplyTap;
  final VoidCallback onCopyTap;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: isMyMessage
                    ? ChatThreadMyMessage(
                        model: message,
                        onActionTap: null,
                        onDownloadMedia: onDownloadMedia,
                        onOpenImagePreviewTap: (_) {},
                      )
                    : ChatThreadOtherMessage(
                        model: message,
                        onActionTap: null,
                        onDownloadMedia: onDownloadMedia,
                        onOpenImagePreviewTap: (_) {},
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ActionPanel(
            isMyMessage: isMyMessage,
            onForwardTap: onForwardTap,
            onReplyTap: onReplyTap,
            onCopyTap: onCopyTap,
            onDeleteTap: onDeleteTap,
          ),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.isMyMessage,
    required this.onForwardTap,
    required this.onReplyTap,
    required this.onCopyTap,
    required this.onDeleteTap,
    super.key,
  });

  final bool isMyMessage;
  final VoidCallback onForwardTap;
  final VoidCallback onReplyTap;
  final VoidCallback onCopyTap;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: isMyMessage ? 0.0 : 56.0,
        right: isMyMessage ? 56.0 : 0.0,
      ),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Palette.color1,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionButton(
            icon: Icons.reply_all_rounded,
            onTap: onForwardTap,
            title: AppLocalizations.of(context)!.chat_thread_action_forward,
          ),
          const SizedBox(height: 8),
          _ActionButton(
            icon: Icons.reply_rounded,
            onTap: onReplyTap,
            title: AppLocalizations.of(context)!.chat_thread_action_reply,
          ),
          const SizedBox(height: 8),
          _ActionButton(
            icon: Icons.copy_rounded,
            onTap: onCopyTap,
            title: AppLocalizations.of(context)!.chat_thread_action_copy,
          ),
          if (isMyMessage)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _ActionButton(
                icon: Icons.delete_outline,
                onTap: onDeleteTap,
                title: AppLocalizations.of(context)!.chat_thread_action_delete,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Palette.color5,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(title),
        ],
      ),
    );
  }
}
