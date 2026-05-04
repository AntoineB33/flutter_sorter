import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_type.dart';

class CurrentChangeList {
  Map<int, Map<HistoryType, List<SyncRequestWithoutHist>>> changes = {};

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
    final sheetChanges = changes[sheetId] ??= {};
    final currentChanges = sheetChanges[type] ??= [];
    currentChanges.add(change);
  }

  void clear() {
    changes.clear();
  }
}
