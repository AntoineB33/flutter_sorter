import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort/sort_service.dart';

class SheetDataManager extends ChangeNotifier {
  final SheetDataController sheetDataController;
  final HistoryController historyController;

  final SortService sortService;
  final SelectionData selection;

  SheetDataManager(this.sheetDataController, this.historyController, this.sortService, this.selection) {
    sheetDataController.addListener(() {
      notifyListeners();
    });
  }

  void onChanged(
    String currentSheetName,
    String newValue,
  ) {
    sheetDataController.updateCell(
      selection.primarySelectedCell.x,
      selection.primarySelectedCell.y,
      newValue,
      onChange: true,
    );
    notifyListeners();
    sheetDataController.scheduleSheetSave(currentSheetName);
    sortService.calculate(currentSheetName);
  }
}