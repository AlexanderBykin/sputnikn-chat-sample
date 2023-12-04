import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:chat_client_repository/chat_client_repository.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:sputnikn_chatsample/core/core.dart';
import 'package:sputnikn_chatsample/pages/chat_thread/models/models.dart';

part 'chat_thread_event.dart';
part 'chat_thread_state.dart';

class ChatThreadBloc extends Bloc<ChatThreadEvent, ChatThreadState>
    with SubscriptionMixin {
  ChatThreadBloc({
    required String chatId,
    required ChatClientRepository chatClientRepository,
    required MediaCacheManager mediaCacheManager,
  })  : _chatClientRepository = chatClientRepository,
        _mediaCacheManager = mediaCacheManager,
        super(
          ChatThreadState(
            chatId: chatId,
          ),
        ) {
    on<FetchChatDetailSubmitted>(_onFetchChatDetailSubmitted);
    on<SyncChatMessagesSubmitted>(_onSyncChatMessagesSubmitted);
    on<ReceiveChatMessageSubmitted>(_onReceiveChatMessageSubmitted);
    on<ReceiveChatDetailSubmitted>(_onReceiveChatDetailSubmitted);
    on<AddNewChatMessageSubmitted>(_onAddNewChatMessageSubmitted);
    on<ChangeScrollPositionSubmitted>(_onChangeScrollPositionSubmitted);
    addSubscription(
      _chatClientRepository.outChatMessages.listen((event) {
        if (event is RoomEventMessageResponse &&
            event.detail.roomId == chatId) {
          // TODO: what if receive message too early before get RoomDetail, should we stash it?
          add(
            ReceiveChatMessageSubmitted(
              ChatThreadUIEventMessage.fromEventMessage(
                event.detail,
                state.chatDetail!,
              ),
            ),
          );
        }
        if (event is RoomEventSystemResponse && event.detail.roomId == chatId) {
          // TODO: what if receive message too early before get RoomDetail, should we stash it?
          add(
            ReceiveChatMessageSubmitted(
              ChatThreadUIEventSystem.fromEventSystem(
                event.detail,
                state.chatDetail!,
              ),
            ),
          );
        }
        if (event is RoomStateChangedResponse) {
          add(ReceiveChatDetailSubmitted(event.detail));
        }
      }),
    );
  }

  final ChatClientRepository _chatClientRepository;
  final MediaCacheManager _mediaCacheManager;

  UserDetail? get authenticatedUser => _chatClientRepository.authenticatedUser;

  Future<Uint8List> onDownloadMedia(String mediaId) async {
    try {
      final cachedMedia = await _mediaCacheManager.getMedia(mediaId);
      if (cachedMedia == null) {
        final result = await _chatClientRepository.downloadMedia(mediaId);
        await _mediaCacheManager.saveMedia(mediaId, result.bytes);
        return Uint8List.fromList(result.bytes);
      } else {
        return cachedMedia;
      }
    } catch (error) {
      return Uint8List(0);
    }
  }

  Future<void> _onFetchChatDetailSubmitted(
    FetchChatDetailSubmitted event,
    Emitter<ChatThreadState> emit,
  ) async {
    emit(state.copyWith(loadingStatus: ChatThreadLoadingStatus.loading));
    try {
      final rooms = await _chatClientRepository.listRooms(
        roomIds: {state.chatId},
      );
      emit(
        state.copyWith(
          loadingStatus: ChatThreadLoadingStatus.success,
          chatDetail: rooms.firstOrNull,
        ),
      );
      add(SyncChatMessagesSubmitted());
    } catch (error) {
      emit(state.copyWith(loadingStatus: ChatThreadLoadingStatus.failed));
    }
  }

  void _onChangeScrollPositionSubmitted(
    ChangeScrollPositionSubmitted event,
    Emitter<ChatThreadState> emit,
  ) {
    final lastItem = event.position.lastOrNull;

    /// user scroll to top, try to load oldest messages
    if (lastItem?.index == state.messages.length - 1) {
      final lastUnreadTime = state.messages.lastOrNull?.timestamp;

      /// Don't spam sync messages if lastUnreadTime equals to state
      if (state.messages.isNotEmpty && state.lastUnreadTime != lastUnreadTime) {
        add(
          SyncChatMessagesSubmitted(
            lastMessageTimestamp: lastUnreadTime,
          ),
        );
      }
    }
  }

  void _onReceiveChatMessageSubmitted(
    ReceiveChatMessageSubmitted event,
    Emitter<ChatThreadState> emit,
  ) {
    final newMessages = state.messages.toList()
      ..add(event.message)
      ..sortChatMessages();
    emit(state.copyWith(messages: newMessages));
  }

  Future<void> _onSyncChatMessagesSubmitted(
    SyncChatMessagesSubmitted event,
    Emitter<ChatThreadState> emit,
  ) async {
    emit(state.copyWith(loadingStatus: ChatThreadLoadingStatus.loading));
    SinceTimeFilter? timeFilter;
    if (event.lastMessageTimestamp != null) {
      timeFilter = SinceTimeFilter(
        sinceTime: event.lastMessageTimestamp!,
        orderType: SinceTimeOrderType.sinceTimeOrderTypeOldest,
      );
    }
    final syncRooms = await _chatClientRepository.syncRooms([
      SyncRoomFilter(
        roomId: state.chatId,
        sinceTimeFilter: timeFilter,
        eventFilter: RoomEventType.roomEventTypeAll,
        eventLimit: 30,
      )
    ]);
    final eventsMessage = syncRooms.messageEvents;
    final eventsSystem = syncRooms.systemEvents;

    if (eventsMessage.isNotEmpty || eventsSystem.isNotEmpty) {
      final newMessages = <ChatThreadUIMessageModelBase>[];
      for (final event in eventsMessage) {
        final newMessage = ChatThreadUIEventMessage.fromEventMessage(
          event,
          state.chatDetail!,
        );
        if (!newMessages.any((e) => e.eventId == newMessage.eventId)) {
          newMessages.add(newMessage);
        }
      }
      for (final event in eventsSystem) {
        final newMessage = ChatThreadUIEventSystem.fromEventSystem(
          event,
          state.chatDetail!,
        );
        if (!newMessages.any((e) => e.eventId == newMessage.eventId)) {
          newMessages.add(newMessage);
        }
      }
      newMessages.sortChatMessages();
      _findAndAddUnreadMarker(newMessages);
      final unreadIndex = _findUnreadMarkerIndex(newMessages);
      final lastUnreadTime = _findUnreadMarkerTime(newMessages);

      log('>>> messageEvents.len=${eventsMessage.length} systemEvents.len=${eventsSystem.length}');
      emit(
        state.copyWith(
          messages: newMessages,
          unreadMarkerIndex: unreadIndex,
          lastUnreadTime: lastUnreadTime,
          loadingStatus: ChatThreadLoadingStatus.success,
        ),
      );
    } else {
      emit(
        state.copyWith(
          loadingStatus: ChatThreadLoadingStatus.success,
        ),
      );
    }
  }

  void _onReceiveChatDetailSubmitted(
    ReceiveChatDetailSubmitted event,
    Emitter<ChatThreadState> emit,
  ) {
    emit(
      state.copyWith(
        chatDetail: event.roomDetail,
      ),
    );
  }

  Future<void> _onAddNewChatMessageSubmitted(
    AddNewChatMessageSubmitted event,
    Emitter<ChatThreadState> emit,
  ) async {
    if (event.message.isEmpty && event.attachments.isEmpty) {
      return;
    }
    // TODO: upload files then use them as attachment
    final mediaContents = [
      for (final media in event.attachments)
        MediaContent(
          bytes: (await media.file.readAsBytes()).toList(),
          contentType: media.mimeType,
        )
    ];
    final attachResponse = (mediaContents.isEmpty)
        ? <String>[]
        : await _chatClientRepository.uploadMedia(mediaContents);
    final result = await _chatClientRepository.addRoomEventMessage(
      state.chatId,
      attachResponse,
      event.message.serialize(),
      event.message.version,
    );
    // TODO: what if receive message too early before get RoomDetail, should we stash it?
    add(
      ReceiveChatMessageSubmitted(
        ChatThreadUIEventMessage.fromEventMessage(
          result,
          state.chatDetail!,
        ),
      ),
    );
  }

  int _findUnreadMarkerIndex(List<ChatThreadUIMessageModelBase> messages) {
    return messages
        .indexWhere((e) => e.eventId == ChatThreadUIEventUnread.keyEventId);
  }

  DateTime? _findUnreadMarkerTime(List<ChatThreadUIMessageModelBase> messages) {
    return messages
        .firstWhereOrNull(
            (e) => e.eventId == ChatThreadUIEventUnread.keyEventId)
        ?.timestamp;
  }

  void _findAndAddUnreadMarker(List<ChatThreadUIMessageModelBase> messages) {
    if (state.chatDetail == null) {
      return;
    }
    messages
        .removeWhere((e) => e.eventId == ChatThreadUIEventUnread.keyEventId);
    final userUnreadDate = state.chatDetail!.members
            .firstWhereOrNull((e) => e.userId == authenticatedUser?.userId)
            ?.lastReadMarker ??
        AppParams.defaultLastReadMarkerDate;
    ChatThreadUIMessageModelBase? firstUnread;
    firstUnread = messages.reversed
        .firstWhereOrNull((e) => e.timestamp.compareTo(userUnreadDate) > 0);
    if (firstUnread != null) {
      messages
        ..add(ChatThreadUIEventUnread.fromUnread(firstUnread.timestamp))
        ..sortChatMessages();
    }
  }
}

extension ChatMessageListExtension on List<ChatThreadUIMessageModelBase> {
  void sortChatMessages() {
    sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
