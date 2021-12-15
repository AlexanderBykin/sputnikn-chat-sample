import 'dart:async';

mixin SubscriptionMixin {
  final List<StreamSubscription> _cleanUpSubscribers = [];

  void addSubscription(StreamSubscription subscription) {
    _cleanUpSubscribers.add(subscription);
  }

  void cancelSubscriptions() {
    for (var e in _cleanUpSubscribers) {
      e.cancel();
    }
    _cleanUpSubscribers.clear();
  }
}
