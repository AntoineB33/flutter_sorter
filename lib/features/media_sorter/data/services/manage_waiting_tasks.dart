import 'dart:async';

import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/core/error/failures.dart';

class ManageWaitingTasks<T> {
  bool _isCalculating = false;
  bool _waitingNewCalculation = false;
  bool _isDisposed = false;
  Duration? lastCalculationDuration;
  Timer? _delayTimer;
  Completer<void>? _delayCompleter;
  final StreamController<Failure> failureController;

  ManageWaitingTasks(this.lastCalculationDuration, this.failureController);
  
  Future<dynamic> execute(Future<T> Function() task, {void Function(T)? onComplete}) async {
    _waitingNewCalculation = true;
    if (_isCalculating) {
      return;
    }
    _isCalculating = true;
    dynamic result;

    while (_waitingNewCalculation) {
      _waitingNewCalculation = false;
      try {
        result = await task();
      } on CacheException catch (e) {
        failureController.add(CacheFailure(e));
      }
      
      // If disposed during the task execution, break out immediately
      if (_isDisposed) continue;

      final delayDuration = lastCalculationDuration ?? Duration.zero;
      
      if (delayDuration > Duration.zero) {
        _delayCompleter = Completer<void>();
        
        // Start the timer
        _delayTimer = Timer(delayDuration, () {
          if (!(_delayCompleter?.isCompleted ?? true)) {
            _delayCompleter?.complete();
          }
        });
        
        // Wait for the timer to finish naturally OR be forced to complete by dispose()
        await _delayCompleter!.future;
      }
    }
    onComplete?.call(result as T);
    _isCalculating = false;
  }
  
  /// Cancels any active delays and stops the execution loop safely.
  void dispose() {
    _isDisposed = true;
    _waitingNewCalculation = false;
    
    // 1. Stop the timer from ticking
    _delayTimer?.cancel();
    
    // 2. Resolve the Future immediately so the while loop unblocks and exits
    if (_delayCompleter != null && !_delayCompleter!.isCompleted) {
      _delayCompleter!.complete();
    }
  }
}