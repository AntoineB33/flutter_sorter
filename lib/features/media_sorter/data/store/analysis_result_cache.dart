import 'package:trying_flutter/features/media_sorter/domain/models/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/sorting_rule.dart';

class AnalysisResultCache {
  final Map<int, AnalysisResult> _analysisResults = {};

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

  bool isSortedWithValidSort(int sheetId) {
    return _getAnalysisResult(sheetId).sortedWithValidSort;
  }

  bool isCurrentBestSortAlwaysApplied(int sheetId) {
    return _getAnalysisResult(sheetId).toAlwaysApplyCurrentBestSort;
  }

  void setSortedWithCurrentBestSort(int sheetId, bool value) {
    updateResults(
      sheetId,
       _getAnalysisResult(sheetId).merge(sortedWithCurrentBestSort: value),
    );
  }

  void setBestSortPossibleFound(int sheetId, bool bestSortPossibleFound) {
    updateResults(sheetId, _getAnalysisResult(sheetId).merge(bestSortPossibleFound: bestSortPossibleFound));
  }

  void setFindingBestSort(int sheetId, bool findingBestSort) {
    updateResults(sheetId, _getAnalysisResult(sheetId).merge(isFindingBestSort: findingBestSort));
  }

  void updateResults(int sheetId, AnalysisResult newResult) {
    _analysisResults[sheetId] = newResult;
  }

  void setSortedWithValidSort(int sheetId, bool sorted) {
    updateResults(sheetId, _getAnalysisResult(sheetId).merge(sortedWithValidSort: sorted));
  }

  void setValidSortIsImpossible(int sheetId, bool impossible) {
    updateResults(sheetId, _getAnalysisResult(sheetId).merge(validSortIsImpossible: impossible));
  }

  void setToAlwaysApplyBestSort(int sheetId, bool toAlwaysApply) {
    updateResults(sheetId, _getAnalysisResult(sheetId).merge(toAlwaysApplyCurrentBestSort: toAlwaysApply));
  }

  AnalysisResultCache(this.loadedSheetsDataStore);
}
