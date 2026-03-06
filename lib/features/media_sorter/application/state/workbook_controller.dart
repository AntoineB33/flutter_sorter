import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_data/sheet_save_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/history_service.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sort_status_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/services/check_valid_strings.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/workbook_usecase.dart';
import 'package:trying_flutter/utils/logger.dart';
import 'dart:math';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/managers/spreadsheet_keyboard_delegate.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart'; // Import AnalysisResult

class WorkbookController extends ChangeNotifier {

  // --- usecases ---
  final WorkbookUseCase workbookUseCase;
  final SaveSheetDataUseCase saveSheetDataUseCase;
  final GetSheetDataUseCase getDataUseCase;
  final CalculationService calculationService = CalculationService();

  WorkbookController({
    required this.workbookUseCase,
    required this.saveSheetDataUseCase,
    required this.getDataUseCase,
  }) {
    workbookUseCase.init();
  }

  Future<void> loadSheetByName(
    String name, {
    bool init = false,
    SelectionData? lastSelection,
  }) async {
    if (!init) {
      selectionController.saveAllLastSelected();
      saveSheetDataUseCase.saveRecentSheetIds(name);
    }

    if (sheetNames.contains(name)) {
      if (!_dataController.loadedSheetsData.containsKey(name)) {
        _dataController.createSaveExecutor(name);
        try {
          _dataController.loadedSheetsData[name] = await getDataUseCase
              .loadSheet(name);
        } catch (e) {
          logger.e("Error parsing sheet data for $name: $e");
          _dataController.loadedSheetsData[name] = SheetData.empty();
          selectionController.clearLastSelection(name);
        }
        await sortController.loadAnalysisResult(name);
      }
    } else {
      _dataController.loadedSheetsData[name] = SheetData.empty();
      sortController.analysisResults[name] = AnalysisResult.empty();
      selectionController.clearLastSelection(name);
      sheetNames.add(name);
      saveSheetDataUseCase.saveRecentSheetIds(sheetNames);
      _dataController.createSaveExecutor(name);
    }
    currentSheetName = name;
    if (!init) {
      selectionController.saveLastSelection(name);
    }

    // Trigger Controller updates
    selectionController.updateRowColCount(
      sheet,
      currentSheetName,
      visibleHeight:
          selectionController.scrollOffsetX +
          _gridController.row1ToScreenBottomHeight,
      visibleWidth:
          selectionController.scrollOffsetY +
          _gridController.colBToScreenRightWidth,
      notify: false,
    );

    _streamController.scrollToOffset(
      x: selectionController.scrollOffsetX,
      y: selectionController.scrollOffsetY,
      animate: true,
    );
    notifyListeners();
  }

  List<String> getRecentSheetNames() {
    return loadedSheetsDataStore.recentSheetIds
        .map((id) => loadedSheetsDataStore.getSheet(id).sheetName)
        .toList();
  }
}
