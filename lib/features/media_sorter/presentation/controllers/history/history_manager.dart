import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort/sort_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';

class HistoryManager extends ChangeNotifier {
  final HistoryController historyController;
  final SheetDataController sheetDataController;
  
  final SortService sortService;
  final LoadedSheetsDataStore loadedSheetsDataStore;

  HistoryManager(this.historyController, this.sheetDataController, this.sortService, this.loadedSheetsDataStore) {
    historyController.addListener(() {
      notifyListeners();
    });
  }
  
  void undo() {
    final Update? updates = historyController.undo();
    if (updates != null) {
      sheetDataController.update(updates);
      sortService.calculate(loadedSheetsDataStore.currentSheetName);
    }
  }
}