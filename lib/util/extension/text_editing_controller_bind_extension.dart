import 'package:flutter/widgets.dart';

extension TextEditingControllerBindExtension on TextEditingController {
  void bindOneWay({
    required String Function() valueGetter,
    required void Function(String) valueSetter,
  }) {
    if (text != valueGetter()) {
      text = valueGetter();
    }
    addListener(() {
      valueSetter(text);
    });
  }

  void bindTwoWay({
    required ChangeNotifier sourceNotifier,
    required String Function() valueGetter,
    required void Function(String) valueSetter,
  }) {
    if (text != valueGetter()) {
      text = valueGetter();
    }
    addListener(() {
      valueSetter(text);
    });
    sourceNotifier.addListener(() {
      if (text != valueGetter()) {
        text = valueGetter();
      }
    });
  }
}
