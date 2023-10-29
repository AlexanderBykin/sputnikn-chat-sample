import 'package:auto_route/auto_route.dart';
import 'package:chat_client_repository/chat_client_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sputnikn_chatsample/core/core.dart';
import 'package:sputnikn_chatsample/pages/chat_create/bloc/chat_create_bloc.dart';
import 'package:sputnikn_chatsample/pages/chat_create/view/widget/widgets.dart';

@RoutePage()
class ChatCreateScreen extends StatefulWidget implements AutoRouteWrapper {
  const ChatCreateScreen({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ChatCreateScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<ChatCreateBloc>(
      create: (context) => ChatCreateBloc(
        chatClientRepository: context.read<ChatClientRepository>(),
      ),
      child: this,
    );
  }
}

class _ChatCreateScreenState extends State<ChatCreateScreen>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController(text: '');
  late AnimationController _hideFabAnimation;
  late final ChatCreateBloc _bloc;

  @override
  void initState() {
    super.initState();
    _hideFabAnimation = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    );
    _hideFabAnimation.forward();
    _bloc = context.read<ChatCreateBloc>();
    _bloc.add(FetchUsersSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    return ChatLoaderScope(
      child: MultiBlocListener(
        listeners: [
          BlocListener<ChatCreateBloc, ChatCreateState>(
            bloc: _bloc,
            listenWhen: (prev, next) =>
                prev.loadingStatus != next.loadingStatus,
            listener: (context, state) {
              ChatLoaderScope.of(context).changeLoaderVisibility(
                state.loadingStatus == ChatCreateLoadingStatus.loading,
              );
            },
          ),
          BlocListener<ChatCreateBloc, ChatCreateState>(
            bloc: _bloc,
            listenWhen: (prev, next) =>
                prev.chatCreateStatus != next.chatCreateStatus,
            listener: (_, state) {
              if (state.chatCreateStatus == ChatCreateStatus.chatCreated) {
                AutoRouter.of(context).pop(state.createdRoom);
              }
            },
          ),
        ],
        child: NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)!.chat_create_title,
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: ScaleTransition(
              scale: _hideFabAnimation,
              alignment: Alignment.bottomCenter,
              child: _btnSave(),
            ),
            body: TapResetFocusArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Palette.color1,
                        hintText: AppLocalizations.of(context)!
                            .chat_create_field_title,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        _bloc.add(
                          ChangeRoomNameSubmitted(_titleController.text),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _usersList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _usersList() {
    return BlocBuilder<ChatCreateBloc, ChatCreateState>(
      bloc: _bloc,
      buildWhen: (prev, next) =>
          prev.members != next.members ||
          prev.selectedMemberIds != next.selectedMemberIds,
      builder: (_, state) {
        return ChatMemberList(
          selectedMemberIds: state.selectedMemberIds,
          members: state.members,
          onUserTap: (value) {
            _bloc.add(
              MemberChangeSelectionSubmitted(value),
            );
          },
        );
      },
    );
  }

  Widget _btnSave() {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.all(16),
      child: TextButton(
        onPressed: () {
          _bloc.add(CreateChatSubmitted());
        },
        child: Text(
          AppLocalizations.of(context)!.chat_create_btn_save,
        ),
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        switch (notification.direction) {
          case ScrollDirection.forward:
            if (notification.metrics.maxScrollExtent !=
                notification.metrics.minScrollExtent) {
              _hideFabAnimation.forward();
            }
          case ScrollDirection.reverse:
            if (notification.metrics.maxScrollExtent !=
                notification.metrics.minScrollExtent) {
              _hideFabAnimation.reverse();
            }
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
