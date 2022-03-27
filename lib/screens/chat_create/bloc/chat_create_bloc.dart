import 'package:bloc/bloc.dart';
import 'package:chat_client_repository/chat_client_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';

part 'chat_create_event.dart';
part 'chat_create_state.dart';

class ChatCreateBloc extends Bloc<ChatCreateEvent, ChatCreateState> {
  ChatCreateBloc({
    required ChatClientRepository chatClientRepository,
  })  : _chatClientRepository = chatClientRepository,
        super(const ChatCreateState()) {
    on<FetchUsersSubmitted>(_onFetchUsersSubmitted);
    on<MemberChangeSelectionSubmitted>(_onMemberChangeSelectionSubmitted);
    on<CreateChatSubmitted>(_onCreateChatSubmitted);
  }

  final ChatClientRepository _chatClientRepository;

  Future<void> _onFetchUsersSubmitted(
    FetchUsersSubmitted event,
    Emitter<ChatCreateState> emit,
  ) async {
    emit(state.copyWith(loadingStatus: ChatCreateLoadingStatus.loading));
    try {
      final result = await _chatClientRepository.listUsers();
      emit(
        state.copyWith(
          loadingStatus: ChatCreateLoadingStatus.success,
          members: result,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          loadingStatus: ChatCreateLoadingStatus.failed,
        ),
      );
    }
  }

  void _onMemberChangeSelectionSubmitted(
    MemberChangeSelectionSubmitted event,
    Emitter<ChatCreateState> emit,
  ) {
    final memberExists =
        state.selectedMemberIds.any((e) => event.member.userId == e);
    if (memberExists) {
      emit(
        state.copyWith(
          selectedMemberIds: state.selectedMemberIds..add(event.member.userId),
        ),
      );
    } else {
      emit(
        state.copyWith(
          selectedMemberIds: state.selectedMemberIds
            ..remove(event.member.userId),
        ),
      );
    }
  }

  Future<void> _onCreateChatSubmitted(
    CreateChatSubmitted event,
    Emitter<ChatCreateState> emit,
  ) async {
    if (state.selectedMemberIds.length < 2) {
      return;
    }
    emit(state.copyWith(loadingStatus: ChatCreateLoadingStatus.loading));
    try {
      final result = await _chatClientRepository.createRoom(
        title: event.title,
        avatar: event.avatar,
        memberIds: state.selectedMemberIds.toList(),
      );
      emit(
        state.copyWith(
          loadingStatus: ChatCreateLoadingStatus.success,
          chatCreateStatus: ChatCreateStatus.chatCreated,
          createdRoom: result,
        ),
      );
    } catch (error) {
      emit(state.copyWith(loadingStatus: ChatCreateLoadingStatus.failed));
    }
  }
}
