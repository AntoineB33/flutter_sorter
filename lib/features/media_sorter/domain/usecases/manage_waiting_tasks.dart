class ManageWaitingTasks {
  bool _isCalculating = false;
  bool _waitingNewCalculation = false;
  
  Future<void> execute(Future<void> Function() task) async {
    _waitingNewCalculation = true;
    if (_isCalculating) {
      return;
    }
    _isCalculating = true;
    // notifyListeners(); // Update UI to show loading spinner

    while (_waitingNewCalculation) {
      _waitingNewCalculation = false;
      await task();
    }
    _isCalculating = false;
  }
}