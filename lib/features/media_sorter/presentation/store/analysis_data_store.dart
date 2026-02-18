import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/sort_status_data_store.dart';

class AnalysisDataStore extends ChangeNotifier {
  final Map<String, AnalysisResult> _analysisResults = {};
  
  // Getter for the data
  Map<String, AnalysisResult> get analysisResults => _analysisResults;

  AnalysisResult getAnalysisResult(String sheetName) {
    return _analysisResults[sheetName] ??= AnalysisResult.empty();
  }

  // Method to update data (called by SortController)
  void updateResults(String currentSheetName, AnalysisResult newResult) {
    _analysisResults[currentSheetName] = newResult;
    if (newResult.validRowIndexes.isEmpty) {
      newResult.bestMediaSortOrder = null;
    }
    
    // This broadcasts a signal to all listeners that the data changed
    notifyListeners();
  }
}