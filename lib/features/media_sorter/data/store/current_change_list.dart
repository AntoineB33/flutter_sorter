import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_data.dart';

class CurrentChangeList {
  Map<int, Map<HistoryType, Map<String, SyncRequestWithoutHist>>> changes = {};

  void addChange(int sheetId, HistoryType type, SyncRequestWithoutHist change) {
    final sheetChanges = changes[sheetId] ??= {};
    final currentChanges = sheetChanges[type] ??= {};
    currentChanges[change.companionWrapper.getKey()] = change;
  }

  void clear() {
    changes.clear();
  }
}
