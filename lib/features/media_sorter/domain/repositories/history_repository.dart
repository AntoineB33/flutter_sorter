import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/selection_data.dart';

abstract class HistoryRepository {
  List<SyncRequest> moveInUpdateHistory(int direction);
  
  List<SyncRequest> commitHistory(
    List<SyncRequest> updates,
    int sheetId,
    bool isFromEditing,
  );
  
  List<SyncRequest> stopEditing(bool escape);
  
  List<SyncRequest> commitSelection(SelectionState selectionState);
  
  List<SyncRequest> addSheetId(int sheetId);
}
