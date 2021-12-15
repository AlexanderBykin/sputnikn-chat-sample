import 'package:lifecycle/lifecycle.dart';
import 'package:sputnikn_chatsample/model/room_last_message_model.dart';
import 'package:sputnikn_chatsample/screens/chat_list/chat_list_event_handler.dart';
import 'package:sputnikn_chatsample/screens/chat_list/chat_room_member_vm.dart';
import 'package:sputnikn_chatsample/util/event_handler_base.dart';
import 'package:sputnikn_chatsample/util/loading_mixin.dart';
import 'package:flutter/widgets.dart';
import 'package:sputnikn_chatsample/services/chat_service/chat_service_base.dart';
import 'package:sputnikn_chatsample/util/subscription_mixin.dart';
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:flutter/foundation.dart';
import 'package:sputnikn_chatsample/util/work_manager_mixin.dart';
import 'chat_room_vm.dart';
import 'package:collection/collection.dart';

class ChatListVM
    with
        ChangeNotifier,
        SubscriptionMixin,
        LoadingMixin,
        LifecycleAware,
        WorkManagerMixin {
  final EventHandlerBase<ChatListVM> _eventHandler;
  final ChatServiceBase _chatService;
  final _rooms = <ChatRoomVM>[];

  ChatListVM({
    required EventHandlerBase<ChatListVM> eventHandler,
    required ChatServiceBase chatService,
  })  : _eventHandler = eventHandler,
        _chatService = chatService {
    addSubscription(_chatService.outChatMessages.listen((event) {
      // Some room changed and we received state, lets apply it
      if (event is RoomStateChangedResponse) {
        _rooms.firstWhereOrNull((e) => e.roomId == event.detail.roomId)?.update(
              title: event.detail.title,
              avatar: event.detail.avatar,
              members: event.detail.members
                  .map((e) => ChatRoomMemberVM.fromResponse(e))
                  .toList(),
              eventMessageUnreadCount: event.detail.eventMessageUnreadCount,
              eventSystemUnreadCount: event.detail.eventSystemUnreadCount,
            );
        _rooms.sortRooms();
        notifyListeners();
      }
      // Some message came to Room, lets apply it to LastMessage
      if (event is RoomEventMessageResponse) {
        _rooms.firstWhereOrNull((e) => e.roomId == event.detail.roomId)?.update(
              lastMessage: RoomLastMessageModel.fromEvent(event.detail),
            );
        _rooms.sortRooms();
        notifyListeners();
      }
      // Someone created new room with us as a member
      if (event is CreateRoomResponse) {
        _rooms.add(ChatRoomVM.fromResponse(event.detail, DateTime.now()));
        _rooms.sortRooms();
        notifyListeners();
      }
    }));
  }

  void startup() {
    if (_chatService.isSocketConnected) {
      _syncRooms();
    }
  }

  List<ChatRoomVM> get rooms => List.of(_rooms, growable: false);

  Future _syncRooms() {
    _rooms.clear();
    changeLoading(true);
    return runWorker<List>(
      onRun: Future(() async {
        final syncResult = await _chatService.chatClient.smartSyncRooms();
        final listRooms =
            await _chatService.chatClient.listRooms({}, isOffline: false);
        return [syncResult, listRooms];
      }),
      onResult: (res) {
        final syncResult = res?[0] as SyncRoomsResponse?;
        final listRooms = res?[1] as ListRoomsResponse?;
        if (syncResult != null && listRooms != null) {
          for (var room in listRooms.detail) {
            final lastRoomMessage = syncResult.messageEvents
                .where((r) => r.roomId == room.roomId)
                .fold<RoomEventMessageDetail?>(null, (previousValue, element) {
              if (previousValue == null) {
                return element;
              } else {
                final aDate = previousValue.createTimestamp;
                final bDate = element.createTimestamp;
                return (aDate.compareTo(bDate) > 0) ? previousValue : element;
              }
            });
            _rooms.add(ChatRoomVM.fromResponse(room)
              ..update(
                lastMessage: (lastRoomMessage != null)
                    ? RoomLastMessageModel.fromEvent(lastRoomMessage)
                    : null,
              ));
          }
          _rooms.sortRooms();
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

  Future _createRoom(String title, String? avatar, List<String> memberIds) {
    changeLoading(true);
    return runWorker<CreateRoomResponse>(
      onRun: _chatService.chatClient.createRoom(title, avatar, memberIds),
      onResult: (res) {
        if (res != null) {
          _rooms.add(ChatRoomVM.fromResponse(res.detail, DateTime.now()));
          _rooms.sortRooms();
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

  void onCreateRoomTap() {
    _eventHandler.processEvent(
      EventNavigateCreateRoom((value) {
        if (value == null) {
          return;
        }
        _createRoom(value.title, value.avatar, value.memberIds);
      }),
      this,
    );
  }

  void onChatItemTap(String chatId) {
    _eventHandler.processEvent(EventNavigateChatThread(chatId), this);
  }

  @override
  void dispose() {
    onLifecycleEvent(LifecycleEvent.pop);
    cancelWorkers();
    cancelSubscriptions();
    super.dispose();
  }

  void _handleError(dynamic error, dynamic stack) {
    debugPrint("$error\n$stack", wrapWidth: 1000);
  }
}

extension RoomListExtension on List<ChatRoomVM> {
  void sortRooms() {
    sort((roomA, roomB) {
      return roomB.lastActivity.compareTo(roomA.lastActivity);
    });
  }
}
