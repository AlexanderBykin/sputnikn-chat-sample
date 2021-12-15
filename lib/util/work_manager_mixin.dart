import 'dart:async';
import 'package:async/async.dart';
import 'package:lifecycle/lifecycle.dart';

mixin WorkManagerMixin on LifecycleAware {
  final List<CancelableOperation> _workers = [];
  LifecycleEvent? _currentLifecycleState;

  LifecycleEvent? get currentLifecycleState => _currentLifecycleState;

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    _currentLifecycleState = event;
  }

  void _addWorker<T>(CancelableOperation<T> worker) {
    _workers.add(worker);
  }

  Future<T?> runWorker<T>({
    required Future<T?> onRun,
    required Function(T?) onResult,
    Function(dynamic, StackTrace)? onError,
    bool forceResult = false,
  }) {
    final cancelableWorker = CancelableOperation.fromFuture(
      onRun.then((value) {
        return value;
      }).catchError((error, stack) {
        onError?.call(error, stack);
        return null;
      }),
    );
    _addWorker(cancelableWorker);
    return cancelableWorker.valueOrCancellation(null).then((value) {
      if (lifecycleEventsVisibleAndActive.contains(_currentLifecycleState) ||
          (forceResult && _currentLifecycleState != LifecycleEvent.pop)) {
          onResult(value);
      }
      return value;
    });
  }

  void cancelWorkers() {
    for (var worker in _workers) {
      if (worker.isCanceled == false) {
        worker.cancel();
      }
    }
    _workers.clear();
  }
}
