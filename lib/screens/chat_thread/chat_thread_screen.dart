import 'package:auto_route/auto_route.dart';
import 'package:flutter/rendering.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sputnikn_chatsample/constants/palette.dart';
import 'package:sputnikn_chatsample/di/di.dart';
import 'package:sputnikn_chatsample/model/chat_thread_ui_message_model.dart';
import 'package:sputnikn_chatsample/screens/chat_thread/chat_thread_event_handler.dart';
import 'package:sputnikn_chatsample/screens/chat_thread/chat_thread_vm.dart';
import 'package:sputnikn_chatsample/screens/chat_thread/widget/chat_thread_my_message.dart';
import 'package:sputnikn_chatsample/screens/chat_thread/widget/chat_thread_other_message.dart';
import 'package:sputnikn_chatsample/screens/chat_thread/widget/chat_thread_system_message.dart';
import 'package:sputnikn_chatsample/screens/widgets/tap_reset_focus_area.dart';
import 'package:sputnikn_chatsample/screens/widgets/user_avatar.dart';
import 'package:sputnikn_chatsample/services/chat_service/chat_service_base.dart';
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputnikn_chatsample/util/media_cache_manager.dart';
import 'widget/chat_thread_bottom_panel.dart';
import 'widget/chat_thread_unread_message.dart';

class ChatThreadScreen extends StatefulWidget implements AutoRouteWrapper {
  final String chatId;

  const ChatThreadScreen({
    @pathParam required this.chatId,
    Key? key,
  }) : super(key: key);

  @override
  _ChatThreadScreenState createState() => _ChatThreadScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    final i = DI.injector;
    return ChangeNotifierProvider(
      create: (ctx) => ChatThreadVM(
        eventHandler: ChatThreadEventHandler(ctx),
        chatService: i.get<ChatServiceBase>(),
        mediaCacheManager: i.get<MediaCacheManager>(),
        chatId: chatId,
      ),
      builder: (_, __) => this,
    );
  }
}

class _ChatThreadScreenState extends State<ChatThreadScreen>
    with TickerProviderStateMixin, LifecycleAware, LifecycleMixin {
  late AnimationController _hideFabAnimation;
  final _avatarSize = 40.0;
  final _itemScrollController = ItemScrollController();
  final _itemPositionsListener = ItemPositionsListener.create();
  final _bottomPanelHeight = 60.0;
  final _bottomPanelMargin = const EdgeInsets.all(8);
  int _lastUnreadMarkerIndex = -1;
  LifecycleEvent? _currentLifecycleState;

  @override
  void initState() {
    super.initState();
    _hideFabAnimation = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    );
    _hideFabAnimation.forward();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      debugPrint("[$runtimeType] addPostFrameCallback");
      final viewModel = context.read<ChatThreadVM>();
      viewModel.startup();
      _itemPositionsListener.itemPositions.addListener(() {
        viewModel.onScrollPositionChanged(
            _itemPositionsListener.itemPositions.value);
      });
      viewModel.addListener(() {
        if (viewModel.unreadMarkerIndex >= 0 &&
            viewModel.unreadMarkerIndex != _lastUnreadMarkerIndex) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (!lifecycleEventsVisibleAndActive
                .contains(_currentLifecycleState)) {
              return;
            }
            _itemScrollController.scrollTo(
              index: viewModel.unreadMarkerIndex,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeIn,
              alignment: 0.9,
            );
          });
        }
        _lastUnreadMarkerIndex = viewModel.unreadMarkerIndex;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Scaffold(
        appBar: _appBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: ScaleTransition(
          scale: _hideFabAnimation,
          alignment: Alignment.bottomCenter,
          child: _bottomPanel(),
        ),
        body: TapResetFocusArea(
          child: Container(
            color: Palette.color0,
            child: _chatMessagesWidget(),
          ),
        ),
      ),
    );
  }

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    _currentLifecycleState = event;
    if (event == LifecycleEvent.pop) {
      return;
    }
    context.read<ChatThreadVM>().onLifecycleEvent(event);
  }

  @override
  void dispose() {
    _hideFabAnimation.dispose();
    super.dispose();
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      titleSpacing: 0.0,
      title: Selector<ChatThreadVM, RoomDetail?>(
        selector: (_, vm) => vm.chatDetail,
        builder: (_, data, __) {
          final memberChars = (data?.members ?? [])
              .take(2)
              .map((e) => e.fullName.characters.first.toUpperCase())
              .toList()
              .join();
          return Row(
            children: [
              UserAvatar(
                userName: memberChars,
                avatarPath: data?.avatar,
                avatarSize: _avatarSize,
                borderRadius: 8.0,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  data?.title ?? "",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  final _selectorKey = UniqueKey();

  Widget _chatMessagesWidget() {
    return Selector<ChatThreadVM, List<ChatThreadUIMessageModelBase>>(
      key: _selectorKey,
      selector: (_, vm) => vm.messages,
      //shouldRebuild: (a, b) => a.calculateItemsHash() != b.calculateItemsHash(),
      builder: (_, data, __) {
        debugPrint(
            ">>> [$runtimeType] _chatMessagesWidget > Selector > builder");
        return ScrollablePositionedList.builder(
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          reverse: true,
          itemCount: data.length,
          minCacheExtent: 50,
          itemBuilder: (_, itemIndex) {
            return _chatItemWidget(
              itemIndex == 0,
              data[itemIndex],
            );
          },
        );
      },
    );
  }

  Widget _chatItemWidget(
      bool isAddPadding, ChatThreadUIMessageModelBase model) {
    final viewModel = context.read<ChatThreadVM>();
    late Widget childResult;
    if (model is ChatThreadUIEventMessage) {
      if (model.senderId == viewModel.myUser?.userId) {
        childResult = ChatThreadMyMessage(
          model: model,
          onActionTap: viewModel.onMessageActionTap,
          onDownloadMedia: viewModel.onDownloadMedia,
          onOpenImagePreviewTap: viewModel.onOpenImagePreviewTap,
        );
      } else {
        childResult = ChatThreadOtherMessage(
          model: model,
          onActionTap: viewModel.onMessageActionTap,
          onDownloadMedia: viewModel.onDownloadMedia,
          onOpenImagePreviewTap: viewModel.onOpenImagePreviewTap,
        );
      }
    } else if (model is ChatThreadUIEventSystem) {
      childResult = ChatThreadSystemMessage(
        model: model,
      );
    } else if (model is ChatThreadUIEventUnread) {
      childResult = ChatThreadUnreadMessage(
        model: model,
      );
    } else {
      childResult = const SizedBox(width: 0, height: 0);
    }
    return (isAddPadding)
        ? Container(
            margin: EdgeInsets.only(
              bottom: _bottomPanelHeight + _bottomPanelMargin.bottom + 16,
            ),
            child: childResult,
          )
        : childResult;
  }

  Widget _bottomPanel() {
    final vm = context.read<ChatThreadVM>();
    return ChatThreadBottomPanel(
      height: _bottomPanelHeight,
      margin: _bottomPanelMargin,
      onAddMessage: vm.onAddNewMessage,
      onAddAttachment: vm.onAddAttachment,
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
}
