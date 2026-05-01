import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/selection_data.dart';

abstract class HistoryRepository {
  List<SyncRequest> moveInUpdateHistory(HistoryType historyType, int direction);

  List<SyncRequestWithoutHist> commitHistory(
    List<SyncRequestWithHist> updates,
    int sheetId,
    HistoryType historyType,
    bool sameHistIdFromLast,
  );

  List<SyncRequest> stopEditing(bool escape);

  List<SyncRequest> addSheetId(int sheetId);
}
