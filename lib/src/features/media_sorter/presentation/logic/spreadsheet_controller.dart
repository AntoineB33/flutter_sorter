import 'package:flutter/material.dart';
import 'dart:math'; // Import for min/max
import '../../domain/entities/analysis_result.dart';
import '../../domain/usecases/analyze_table_usecase.dart';
import '../../domain/usecases/copy_selection_usecase.dart';

class SpreadsheetController extends ChangeNotifier {
  final AnalyzeTableUseCase _analyzeUseCase;
  final CopySelectionUseCase _copyUseCase;

  Point<int>? _selectionStart;
  Point<int>? _selectionEnd;
  
  SpreadsheetController(this._analyzeUseCase, this._copyUseCase);

  AnalysisResult? _result;
  bool _isCalculating = false;
  bool _waitingNewCalculation = false;

  AnalysisResult? get result => _result;
  bool get isCalculating => _isCalculating;

  Future<void> calculate() async {
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
        notifyListeners(); // Update UI with new result
      }
    }
    _isCalculating = false;
  }

  Future<String?> copySelectionToClipboard() async {
    if (_selectionStart == null || _selectionEnd == null) return null;

    // The Controller just passes the "Intent" and the "Context" (coordinates)
    return await _copyUseCase.execute(_selectionStart!, _selectionEnd!);
    
    // Optional: Show a snackbar or feedback
  }
}