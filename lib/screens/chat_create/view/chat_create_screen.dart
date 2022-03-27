import 'package:auto_route/auto_route.dart';
import 'package:chat_client_repository/chat_client_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:sputnikn_chatsample/core/core.dart';
import 'package:sputnikn_chatsample/screens/chat_create/bloc/chat_create_bloc.dart';
import 'package:sputnikn_chatsample/screens/chat_create/view/widget/widgets.dart';

class ChatCreateScreen extends StatefulWidget {
  const ChatCreateScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatCreateScreenState();

  static Route<T> route<T>(
    BuildContext context,
    Widget child,
    CustomPage<T> page,
  ) {
    return MaterialPageRoute(
      builder: (_) {
        return BlocProvider<ChatCreateBloc>(
          create: (context) => ChatCreateBloc(
            chatClientRepository: context.read<ChatClientRepository>(),
          ),
          child: child,
        );
      },
      settings: page,
    );
  }
}

class _ChatCreateScreenState extends State<ChatCreateScreen>
    with TickerProviderStateMixin, LoadingOverlayMixin {
  final _titleController = TextEditingController(text: '');
  late AnimationController _hideFabAnimation;

  @override
  void initState() {
    super.initState();
    _hideFabAnimation = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    );
    _hideFabAnimation.forward();
    context.read<ChatCreateBloc>().add(FetchUsersSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ChatCreateBloc, ChatCreateState>(
          listenWhen: (prev, next) => prev.loadingStatus != next.loadingStatus,
          listener: (context, state) {
            if (state.loadingStatus == ChatCreateLoadingStatus.loading) {
              showLoader(context);
            } else {
              hideLoader();
            }
          },
        ),
        BlocListener<ChatCreateBloc, ChatCreateState>(
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
                  child: _roomNameField(),
                ),
                Expanded(
                  child: _usersList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roomNameField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Palette.color1,
        hintText: AppLocalizations.of(context)!.chat_create_field_title,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        context.read<ChatCreateBloc>().add(
              ChangeRoomNameSubmitted(_titleController.text),
            );
      },
    );
  }

  Widget _usersList() {
    return BlocBuilder<ChatCreateBloc, ChatCreateState>(
      buildWhen: (prev, next) =>
          prev.members != next.members ||
          prev.selectedMemberIds != next.selectedMemberIds,
      builder: (_, state) {
        return ListView.builder(
          itemCount: state.members.length,
          itemBuilder: (_, itemIndex) {
            return ChatMemberItemWidget(
              member: state.members[itemIndex],
              isSelected: state.selectedMemberIds
                  .any((e) => state.members[itemIndex].userId == e),
              onItemTap: (value) {
                context.read<ChatCreateBloc>().add(
                      MemberChangeSelectionSubmitted(value),
                    );
              },
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
          context.read<ChatCreateBloc>().add(CreateChatSubmitted());
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
            break;
          case ScrollDirection.reverse:
            if (notification.metrics.maxScrollExtent !=
                notification.metrics.minScrollExtent) {
              _hideFabAnimation.reverse();
            }
            break;
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
