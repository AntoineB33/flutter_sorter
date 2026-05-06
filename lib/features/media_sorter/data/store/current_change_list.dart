import 'dart:convert';

import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_type.dart';

class CurrentChangeList {
  final Map<HistoryType, bool> committedInThisRunTime = {
    for (final historyType in HistoryType.values) historyType: false,
  };
  final Map<int, Map<HistoryType, List<SyncRequestWithoutHist>>> changes = {};
  final List<SyncRequestWithoutHist> changeList = [];

  bool get committed => committedInThisRunTime.values.any((value) => value);
  
  // Add this getter for easy debugging
  String get debugChangeListJson => jsonEncode(changeList);

  void addChange(HistoryType type, SyncRequestWithoutHist change) {
    int sheetId = switch (change.companionWrapper) {
      SheetDataWrapper() => (change.companionWrapper as SheetDataWrapper).companion.sheetId.value,
      HistoryWrapper() => (){throw ArgumentError('History changes should not be added to CurrentChangeList');}(),
      SheetCellWrapper() => (change.companionWrapper as SheetCellWrapper).companion.sheetId.value,
      RowHeightWrapper() => (change.companionWrapper as RowHeightWrapper).companion.sheetId.value,
      ColWidthWrapper() => (change.companionWrapper as ColWidthWrapper).companion.sheetId.value,
      RowsManuallyAdjustedHeightWrapper() => (change.companionWrapper as RowsManuallyAdjustedHeightWrapper).companion.sheetId.value,
      ColsManuallyAdjustedWidthWrapper() => (change.companionWrapper as ColsManuallyAdjustedWidthWrapper).companion.sheetId.value,
    };
    if (!changes.containsKey(sheetId)) {
      changes[sheetId] = {};
    }
    if (!changes[sheetId]!.containsKey(type)) {
      changes[sheetId]![type] = [];
    }
    changes[sheetId]![type]!.add(change);
  }

  void clearChanges() {
    changes.clear();
  }

  void clearChangeList() {
    changeList.clear();
    committedInThisRunTime.updateAll((key, value) => false);
  }
}
