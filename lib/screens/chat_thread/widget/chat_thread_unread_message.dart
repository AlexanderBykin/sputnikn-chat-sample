import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sputnikn_chatsample/model/chat_thread_ui_message_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatThreadUnreadMessage extends StatelessWidget {
  final ChatThreadUIEventUnread model;

  const ChatThreadUnreadMessage({
    required this.model,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(AppLocalizations.of(context)!.chat_thread_unreaded_messages),
    );
  }
}
