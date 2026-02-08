import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/layout_calculator.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/get_default_sizes.dart';

class SheetDataController extends ChangeNotifier {
  // --- states ---
  final Map<String, ManageWaitingTasks<void>> _saveExecutors = {};

      
  final CalculationService calculationService = CalculationService();

  // --- usecases ---
  final SaveSheetDataUseCase _saveSheetDataUseCase;

  // getters
  // SheetData get currentSheet => sheet;
  // Map<String, ManageWaitingTasks<void>> get saveExecutors => _saveExecutors;
  // ManageWaitingTasks<void> get saveLastSelectionExecutor =>
  //     _saveLastSelectionExecutor;
  // SheetContent get sheetContent => sheet.sheetContent;
  // int get rowCount => sheet.sheetContent.table.length;
  // int get colCount => rowCount > 0 ? sheet.sheetContent.table[0].length : 0;
  // ManageWaitingTasks<AnalysisResult> get calculateExecutor =>
  //     _calculateExecutor;

  SheetDataController({
    required GetSheetDataUseCase getDataUseCase,
    required SaveSheetDataUseCase saveSheetDataUseCase,
  }) : _saveSheetDataUseCase = saveSheetDataUseCase;

  void scheduleSheetSave(SheetData sheet, String sheetName, int saveDelayMs) {
    _saveExecutors[sheetName]!.execute(() async {
      await _saveSheetDataUseCase.saveSheet(sheetName, sheet);
      await Future.delayed(Duration(milliseconds: saveDelayMs));
    });
  }

  void createSaveExecutor(String name) {
    _saveExecutors[name] = ManageWaitingTasks<void>();
  }

  void onChanged(String newValue) {
    updateCell(
      _selectionController.primarySelectedCell.x,
      _selectionController.primarySelectedCell.y,
      newValue,
      onChange: true,
    );
    notifyListeners();
    saveAndCalculate();
  }
}
