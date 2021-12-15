import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:sputnikn_chat_client/model/response/upload_media_response.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sputnikn_chatsample/constants/constants.dart';
import 'package:sputnikn_chatsample/model/chat_thread_ui_message_model.dart';
import 'package:sputnikn_chatsample/model/event_message_content_model_v1.dart';
import 'package:sputnikn_chatsample/model/media_file_model.dart';
import 'package:sputnikn_chatsample/screens/chat_thread/chat_thread_event_handler.dart';
import 'package:sputnikn_chatsample/services/chat_service/chat_service_base.dart';
import 'package:sputnikn_chatsample/util/event_handler_base.dart';
import 'package:sputnikn_chatsample/util/image_util.dart';
import 'package:sputnikn_chatsample/util/loading_mixin.dart';
import 'package:sputnikn_chatsample/util/media_cache_manager.dart';
import 'package:sputnikn_chatsample/util/subscription_mixin.dart';
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:sputnikn_chat_client/model/response/room_event_system_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:sputnikn_chatsample/util/work_manager_mixin.dart';

class ChatThreadVM
    with
        ChangeNotifier,
        SubscriptionMixin,
        LoadingMixin,
        LifecycleAware,
        WorkManagerMixin {
  final EventHandlerBase<ChatThreadVM> _eventHandler;
  final ChatServiceBase _chatService;
  final MediaCacheManager _mediaCacheManager;
  final List<ChatThreadUIMessageModelBase> _messages = [];
  final String _chatId;
  RoomDetail? _chatDetail;

  int _unreadMarkerIndex = -1;
  int get unreadMarkerIndex => _unreadMarkerIndex;

  ChatThreadVM({
    required EventHandlerBase<ChatThreadVM> eventHandler,
    required ChatServiceBase chatService,
    required MediaCacheManager mediaCacheManager,
    required String chatId,
  })  : _eventHandler = eventHandler,
        _chatService = chatService,
        _mediaCacheManager = mediaCacheManager,
        _chatId = chatId {
    addSubscription(_chatService.outChatMessages.listen((event) {
      if (event is RoomEventMessageResponse && event.detail.roomId == _chatId) {
        // TODO: what if receive message too early before get RoomDetail, should we stash it?
        _addMessageAndSort(ChatThreadUIMessageModelBase.fromEventMessage(
          event.detail,
          _chatDetail!,
        ));
      }
      if (event is RoomEventSystemResponse && event.detail.roomId == _chatId) {
        // TODO: what if receive message too early before get RoomDetail, should we stash it?
        _addMessageAndSort(ChatThreadUIMessageModelBase.fromEventSystem(
          event.detail,
          _chatDetail!,
        ));
      }
      if (event is RoomStateChangedResponse) {
        _chatDetail = event.detail;
        notifyListeners();
      }
    }));
  }

  UserDetail? get myUser => _chatService.authenticatedUser;
  RoomDetail? get chatDetail => _chatDetail;
  List<ChatThreadUIMessageModelBase> get messages => _messages.toList();

  void startup() {
    // sync chat messages from some timestamp point
    _loadChatDetails().then((value) => _syncChatMessages());
  }

  void onScrollPositionChanged(Iterable<ItemPosition> position) {
    final lastItem = position.lastOrNull;
    if (lastItem?.index == _messages.length - 1) {
      if (_messages.isNotEmpty) {
        _syncChatMessages(_messages.last.timestamp);
      }
    }
  }

  void onMessageActionTap(ChatThreadUIEventMessage message) {
    _eventHandler.processEvent(
      EventOpenChatMessageAction(
        message: message,
        isMyMessage: message.senderId == myUser?.userId,
        onDownloadMedia: onDownloadMedia,
        onForward: () {
          debugPrint(">>> onForwardMessage");
        },
        onReply: () {
          debugPrint(">>> onReplyMessage");
        },
        onCopy: () {
          debugPrint(">>> onCopyMessage");
        },
        onDelete: () {
          debugPrint(">>> onDeleteMessage");
        },
      ),
      this,
    );
  }

  Future<Uint8List> onDownloadMedia(String mediaId) async {
    final cachedMedia = await _mediaCacheManager.getMedia(mediaId);
    if (cachedMedia == null) {
      final result = await _chatService.chatClient.downloadMedia(mediaId);
      await _mediaCacheManager.saveMedia(mediaId, result.content.bytes);
      return Uint8List.fromList(result.content.bytes);
    } else {
      return cachedMedia;
    }
  }

  void onOpenImagePreviewTap(Uint8List media) {
    _eventHandler.processEvent(EventOpenChatImagePreview(media), this);
  }

  Future _loadChatDetails() {
    changeLoading(true);
    return runWorker<ListRoomsResponse>(
      onRun: _chatService.chatClient.listRooms({_chatId}),
      onResult: (res) {
        if (res?.detail.isNotEmpty == true) {
          _chatDetail = res!.detail.firstOrNull;
          notifyListeners();
        }
        changeLoading(false);
      },
      onError: (error, stack) {
        changeLoading(false);
        _handleError(error, stack);
      },
    );
  }

  Future _syncChatMessages([DateTime? lastMessageTimestamp]) {
    changeLoading(true);
    SinceTimeFilter? timeFilter;
    if (lastMessageTimestamp != null) {
      timeFilter = SinceTimeFilter(
        sinceTime: lastMessageTimestamp,
        orderType: SinceTimeOrderType.sinceTimeOrderTypeOldest,
      );
    }
    return runWorker<SyncRoomsResponse>(
      onRun: _chatService.chatClient.syncRooms([
        SyncRoomFilter(
          roomId: _chatId,
          sinceTimeFilter: timeFilter,
          eventFilter: RoomEventType.roomEventTypeAll,
          eventLimit: 30,
        )
      ]),
      onResult: (res) {
        final eventsMessage = res?.messageEvents ?? [];
        final eventsSystem = res?.systemEvents ?? [];
        for (var event in eventsMessage) {
          final newMessage = ChatThreadUIMessageModelBase.fromEventMessage(
            event,
            _chatDetail!,
          );
          _addMessageAndSort(newMessage, shouldNotify: false);
        }
        for (var event in eventsSystem) {
          final newMessage = ChatThreadUIMessageModelBase.fromEventSystem(
            event,
            _chatDetail!,
          );
          _addMessageAndSort(newMessage, shouldNotify: false);
        }
        _findAndAddUnreadMarker();

        /// do not notify about changes, until ScrollController spam `_syncChatMessages` again
        if (eventsMessage.isNotEmpty || eventsSystem.isNotEmpty) {
          debugPrint(
              ">>> messageEvents.len=${eventsMessage.length} systemEvents.len=${eventsSystem.length}");
          notifyListeners();
        }
      },
      onError: (error, stack) {
        _handleError(error, stack);
      },
    );
  }

  void onAddNewMessage(
    EventMessageContentModelV1 message,
    List<MediaFileModel> attachments,
  ) {
    if (message.isEmpty && attachments.isEmpty) {
      return;
    }
    runWorker<RoomEventMessageResponse>(
      // TODO: upload files then use them as attachment
      onRun: Future(() async {
        final mediaContents = [
          for (final media in attachments)
            MediaContent(
              bytes: (await media.file.readAsBytes()).toList(),
              contentType: media.mimeType,
            )
        ];
        final UploadMediaResponse? attachResponse = (mediaContents.isEmpty)
            ? null
            : await _chatService.chatClient.uploadMedia(
                mediaContents,
                timeoutMillis: 10000,
              );
        final uploadedMediaIds = attachResponse?.mediaIds ?? [];
        return _chatService.chatClient.addRoomEventMessage(
          _chatId,
          uploadedMediaIds,
          message.serialize(),
          message.version,
        );
      }),
      onResult: (res) {
        if (res == null) {
          return;
        }
        // TODO: what if receive message too early before get RoomDetail, should we stash it?
        _addMessageAndSort(ChatThreadUIMessageModelBase.fromEventMessage(
          res.detail,
          chatDetail!,
        ));
      },
      onError: (error, stack) {
        _handleError(error, stack);
      },
    );
  }

  Future<List<MediaFileModel>> onAddAttachment() {
    final completer = Completer<List<MediaFileModel>>();
    _eventHandler.processEvent(
      EventShowPhotoSourceDialog(
        onCamera: () async {
          final image =
              await ImageUtil.takePictureFromCamera(preferFront: false);
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
      ),
      this,
    );
    return completer.future;
  }

  void _findAndAddUnreadMarker() {
    if (_chatDetail == null) {
      return;
    }
    _messages
        .removeWhere((e) => e.eventId == ChatThreadUIEventUnread.keyEventId);
    final userUnreadDate = _chatDetail!.members
            .firstWhereOrNull(
                (e) => e.userId == _chatService.authenticatedUser?.userId)
            ?.lastReadMarker ??
        Constants.defaultLastReadMarkerDate;
    ChatThreadUIMessageModelBase? firstUnread;
    firstUnread = _messages.reversed
        .firstWhereOrNull((e) => e.timestamp.compareTo(userUnreadDate) > 0);
    if (firstUnread != null) {
      _addMessageAndSort(
        ChatThreadUIMessageModelBase.fromUnread(firstUnread.timestamp),
        shouldNotify: false,
      );
    }
    _unreadMarkerIndex = _messages
        .indexWhere((e) => e.eventId == ChatThreadUIEventUnread.keyEventId);
  }

  void _addMessageAndSort(
    ChatThreadUIMessageModelBase model, {
    bool shouldNotify = true,
  }) {
    if (!_messages.any((e) => e.eventId == model.eventId)) {
      _messages.add(model);
      _sortMessages();
    }
    if (shouldNotify) {
      notifyListeners();
    }
  }

  void _sortMessages() {
    // ListView is reversed, so let's sort like that
    _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void _handleError(error, StackTrace stack) {
    debugPrint("$error\n$stack", wrapWidth: 1000);
  }

  @override
  void dispose() {
    onLifecycleEvent(LifecycleEvent.pop);
    cancelSubscriptions();
    cancelWorkers();
    super.dispose();
  }
}
