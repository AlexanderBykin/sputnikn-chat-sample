import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:sputnikn_chatsample/model/create_chat_model.dart';
import 'package:sputnikn_chatsample/screens/chat_create/selectable_member_vm.dart';
import 'package:sputnikn_chatsample/services/chat_service/chat_service_base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sputnikn_chatsample/util/event_handler_base.dart';
import 'package:sputnikn_chatsample/util/loading_mixin.dart';
import 'package:sputnikn_chatsample/util/work_manager_mixin.dart';

class ChatCreateVM
    with ChangeNotifier, LoadingMixin, LifecycleAware, WorkManagerMixin {
  final EventHandlerBase<ChatCreateVM> _eventHandler;
  final ChatServiceBase _chatService;
  final List<SelectableMemberVM> _members = [];
  String _title = "";
  String? _avatar;

  ChatCreateVM({
    required EventHandlerBase<ChatCreateVM> eventHandler,
    required ChatServiceBase chatService,
  })  : _eventHandler = eventHandler,
        _chatService = chatService;

  void startup() {
    _members.clear();
    _loadUsers();
  }

  List<SelectableMemberVM> get members => List.of(_members);
  String get title => _title;
  String? get avatar => _avatar;

  set title(String value) {
    _title = value;
    notifyListeners();
  }

  set avatar(String? value) {
    _avatar = value;
    notifyListeners();
  }

  void onSaveTap() {
    final memberIds = _members
        .where((e) => e.isSelected)
        .map((e) => e.member.userId)
        .toList();
    if (memberIds.length < 2) {
      return;
    }
    _eventHandler.processEvent(
      EventNavigateBack(CreateChatModel(
        _title,
        _avatar,
        memberIds,
      )),
      this,
    );
  }

  Future _loadUsers() {
    changeLoading(true);
    return runWorker<ListUsersResponse>(
      onRun: _chatService.chatClient.listUsers(),
      onResult: (res) {
        final users = res?.users ?? [];
        for (var e in users) {
          _members.add(SelectableMemberVM(e));
        }
        notifyListeners();
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

  @override
  void dispose() {
    onLifecycleEvent(LifecycleEvent.pop);
    cancelWorkers();
    super.dispose();
  }
}
