import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';

class AnalysisResultCache extends ChangeNotifier {
  final Map<String, AnalysisResult> _analysisResults = {};

  final LoadedSheetsCache loadedSheetsDataStore;

  AnalysisResult _getAnalysisResult(String sheetId) {
    return _analysisResults[sheetId]!;
  }

  Map<int, Map<int, List<SortingRule>>> getMyRules(String sheetId) {
    return _getAnalysisResult(sheetId).myRules;
  }

  AnalysisResult getAnalysisResult(String sheetId) {
    return _getAnalysisResult(sheetId);
  }

  bool validRowIndexesEmpty(String sheetId) {
    return _getAnalysisResult(sheetId).validRowIndexes.isEmpty;
  }

  bool myRulesEmpty(String sheetId) {
    return _getAnalysisResult(sheetId).myRules.isEmpty;
  }

  bool groupsToMaximizeEmpty(String sheetId) {
    return _getAnalysisResult(sheetId).groupsToMaximize.isEmpty;
  }

  bool toSort(String sheetId) {
    return _getAnalysisResult(sheetId).toSort;
  }

  bool sortedWithValidSort(String sheetId) {
    return _getAnalysisResult(sheetId).sortedWithValidSort;
  }

  void updateResults(String sheetId, AnalysisResult newResult) {
    _analysisResults[sheetId] = newResult;
    notifyListeners();
  }

  void setResultCalculated(String sheetId, bool resultCalculated) {
    _analysisResults[sheetId]!.resultCalculated = resultCalculated;
    notifyListeners();
  }

  void setSortedWithValidSort(String sheetId, bool sorted) {
    _analysisResults[sheetId]!.sortedWithValidSort = sorted;
    notifyListeners();
  }

  AnalysisResultCache(this.loadedSheetsDataStore);
}
