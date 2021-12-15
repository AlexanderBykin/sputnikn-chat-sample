import 'package:sputnikn_chat_client/sputnikn_chat_client.dart';
import 'package:flutter/foundation.dart';

class SelectableMemberVM with ChangeNotifier {
  final UserDetail member;
  bool _isSelected = false;

  SelectableMemberVM(this.member);

  bool get isSelected => _isSelected;
  set isSelected(bool value) {
    _isSelected = value;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectableMemberVM &&
          runtimeType == other.runtimeType &&
          member == other.member;

  @override
  int get hashCode => member.hashCode;
}
