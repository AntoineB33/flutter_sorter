import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/features/media_sorter/data/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/update_data.dart';

abstract class HistoryRepository {
  UpdateData? moveInUpdateHistory(int direction);
  @useResult
  ChangeSet commitHistory(
    IMap<String, UpdateUnit> updates,
    int sheetId,
    bool isFromEditing,
  );
  @useResult
  ChangeSet stopEditing(bool escape);
  @useResult
  UpdateUnit commitSelection(SelectionState selectionState);
  @useResult
  ChangeSet addSheetId(int sheetId);
}
