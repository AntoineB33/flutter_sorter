import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';

class AnalysisResultCache {
  final Map<String, AnalysisResult> _analysisResults = {};

  final LoadedSheetsCache loadedSheetsDataStore;

  bool getFindingBestSort(String sheetId) {
    return _getAnalysisResult(sheetId).isFindingBestSort;
  }

  bool bestSortPossibleFound(String sheetId) {
    return _getAnalysisResult(sheetId).bestSortPossibleFound;
  }

  bool sortedWithCurrentBestSort(String sheetId) {
    return _getAnalysisResult(sheetId).sortedWithValidSort;
  }

  List<bool> isMedium(String sheetId) {
    return _getAnalysisResult(sheetId).isMedium;
  }

  AnalysisResult _getAnalysisResult(String sheetId) {
    return _analysisResults[sheetId]!;
  }

  Map<int, Map<int, List<SortingRule>>> getMyRules(String sheetId) {
    return _getAnalysisResult(sheetId).myRules;
  }

  List<List<int>> getGroupAttribution(String sheetId) {
    return _getAnalysisResult(sheetId).groupAttribution;
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

  bool sortedWithValidSort(String sheetId) {
    return _getAnalysisResult(sheetId).sortedWithValidSort;
  }

  void updateResults(String sheetId, AnalysisResult newResult) {
    _analysisResults[sheetId] = newResult;
  }

  void setSortedWithValidSort(String sheetId, bool sorted) {
    _analysisResults[sheetId]!.sortedWithValidSort = sorted;
  }

  void addNewAnalysisResult(String sheetId) {
    _analysisResults[sheetId] = AnalysisResult.empty();
  }

  AnalysisResultCache(this.loadedSheetsDataStore);
}
