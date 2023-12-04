import 'package:bloc/bloc.dart';
import 'package:chat_client_repository/chat_client_repository.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:sputnikn_chatsample/core/core.dart';
import 'package:sputnikn_chatsample/pages/chat_list/models/models.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState>
    with SubscriptionMixin {
  ChatListBloc({
    required ChatClientRepository chatClientRepository,
  })  : _chatClientRepository = chatClientRepository,
        super(const ChatListState()) {
    on<FetchRoomListSubmitted>(_onFetchRoomListSubmitted);
    on<ChangeRoomSubmitted>(_onChangeRoomSubmitted);
    on<NewRoomSubmitted>(_onNewRoomSubmitted);
    addSubscription(
      _chatClientRepository.outChatMessages.listen((event) {
        // Some room changed and we received state, lets apply it
        if (event is RoomStateChangedResponse) {
          final changedRoom = state.rooms
              .firstWhereOrNull((e) => e.roomId == event.detail.roomId)
              ?.copyWith(
                title: event.detail.title,
                avatar: event.detail.avatar,
                members: event.detail.members
                    .map(ChatRoomMemberModel.fromResponse)
                    .toList(),
                eventMessageUnreadCount: event.detail.eventMessageUnreadCount,
                eventSystemUnreadCount: event.detail.eventSystemUnreadCount,
              );
          if (changedRoom == null) {
            return;
          }
          add(ChangeRoomSubmitted(changedRoom));
        }
        // Some message came to Room, lets apply it to LastMessage
        if (event is RoomEventMessageResponse) {
          final changedRoom = state.rooms
              .firstWhereOrNull((e) => e.roomId == event.detail.roomId)
              ?.copyWith(
                lastMessage: RoomLastMessageModel.fromEvent(event.detail),
              );
          if (changedRoom == null) {
            return;
          }
          add(ChangeRoomSubmitted(changedRoom));
        }
        // Someone created new room with us as a member
        if (event is CreateRoomResponse) {
          add(
            NewRoomSubmitted(
              ChatRoomModel.fromResponse(
                event.detail,
                DateTime.now(),
              ),
            ),
          );
        }
      }),
    );
  }

  final ChatClientRepository _chatClientRepository;

  Future<void> _onFetchRoomListSubmitted(
    FetchRoomListSubmitted event,
    Emitter<ChatListState> emit,
  ) async {
    emit(state.copyWith(loadingStatus: ChatListLoadingStatus.loading));
    try {
      final syncResult = await _chatClientRepository.smartSyncRooms();
      final listRooms = await _chatClientRepository.listRooms();
      final newRooms = <ChatRoomModel>[];
      for (final room in listRooms) {
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
        newRooms.add(
          ChatRoomModel.fromResponse(room).copyWith(
            lastMessage: (lastRoomMessage != null)
                ? RoomLastMessageModel.fromEvent(lastRoomMessage)
                : null,
          ),
        );
      }
      emit(
        state.copyWith(
          loadingStatus: ChatListLoadingStatus.success,
          rooms: newRooms..sortRooms(),
        ),
      );
    } catch (error) {
      print('[$runtimeType] $error');
      emit(
        state.copyWith(
          loadingStatus: ChatListLoadingStatus.failed,
          rooms: [],
        ),
      );
    }
  }

  void _onChangeRoomSubmitted(
    ChangeRoomSubmitted event,
    Emitter<ChatListState> emit,
  ) {
    final rooms = state.rooms
      ..removeWhere((e) => e.roomId == event.room.roomId)
      ..add(event.room);
    emit(state.copyWith(rooms: rooms..sortRooms()));
  }

  void _onNewRoomSubmitted(
    NewRoomSubmitted event,
    Emitter<ChatListState> emit,
  ) {
    final rooms = state.rooms..add(event.room);
    emit(state.copyWith(rooms: rooms..sortRooms()));
  }
}
