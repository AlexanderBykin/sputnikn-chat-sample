import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/models/models.dart';

class ChatThreadUnreadMessage extends StatelessWidget {
  const ChatThreadUnreadMessage({
    required this.model,
    super.key,
  });

  final ChatThreadUIEventUnread model;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(
        AppLocalizations.of(context)!.chat_thread_unreaded_messages,
      ),
    );
  }
}
