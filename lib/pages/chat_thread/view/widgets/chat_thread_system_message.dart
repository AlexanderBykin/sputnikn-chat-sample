import 'package:flutter/widgets.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/models/models.dart';

class ChatThreadSystemMessage extends StatelessWidget {
  const ChatThreadSystemMessage({
    required this.model,
    super.key,
  });

  final ChatThreadUIEventSystem model;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        top: 16,
        right: 16,
      ),
      child: Center(
        child: Text(model.messageContent.buildContent()),
      ),
    );
  }
}
