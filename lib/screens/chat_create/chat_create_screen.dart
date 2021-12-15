import 'package:auto_route/auto_route.dart';
import 'package:flutter/rendering.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:sputnikn_chatsample/constants/palette.dart';
import 'package:sputnikn_chatsample/di/di.dart';
import 'package:sputnikn_chatsample/screens/chat_create/chat_create_event_handler.dart';
import 'package:sputnikn_chatsample/screens/chat_create/chat_create_vm.dart';
import 'package:sputnikn_chatsample/screens/chat_create/widget/chat_member_item_widget.dart';
import 'package:sputnikn_chatsample/screens/chat_create/selectable_member_vm.dart';
import 'package:sputnikn_chatsample/screens/widgets/tap_reset_focus_area.dart';
import 'package:sputnikn_chatsample/services/chat_service/chat_service_base.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sputnikn_chatsample/util/extension/text_editing_controller_bind_extension.dart';

class ChatCreateScreen extends StatefulWidget implements AutoRouteWrapper {
  const ChatCreateScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatCreateScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ChatCreateVM(
        eventHandler: ChatCreateEventHandler(ctx),
        chatService: DI.injector.get<ChatServiceBase>(),
      ),
      builder: (_, __) => this,
    );
  }
}

class _ChatCreateScreenState extends State<ChatCreateScreen>
    with TickerProviderStateMixin, LifecycleAware, LifecycleMixin {
  final _titleController = TextEditingController(text: "");
  late AnimationController _hideFabAnimation;

  @override
  void initState() {
    super.initState();
    _hideFabAnimation = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    );
    _hideFabAnimation.forward();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final viewModel = context.read<ChatCreateVM>();
      _titleController.bindTwoWay(
        sourceNotifier: viewModel,
        valueGetter: () => viewModel.title,
        valueSetter: (value) => viewModel.title = value,
      );
      viewModel.startup();
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.chat_create_title,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: ScaleTransition(
          scale: _hideFabAnimation,
          alignment: Alignment.bottomCenter,
          child: _btnSave(),
        ),
        body: TapResetFocusArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _roomNameField(),
              ),
              Expanded(
                child: _usersList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roomNameField() {
    return TextFormField(
      controller: _titleController,
      maxLines: 1,
      decoration: InputDecoration(
        filled: true,
        fillColor: Palette.color1,
        hintText: AppLocalizations.of(context)!.chat_create_field_title,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
      ),
    );
  }

  Widget _usersList() {
    return Selector<ChatCreateVM, List<SelectableMemberVM>>(
      selector: (_, viewModel) => viewModel.members,
      builder: (_, data, __) {
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (_, itemIndex) {
            return ChatMemberItemWidget.builder(
              data[itemIndex],
            );
          },
        );
      },
    );
  }

  Widget _btnSave() {
    return Container(
      width: double.infinity,
      height: 50.0,
      margin: const EdgeInsets.all(16),
      child: TextButton(
        onPressed: context.read<ChatCreateVM>().onSaveTap,
        child: Text(
          AppLocalizations.of(context)!.chat_create_btn_save,
        ),
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;
        switch (userScroll.direction) {
          case ScrollDirection.forward:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
              _hideFabAnimation.forward();
            }
            break;
          case ScrollDirection.reverse:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
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

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event == LifecycleEvent.pop) {
      return;
    }
    context.read<ChatCreateVM>().onLifecycleEvent(event);
  }
}
