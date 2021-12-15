import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:sputnikn_chatsample/screens/chat_login/chat_login_event_handler.dart';
import 'package:sputnikn_chatsample/services/chat_service/chat_service_base.dart';
import 'package:sputnikn_chatsample/util/event_handler_base.dart';
import 'package:sputnikn_chatsample/util/loading_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:sputnikn_chatsample/util/work_manager_mixin.dart';

class ChatLoginVM
    with ChangeNotifier, LoadingMixin, LifecycleAware, WorkManagerMixin {
  final ChatServiceBase _chatService;
  final EventHandlerBase<ChatLoginVM> _eventHandler;

  String _login = "testuser1";
  String _password = "1";

  ChatLoginVM({
    required EventHandlerBase<ChatLoginVM> eventHandler,
    required ChatServiceBase chatService,
  })  : _eventHandler = eventHandler,
        _chatService = chatService;

  String get login => _login;

  set login(String value) {
    _login = value;
    notifyListeners();
  }

  String get password => _password;

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  void onAuthTap() {
    if (_login.isEmpty || _password.isEmpty || isLoading) {
      return;
    }
    _authUser();
  }

  Future _authUser() {
    changeLoading(true);
    return runWorker<UserDetail?>(
      onRun: _chatService.authUser(_login, _password),
      onResult: (res) {
        if (res != null) {
          _eventHandler.processEvent(EventNavigateChatList(), this);
        }
        changeLoading(false);
      },
      onError: (error, stack) {
        changeLoading(false);
        _handleError(error, stack);
      },
    );
  }

  void _handleError(dynamic error, dynamic stack) {
    debugPrint("$error\n$stack", wrapWidth: 1000);
  }
}
