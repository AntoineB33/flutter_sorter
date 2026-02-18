import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/sort_status_data_store.dart';

class AnalysisDataStore extends ChangeNotifier {
  final Map<String, AnalysisResult> _analysisResults = {};

  final LoadedSheetsDataStore loadedSheetsDataStore;

  AnalysisDataStore(this.loadedSheetsDataStore);
  
  // Getter for the data
  Map<String, AnalysisResult> get analysisResults => _analysisResults;
  AnalysisResult get currentSheetAnalysisResult => getAnalysisResult(loadedSheetsDataStore.currentSheetName);
  List<List<HashSet<Attribute>>> get tableToAtt => currentSheetAnalysisResult.tableToAtt;
  Map<int, Map<int, List<SortingRule>>> get myRules => currentSheetAnalysisResult.myRules;
  List<List<int>> get groupsToMaximize => currentSheetAnalysisResult.groupsToMaximize;

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