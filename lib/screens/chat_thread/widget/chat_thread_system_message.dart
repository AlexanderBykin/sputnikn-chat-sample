import 'package:sputnikn_chatsample/model/chat_thread_ui_message_model.dart';
import 'package:flutter/widgets.dart';

class ChatThreadSystemMessage extends StatelessWidget {
  final ChatThreadUIEventSystem model;

  const ChatThreadSystemMessage({
    required this.model,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 16.0,
        top: 16.0,
        right: 16.0,
      ),
      child: Center(
        child: Text(model.messageContent.buildContent()),
      ),
    );
  }
}
