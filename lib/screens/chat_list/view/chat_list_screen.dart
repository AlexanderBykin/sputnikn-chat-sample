import 'package:auto_route/auto_route.dart';
import 'package:chat_client_repository/chat_client_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sputnikn_chatsample/core/themes/palette.dart';
import 'package:sputnikn_chatsample/route/app_router.gr.dart';
import 'package:sputnikn_chatsample/screens/chat_list/bloc/chat_list_bloc.dart';
import 'package:sputnikn_chatsample/screens/chat_list/models/models.dart';
import 'package:sputnikn_chatsample/screens/chat_list/view/widgets/widgets.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatListScreenState();

  static Route<T> route<T>(
    BuildContext context,
    Widget child,
    CustomPage<T> page,
  ) {
    return MaterialPageRoute(
      builder: (_) {
        return BlocProvider<ChatListBloc>(
          create: (context) => ChatListBloc(
            chatClientRepository: context.read<ChatClientRepository>(),
          ),
          child: child,
        );
      },
      settings: page,
    );
  }
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatListBloc>().add(FetchRoomListSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appLabel(),
        actions: [
          IconButton(
            onPressed: () {
              AutoRouter.of(context).push(const ChatCreateScreenRoute());
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Container(
        color: Palette.color0,
        child: BlocBuilder<ChatListBloc, ChatListState>(
          buildWhen: (prev, next) => prev.rooms != next.rooms,
          builder: (_, state) {
            return (state.rooms.isEmpty)
                ? _emptyListContent()
                : _listContent(state.rooms);
          },
        ),
      ),
    );
  }

  Widget _appLabel() {
    return RichText(
      text: TextSpan(
        text: AppLocalizations.of(context)!.app_title.split('-').first,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Palette.color3,
        ),
        children: [
          TextSpan(
            text: '-${AppLocalizations.of(context)!.app_title.split('-').last}',
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

  Widget _listContent(List<ChatRoomModel> rooms) {
    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (_, itemIndex) {
        return ChatListItemWidget(
          room: rooms[itemIndex],
          onChatItemTap: () {
            AutoRouter.of(context).push(
              ChatThreadScreenRoute(
                chatId: rooms[itemIndex].roomId,
              ),
            );
          },
        );
      },
    );
  }
}
