import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';

class SelectionDataStore extends ChangeNotifier {
  Map<String, SelectionData> lastSelectionBySheet = {};

  LoadedSheetsDataStore loadedSheetsDataStore;

  SelectionData get selection =>
    lastSelectionBySheet[loadedSheetsDataStore.currentSheetName] ??= SelectionData.empty();
  int get tableViewRows => selection.tableViewRows;
  int get tableViewCols => selection.tableViewCols;
  bool get editingMode => selection.editingMode;

  SelectionDataStore(this.loadedSheetsDataStore);
}