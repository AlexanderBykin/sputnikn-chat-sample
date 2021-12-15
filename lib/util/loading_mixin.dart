import 'package:flutter/foundation.dart';

mixin LoadingMixin on ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void changeLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
