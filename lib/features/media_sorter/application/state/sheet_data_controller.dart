import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/helpers/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/data/services/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/history_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/data/services/spreadsheet_clipboard_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:uuid/uuid.dart';

class SheetDataController extends ChangeNotifier {
  final SheetDataUsecase sheetDataUsecase;

  SheetDataController(this.sheetDataUsecase);

  void saveRecentSheetIds() {
    sheetDataUsecase.saveRecentSheetIds();
  }

  void onChanged(String newValue) {
    update(
      UpdateData(Uuid().v4(), DateTime.now(), [
        CellUpdate(
          selectionDataStore.primarySelectedCell.x,
          selectionDataStore.primarySelectedCell.y,
          newValue,
          loadedSheetsData.getCellContent(
            selectionDataStore.primarySelectedCell.x,
            selectionDataStore.primarySelectedCell.y,
          ),
        ),
      ]),
      false,
    );
    notifyListeners();
    scheduleSheetSave(currentSheetName);
    sortService.calculate(currentSheetName);
  }

  void delete() {
    List<BaseUpdate> updates = [];
    for (Point<int> cell in selection.selectedCells) {
      updates.add(
        CellUpdate(
          cell.x,
          cell.y,
          '',
          loadedSheetsData.getCellContent(cell.x, cell.y),
        ),
      );
    }
    UpdateData updateData = UpdateData(Uuid().v4(), DateTime.now(), updates);
    update(updateData, true);
    notifyListeners();
    scheduleSheetSave(currentSheetName);
    sortService.calculate(currentSheetName);
  }

  void applyDefaultColumnSequence() {
    update(
      UpdateData(Uuid().v4(), DateTime.now(), [
        ColumnTypeUpdate(
          1,
          ColumnType.dependencies,
          loadedSheetsData.getColumnType(1),
        ),
        ColumnTypeUpdate(
          2,
          ColumnType.dependencies,
          loadedSheetsData.getColumnType(2),
        ),
        ColumnTypeUpdate(
          3,
          ColumnType.dependencies,
          loadedSheetsData.getColumnType(3),
        ),
        ColumnTypeUpdate(7, ColumnType.urls, loadedSheetsData.getColumnType(7)),
        ColumnTypeUpdate(
          8,
          ColumnType.dependencies,
          loadedSheetsData.getColumnType(8),
        ),
      ]),
      true,
    );
  }

  @override
  void dispose() {
    for (var executor in _saveExecutors.values) {
      executor.dispose();
    }
    super.dispose();
  }

  void setCellContent(Point<int> cell, String newVal) {
    sheetDataUsecase.setCellContent(cell, newVal);
    notifyListeners();
  }
}
