import 'package:auto_route/auto_route.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:sputnikn_chatsample/constants/palette.dart';
import 'package:sputnikn_chatsample/di/di.dart';
import 'package:sputnikn_chatsample/screens/chat_list/widget/chat_list_item_widget.dart';
import 'package:sputnikn_chatsample/screens/chat_list/chat_list_vm.dart';
import 'package:sputnikn_chatsample/screens/chat_list/chat_room_vm.dart';
import 'package:sputnikn_chatsample/services/chat_service/chat_service_base.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'chat_list_event_handler.dart';

class ChatListScreen extends StatefulWidget implements AutoRouteWrapper {
  const ChatListScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatListScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ChatListVM(
        eventHandler: ChatListEventHandler(ctx),
        chatService: DI.injector.get<ChatServiceBase>(),
      ),
      builder: (_, __) => this,
    );
  }
}

class _ChatListScreenState extends State<ChatListScreen>
    with LifecycleAware, LifecycleMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      context.read<ChatListVM>().startup();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ChatListVM>();
    return Scaffold(
      appBar: AppBar(
        title: _appLabel(),
        actions: [
          IconButton(
            onPressed: vm.onCreateRoomTap,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Container(
        color: Palette.color0,
        child: Selector<ChatListVM, List<ChatRoomVM>>(
          selector: (_, vm) => vm.rooms,
          builder: (_, data, __) {
            return (data.isEmpty) ? _emptyListContent() : _listContent(data);
          },
        ),
      ),
    );
  }

  Widget _appLabel() {
    return RichText(
      text: TextSpan(
        text: AppLocalizations.of(context)!.app_title.split("-").first,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Palette.color3,
        ),
        children: [
          TextSpan(
            text: "-" + AppLocalizations.of(context)!.app_title.split("-").last,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyListContent() {
    return Center(
      child: Text(AppLocalizations.of(context)!.chat_list_empty_list),
    );
  }

  Widget _listContent(List<ChatRoomVM> rooms) {
    final viewModel = context.read<ChatListVM>();
    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (_, itemIndex) {
        return ChatListItemWidget.builder(
          rooms[itemIndex],
          viewModel.onChatItemTap,
        );
      },
    );
  }

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event == LifecycleEvent.pop) {
      return;
    }
    context.read<ChatListVM>().onLifecycleEvent(event);
  }
}
