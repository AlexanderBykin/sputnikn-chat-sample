import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:chat_client_repository/chat_client_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sputnikn_chatsample/core/core.dart';
import 'package:sputnikn_chatsample/route/app_router.gr.dart';
import 'package:sputnikn_chatsample/screens/chat_thread/bloc/chat_thread_bloc.dart';
import 'package:sputnikn_chatsample/screens/chat_thread/models/models.dart';
import 'package:sputnikn_chatsample/screens/chat_thread/view/widgets/widgets.dart';

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({
    @pathParam required String chatId,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();

  static Route<T> route<T>(
    BuildContext context,
    Widget child,
    CustomPage<T> page,
  ) {
    return MaterialPageRoute(
      builder: (_) {
        final args = page.arguments as ChatThreadScreenRouteArgs?;
        return BlocProvider<ChatThreadBloc>(
          create: (ctx) => ChatThreadBloc(
            chatId: args!.chatId,
            chatClientRepository: ctx.read<ChatClientRepository>(),
            mediaCacheManager: ctx.read<MediaCacheManager>(),
          ),
          child: child,
        );
      },
      settings: page,
    );
  }
}

class _ChatThreadScreenState extends State<ChatThreadScreen>
    with TickerProviderStateMixin, LoadingOverlayMixin {
  late AnimationController _hideFabAnimation;
  final _avatarSize = 40.0;
  final _itemScrollController = ItemScrollController();
  final _itemPositionsListener = ItemPositionsListener.create();
  final _bottomPanelHeight = 60.0;
  final _bottomPanelMargin = const EdgeInsets.all(8);
  int _lastUnreadMarkerIndex = -1;

  @override
  void initState() {
    super.initState();
    _hideFabAnimation = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    );
    _hideFabAnimation.forward();
    context.read<ChatThreadBloc>().add(FetchChatDetailSubmitted());
    _itemPositionsListener.itemPositions.addListener(() {
      context.read<ChatThreadBloc>().add(
            ChangeScrollPositionSubmitted(
              _itemPositionsListener.itemPositions.value,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatThreadBloc, ChatThreadState>(
      listenWhen: (prev, next) =>
          prev.unreadMarkerIndex != next.unreadMarkerIndex,
      listener: (_, state) {
        if (state.unreadMarkerIndex >= 0 &&
            state.unreadMarkerIndex != _lastUnreadMarkerIndex) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            _itemScrollController.scrollTo(
              index: state.unreadMarkerIndex,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeIn,
              alignment: 0.9,
            );
          });
        }
        _lastUnreadMarkerIndex = state.unreadMarkerIndex;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: Scaffold(
          appBar: _appBar(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
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
      ),
    );
  }

  @override
  void dispose() {
    _hideFabAnimation.dispose();
    super.dispose();
  }

  EventOpenChatMessageAction _buildOpenChatMessageAction(
    ChatThreadUIEventMessage message,
  ) {
    final authUser = context.read<ChatThreadBloc>().authenticatedUser;
    return EventOpenChatMessageAction(
      message: message,
      isMyMessage: message.senderId == authUser?.userId,
      onDownloadMedia: context.read<ChatThreadBloc>().onDownloadMedia,
      onForward: () {
        log('>>> onForwardMessage');
      },
      onReply: () {
        log('>>> onReplyMessage');
      },
      onCopy: () {
        log('>>> onCopyMessage');
      },
      onDelete: () {
        log('>>> onDeleteMessage');
      },
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      titleSpacing: 0,
      title: BlocBuilder<ChatThreadBloc, ChatThreadState>(
        buildWhen: (prev, next) => prev.chatDetail != next.chatDetail,
        builder: (_, state) {
          final memberChars = (state.chatDetail?.members ?? [])
              .take(2)
              .map((e) => e.fullName.characters.first.toUpperCase())
              .toList()
              .join();
          return Row(
            children: [
              UserAvatar(
                userName: memberChars,
                avatarPath: state.chatDetail?.avatar,
                avatarSize: _avatarSize,
                borderRadius: 8,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  state.chatDetail?.title ?? '',
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
    return BlocBuilder<ChatThreadBloc, ChatThreadState>(
      buildWhen: (prev, next) => prev.messages != next.messages,
      builder: (_, state) {
        return ScrollablePositionedList.builder(
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          reverse: true,
          itemCount: state.messages.length,
          minCacheExtent: 50,
          itemBuilder: (_, itemIndex) {
            return _chatItemWidget(
              itemIndex == 0,
              state.messages[itemIndex],
            );
          },
        );
      },
    );
  }

  Widget _chatItemWidget(
    bool isAddPadding,
    ChatThreadUIMessageModelBase model,
  ) {
    final chatThreadBloc = context.read<ChatThreadBloc>();
    final authUser = context.read<ChatThreadBloc>().authenticatedUser;
    Widget childResult = const SizedBox(width: 0, height: 0);
    if (model is ChatThreadUIEventMessage) {
      if (model.senderId == authUser?.userId) {
        childResult = ChatThreadMyMessage(
          model: model,
          onActionTap: (value) {
            _showChatMessageActionDialog(
              _buildOpenChatMessageAction(value),
            );
          },
          onDownloadMedia: chatThreadBloc.onDownloadMedia,
          onOpenImagePreviewTap: _showChatImagePreview,
        );
      } else {
        childResult = ChatThreadOtherMessage(
          model: model,
          onActionTap: (value) {
            _showChatMessageActionDialog(
              _buildOpenChatMessageAction(value),
            );
          },
          onDownloadMedia: chatThreadBloc.onDownloadMedia,
          onOpenImagePreviewTap: _showChatImagePreview,
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
    return ChatThreadBottomPanel(
      height: _bottomPanelHeight,
      margin: _bottomPanelMargin,
      onAddMessage: (message, attachments) {
        context.read<ChatThreadBloc>().add(
              AddNewChatMessageSubmitted(
                message,
                attachments,
              ),
            );
      },
      onAddAttachment: _onAddAttachment,
    );
  }

  Future<List<MediaFileModel>> _onAddAttachment() {
    final completer = Completer<List<MediaFileModel>>();
    _showPhotoSourceDialog(
      onCamera: () async {
        final image = await ImageUtil.takePictureFromCamera(preferFront: false);
        if (image == null) {
          return;
        }
        final cropped = await ImageUtil.cropImage(File(image.path));
        if (cropped != null) {
          completer.complete([
            MediaFileModel(
              file: cropped,
              mimeType: image.mimeType,
            ),
          ]);
        } else {
          completer.complete([]);
        }
      },
      onGallery: () async {
        final image = await ImageUtil.takePictureFromGallery();
        if (image == null) {
          return;
        }
        final cropped = await ImageUtil.cropImage(File(image.path));
        if (cropped != null) {
          completer.complete([
            MediaFileModel(
              file: cropped,
              mimeType: image.mimeType,
            ),
          ]);
        } else {
          completer.complete([]);
        }
      },
    );
    return completer.future;
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

  Future<dynamic> _showChatMessageActionDialog(
    EventOpenChatMessageAction event,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      builder: (_) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 15,
            sigmaY: 15,
          ),
          child: ChatThreadMessageAction(
            message: event.message,
            isMyMessage: event.isMyMessage,
            onDownloadMedia: event.onDownloadMedia,
            onForward: () {
              event.onForward();
              Navigator.of(context).pop();
            },
            onReply: () {
              event.onReply();
              Navigator.of(context).pop();
            },
            onCopy: () {
              event.onCopy();
              Navigator.of(context).pop();
            },
            onDelete: () {
              event.onDelete();
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Future _showChatImagePreview(Uint8List imageData) {
    return showDialog<void>(
      context: context,
      useRootNavigator: false,
      builder: (_) {
        return ChatThreadImagePreview(
          imageData: imageData,
        );
      },
    );
  }

  Future _showPhotoSourceDialog({
    required Function() onCamera,
    required Function() onGallery,
  }) {
    final sheet = CupertinoActionSheet(
      message: Text(
        AppLocalizations.of(context)!.chat_thread_choose_media_title,
      ),
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(
          AppLocalizations.of(context)!.chat_thread_choose_media_btn_cancel,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      actions: [
        CupertinoActionSheetAction(
          child: Text(
            AppLocalizations.of(context)!
                .chat_thread_choose_media_source_camera,
            style: const TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onCamera();
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            AppLocalizations.of(context)!
                .chat_thread_choose_media_source_gallery,
            style: const TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onGallery();
          },
        ),
      ],
    );

    return showCupertinoModalPopup<void>(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 15,
            sigmaY: 15,
          ),
          child: sheet,
        );
      },
    );
  }
}
