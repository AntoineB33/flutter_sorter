import 'dart:async';
import 'dart:isolate';
import '../logger.dart';

class OneSlotExecutor<T> {
  bool _isRunning = false;
  
  // We need to store the input data and the static function, not a closure
  _TaskDefinition<T>? _nextTask;

  void run(FutureOr<void> Function(T) function, T message) {
    if (!_isRunning) {
      _execute(function, message);
      return;
    }
    _nextTask = _TaskDefinition(function, message);
  }

  Future<void> _execute(FutureOr<void> Function(T) function, T message) async {
    _isRunning = true;
    try {
      // Isolate.run will work because we are passing a function pointer
      // and a specific data object, not a closure with captured state.
      await Isolate.run(() => function(message));
    } catch (e) {
      log.warning('Executor Error: $e');
    } finally {
      if (_nextTask != null) {
        final next = _nextTask!;
        _nextTask = null;
        scheduleMicrotask(() => _execute(next.function, next.message));
      } else {
        _isRunning = false;
      }
    }
  }
}

class _TaskDefinition<T> {
  final FutureOr<void> Function(T) function;
  final T message;
  _TaskDefinition(this.function, this.message);
}