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
import 'package:sputnikn_chatsample/app_router/app_router.dart';
import 'package:sputnikn_chatsample/core/core.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/models/models.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/page.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/view/widgets/widgets.dart';

@RoutePage()
class ChatThreadScreen extends StatefulWidget implements AutoRouteWrapper {
  const ChatThreadScreen({
    // ignore: avoid_unused_constructor_parameters
    required String chatId,
    super.key,
  });

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    final args = context.routeData.argsAs<ChatThreadRouteArgs>();
    return BlocProvider<ChatThreadBloc>(
      create: (ctx) => ChatThreadBloc(
        chatId: args.chatId,
        chatClientRepository: ctx.read<ChatClientRepository>(),
        mediaCacheManager: ctx.read<MediaCacheManager>(),
      ),
      child: this,
    );
  }
}

class _ChatThreadScreenState extends State<ChatThreadScreen>
    with TickerProviderStateMixin {
  late AnimationController _hideFabAnimation;
  final _avatarSize = 40.0;
  final _itemScrollController = ItemScrollController();
  final _itemPositionsListener = ItemPositionsListener.create();
  final _bottomPanelHeight = 60.0;
  final _bottomPanelMargin = const EdgeInsets.all(8);
  late final ChatThreadBloc _bloc;
  int _lastUnreadMarkerIndex = -1;

  @override
  void initState() {
    _bloc = context.read<ChatThreadBloc>();
    super.initState();
    _hideFabAnimation = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    );
    _hideFabAnimation.forward();
    _bloc.add(FetchChatDetailSubmitted());
    _itemPositionsListener.itemPositions.addListener(() {
      _bloc.add(
        ChangeScrollPositionSubmitted(
          _itemPositionsListener.itemPositions.value,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatThreadBloc, ChatThreadState>(
      bloc: _bloc,
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
            child: ChatThreadBottomPanel(
              height: _bottomPanelHeight,
              margin: _bottomPanelMargin,
              onAddMessage: (message, attachments) {
                _bloc.add(
                  AddNewChatMessageSubmitted(
                    message,
                    attachments,
                  ),
                );
              },
              onAddAttachment: _onAddAttachment,
            ),
          ),
          body: TapResetFocusArea(
            child: ColoredBox(
              color: Palette.color0,
              child: BlocBuilder<ChatThreadBloc, ChatThreadState>(
                buildWhen: (prev, next) => prev.messages != next.messages,
                builder: (_, state) {
                  return ChatThreadMessageList(
                    currentUser: _bloc.authenticatedUser,
                    messages: state.messages,
                    firstMessageBottomPadding:
                        _bottomPanelHeight + _bottomPanelMargin.bottom + 16,
                    scrollController: _itemScrollController,
                    positionsListener: _itemPositionsListener,
                    onActionTap: (value) {
                      _showChatMessageActionDialog(
                        _buildOpenChatMessageAction(value),
                      );
                    },
                    onDownloadMedia: _bloc.onDownloadMedia,
                    onOpenImagePreviewTap: _showChatImagePreview,
                  );
                },
              ),
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
    final authUser = _bloc.authenticatedUser;
    return EventOpenChatMessageAction(
      message: message,
      isMyMessage: message.senderId == authUser?.userId,
      onDownloadMedia: _bloc.onDownloadMedia,
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
              file: File(cropped.path),
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
              file: File(cropped.path),
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

  Future<dynamic> _showChatMessageActionDialog(
    EventOpenChatMessageAction event,
  ) {
    return showDialog<void>(
      context: context,
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
            onForwardTap: () {
              event.onForward();
              Navigator.of(context).pop();
            },
            onReplyTap: () {
              event.onReply();
              Navigator.of(context).pop();
            },
            onCopyTap: () {
              event.onCopy();
              Navigator.of(context).pop();
            },
            onDeleteTap: () {
              event.onDelete();
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Future<void> _showChatImagePreview(Uint8List imageData) {
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

  Future<void> _showPhotoSourceDialog({
    required VoidCallback onCamera,
    required VoidCallback onGallery,
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
