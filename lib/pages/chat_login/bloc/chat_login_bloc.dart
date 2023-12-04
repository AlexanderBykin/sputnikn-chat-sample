import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_client_repository/chat_client_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'chat_login_event.dart';
part 'chat_login_state.dart';

class ChatLoginBloc extends Bloc<ChatLoginEvent, ChatLoginState> {
  ChatLoginBloc({
    required ChatClientRepository chatClientRepository,
  })  : _chatClientRepository = chatClientRepository,
        super(
          const ChatLoginState(
            login: 'testuser1',
            password: '1',
          ),
        ) {
    on<ChangeLoginSubmitted>(_onChangeLoginSubmitted);
    on<ChangePasswordSubmitted>(_onChangePasswordSubmitted);
    on<SignInSubmitted>(_onSignInSubmitted);
  }

  final ChatClientRepository _chatClientRepository;

  void _onChangeLoginSubmitted(
    ChangeLoginSubmitted event,
    Emitter<ChatLoginState> emit,
  ) {
    emit(state.copyWith(login: event.login));
  }

  void _onChangePasswordSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChatLoginState> emit,
  ) {
    emit(state.copyWith(password: event.password));
  }

  Future<void> _onSignInSubmitted(
    SignInSubmitted event,
    Emitter<ChatLoginState> emit,
  ) async {
    if (state.login.isEmpty || state.password.isEmpty) {
      return;
    }
    emit(state.copyWith(loadingStatus: ChatLoginLoadingStatus.loading));
    try {
      final result = await _chatClientRepository.authUser(
        login: state.login,
        password: state.password,
      );
      emit(
        state.copyWith(
          loadingStatus: ChatLoginLoadingStatus.success,
          authStatus: ChatLoginAuthStatus.success,
        ),
      );
    } catch (error) {
      emit(state.copyWith(loadingStatus: ChatLoginLoadingStatus.failed));
    }
  }
}
