part of 'chat_create_bloc.dart';

enum ChatCreateLoadingStatus {
  loading,
  success,
  failed,
}

enum ChatCreateStatus {
  none,
  chatCreated,
}

@immutable
class ChatCreateState extends Equatable {
  const ChatCreateState({
    this.title = '',
    this.avatar,
    this.members = const [],
    this.selectedMemberIds = const [],
    this.loadingStatus = ChatCreateLoadingStatus.success,
    this.chatCreateStatus = ChatCreateStatus.none,
    this.createdRoom,
  });

  final String title;
  final String? avatar;
  final List<UserDetail> members;
  final List<String> selectedMemberIds;
  final ChatCreateLoadingStatus loadingStatus;
  final ChatCreateStatus chatCreateStatus;
  final RoomDetail? createdRoom;

  ChatCreateState copyWith({
    String? title,
    String? avatar,
    List<UserDetail>? members,
    List<String>? selectedMemberIds,
    ChatCreateLoadingStatus? loadingStatus,
    ChatCreateStatus? chatCreateStatus,
    RoomDetail? createdRoom,
  }) {
    return ChatCreateState(
      title: title ?? this.title,
      avatar: avatar ?? this.avatar,
      members: members ?? this.members,
      selectedMemberIds: selectedMemberIds ?? this.selectedMemberIds,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      chatCreateStatus: chatCreateStatus ?? this.chatCreateStatus,
      createdRoom: createdRoom,
    );
  }

  @override
  List<Object?> get props => [
        title,
        avatar,
        members,
        selectedMemberIds,
        loadingStatus,
        chatCreateStatus,
        createdRoom,
      ];
}
