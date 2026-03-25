import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';

class AnalysisResultCache {
  final Map<String, AnalysisResult> _analysisResults = {};

  final LoadedSheetsCache loadedSheetsDataStore;

  bool isFindingBestSort(int sheetId) {
    return _getAnalysisResult(sheetId).isFindingBestSort;
  }

  bool bestSortPossibleFound(int sheetId) {
    return _getAnalysisResult(sheetId).bestSortPossibleFound;
  }

  bool sortedWithCurrentBestSort(int sheetId) {
    return _getAnalysisResult(sheetId).sortedWithCurrentBestSort;
  }

  List<bool> isMedium(int sheetId) {
    return _getAnalysisResult(sheetId).isMedium;
  }

  AnalysisResult _getAnalysisResult(int sheetId) {
    return _analysisResults[sheetId]!;
  }

  Map<int, Map<int, List<SortingRule>>> getMyRules(int sheetId) {
    return _getAnalysisResult(sheetId).myRules;
  }

  List<List<int>> getGroupAttribution(int sheetId) {
    return _getAnalysisResult(sheetId).groupAttribution;
  }

  AnalysisResult getAnalysisResult(int sheetId) {
    return _getAnalysisResult(sheetId);
  }

  bool validRowIndexesEmpty(int sheetId) {
    return _getAnalysisResult(sheetId).validRowIndexes.isEmpty;
  }

  bool myRulesEmpty(int sheetId) {
    return _getAnalysisResult(sheetId).myRules.isEmpty;
  }

  bool groupsToMaximizeEmpty(int sheetId) {
    return _getAnalysisResult(sheetId).groupsToMaximize.isEmpty;
  }

  bool isSortedWithValidSort(int sheetId) {
    return _getAnalysisResult(sheetId).sortedWithValidSort;
  }

  void setSortedWithCurrentBestSort(int sheetId, bool value) {
    _getAnalysisResult(sheetId).sortedWithCurrentBestSort = value;
  }

  void setFindingBestSort(int sheetId, bool findingBestSort) {
    _analysisResults[sheetId]!.isFindingBestSort = findingBestSort;
  }

  void updateResults(int sheetId, AnalysisResult newResult) {
    _analysisResults[sheetId] = newResult;
  }

  void setSortedWithValidSort(int sheetId, bool sorted) {
    _analysisResults[sheetId]!.sortedWithValidSort = sorted;
  }

  void addNewAnalysisResult(int sheetId) {
    _analysisResults[sheetId] = AnalysisResult.empty();
  }

  void setValidSortIsImpossible(int sheetId, bool impossible) {
    _analysisResults[sheetId]!.validSortIsImpossible = impossible;
  }

  AnalysisResultCache(this.loadedSheetsDataStore);
}
