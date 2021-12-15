import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:sputnikn_chatsample/screens/chat_create/chat_create_vm.dart';
import 'package:sputnikn_chatsample/util/event_handler_base.dart';

class ChatCreateEventHandler extends EventHandlerBase<ChatCreateVM> {
  final BuildContext context;

  ChatCreateEventHandler(this.context);

  @override
  void processEvent(EventHandlerMessageBase event, ChatCreateVM viewModel) {
    if (event is EventNavigateBack) {
      AutoRouter.of(context).pop(event.param);
    } else {
      unhandledEvent(event);
    }
  }
}
