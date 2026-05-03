import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_data.dart';

class CurrentChangeList {
  int sheetId = -1;
  Map<HistoryType, List<SyncRequestWithoutHist>> changes = {};

  void addChange(HistoryType type, SyncRequestWithoutHist change) {
    final currentChanges = changes[type] ??= [];
    currentChanges.add(change);
  }

  void clear() {
    changes.clear();
  }
}
