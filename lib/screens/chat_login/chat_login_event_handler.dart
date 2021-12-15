import 'package:auto_route/auto_route.dart';
import 'package:sputnikn_chatsample/route/app_router.gr.dart';
import 'package:flutter/widgets.dart';
import 'package:sputnikn_chatsample/screens/chat_login/chat_login_vm.dart';
import 'package:sputnikn_chatsample/util/event_handler_base.dart';

class EventNavigateChatList implements EventHandlerMessageBase {}

class ChatLoginEventHandler extends EventHandlerBase<ChatLoginVM> {
  final BuildContext context;

  ChatLoginEventHandler(this.context);

  @override
  void processEvent(EventHandlerMessageBase event, ChatLoginVM viewModel) {
    if (event is EventNavigateChatList) {
      AutoRouter.of(context).replace(const ChatRouter(
        children: [
          ChatListScreenRoute(),
        ],
      ));
    } else {
      unhandledEvent(event);
    }
  }
}
