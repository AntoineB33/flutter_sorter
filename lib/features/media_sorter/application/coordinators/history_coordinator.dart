import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/application/state/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';

class HistoryCoordinator extends ChangeNotifier {
  final HistoryController historyController;
  final SheetDataController sheetDataController;

  final LoadedSheetsCache loadedSheetsDataStore;

  HistoryCoordinator(
    this.historyController,
    this.sheetDataController,
    this.loadedSheetsDataStore,
  ) {
    historyController.addListener(() {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    historyController.dispose();
    super.dispose();
  }
}
