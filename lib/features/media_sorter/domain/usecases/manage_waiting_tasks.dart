class ManageWaitingTasks<T> {
  bool _isCalculating = false;
  bool _waitingNewCalculation = false;
  
  Future<void> execute(Future<T> Function() task, {void Function(T)? onComplete}) async {
    _waitingNewCalculation = true;
    if (_isCalculating) {
      return;
    }
    _isCalculating = true;
    dynamic result;

    while (_waitingNewCalculation) {
      _waitingNewCalculation = false;
      result = await task();
    }
    onComplete?.call(result as T);
    _isCalculating = false;
  }
}