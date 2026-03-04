import 'package:trying_flutter/features/media_sorter/application/state/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sort_controller.dart';

class SpreadsheetCoordinator {
  final HistoryController historyController;
  final SheetDataController sheetDataController;
  final GridController gridController;
  final SortController sortController;

  SpreadsheetCoordinator(this.historyController, this.sheetDataController, this.gridController, this.sortController);

  void update(UpdateData updateData, bool updateHistory) {
    sheetDataController.update(updateData);
    if (updateHistory) {
      historyController.commitHistory(updateData);
    }
    gridController.adjustRowHeightAfterUpdate(updateData);
    sortController.calculateOnChange();
    sheetDataController.notifyListeners();
    sheetDataController.scheduleSheetSave(sheetDataController.currentSheetName);
  }

  void undo() {
    historyController.moveInUpdateHistory(-1);
  }

  void redo() {
    historyController.moveInUpdateHistory(1);
  }
}