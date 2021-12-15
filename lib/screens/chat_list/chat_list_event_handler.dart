import 'package:auto_route/auto_route.dart';
import 'package:sputnikn_chatsample/model/create_chat_model.dart';
import 'package:sputnikn_chatsample/route/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:sputnikn_chatsample/screens/chat_list/chat_list_vm.dart';
import 'package:sputnikn_chatsample/util/event_handler_base.dart';

class EventNavigateChatThread implements EventHandlerMessageBase {
  final String chatId;

  EventNavigateChatThread(this.chatId);
}

class EventNavigateCreateRoom implements EventHandlerMessageBase {
  final Function(CreateChatModel?) callback;

  EventNavigateCreateRoom(this.callback);
}

class ChatListEventHandler extends EventHandlerBase<ChatListVM> {
  final BuildContext context;

  ChatListEventHandler(this.context);

  @override
  void processEvent(EventHandlerMessageBase event, ChatListVM viewModel) {
    if (event is EventNavigateChatThread) {
      AutoRouter.of(context).push(ChatThreadScreenRoute(chatId: event.chatId));
    } else if (event is EventNavigateCreateRoom) {
      AutoRouter.of(context).push(const ChatCreateScreenRoute()).then((value) {
        event.callback(value as CreateChatModel?);
      });
    }
  }
}
