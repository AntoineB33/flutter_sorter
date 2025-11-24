// logic/async_utils.dart
import 'dart:async';
import '../logger.dart';

class OneSlotExecutor {
  bool _isRunning = false;
  Future<void> Function()? _nextTask;

  void run(Future<void> Function() task) {
    if (!_isRunning) {
      _execute(task);
      return;
    }
    
    // If busy, queue this task (replacing any previously queued task)
    _nextTask = task;
  }

  Future<void> _execute(Future<void> Function() task) async {
    _isRunning = true;
    try {
      await task();
    } catch (e) {
      // Depending on your logger setup, you might import it here
      log.warning('Executor Error: $e');
    } finally {
      if (_nextTask != null) {
        final next = _nextTask!;
        _nextTask = null;
        scheduleMicrotask(() => _execute(next));
      } else {
        _isRunning = false;
      }
    }
  }
}