import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';

class AnalysisCache extends ChangeNotifier {
  final Map<String, AnalysisResult> _analysisResults = {};

  final LoadedSheetsCache loadedSheetsDataStore;

  AnalysisResult _getAnalysisResult(String sheetId) {
    if (!_analysisResults.containsKey(sheetId)) {
      throw Exception('Sheet $sheetId not found in AnalysisCache');
    }
    return _analysisResults[sheetId]!;
  }

  AnalysisResult getAnalysisResult(String sheetId) {
    return _getAnalysisResult(sheetId).clone();
  }

  void updateResults(String sheetId, AnalysisResult newResult) {
    _analysisResults[sheetId] = newResult;
    notifyListeners();
  }

  AnalysisCache(this.loadedSheetsDataStore);
}
