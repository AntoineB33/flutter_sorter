import 'package:flutter/material.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/usecases/analyze_table_usecase.dart';

class SpreadsheetController extends ChangeNotifier {
  final AnalyzeTableUseCase _analyzeUseCase;
  
  SpreadsheetController(this._analyzeUseCase);

  AnalysisResult? _result;
  bool _isCalculating = false;
  bool _waitingNewCalculation = false;

  AnalysisResult? get result => _result;
  bool get isCalculating => _isCalculating;

  Future<void> onCtrlCPressed() async {
    _waitingNewCalculation = true;
    if (_isCalculating) {
      return;
    }
    _isCalculating = true;
    // notifyListeners(); // Update UI to show loading spinner

    while (_waitingNewCalculation) {
      _waitingNewCalculation = false;
      try {
        // Call the domain layer
        _result = await _analyzeUseCase.execute();
      } catch (e) {
        // Handle errors
      } finally {
        _isCalculating = false;
        notifyListeners(); // Update UI to show result in sidebar
      }
    }
  }
}