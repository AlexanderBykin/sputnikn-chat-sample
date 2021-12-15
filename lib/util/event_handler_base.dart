import 'package:flutter/widgets.dart';

abstract class EventHandlerMessageBase {}

class EventNavigateBack implements EventHandlerMessageBase {
  final Object? param;

  EventNavigateBack([this.param]);
}

class EventRunWithContext implements EventHandlerMessageBase {
  final Function(BuildContext) callback;

  EventRunWithContext(this.callback);
}

abstract class EventHandlerBase<TViewModel> {
  void processEvent(EventHandlerMessageBase event, TViewModel viewModel);

  void unhandledEvent(EventHandlerMessageBase event) {
    debugPrint(">>> Unhandled event '${event.runtimeType}'");
  }
}
