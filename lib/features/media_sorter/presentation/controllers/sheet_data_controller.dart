import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_model.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';

class SheetDataController extends ChangeNotifier {
  // --- states ---
  SheetModel sheet = SheetModel.empty();
  String sheetName = "";
  List<String> availableSheets = [];
  Map<String, SheetModel> loadedSheetsData = {};
  Map<String, SelectionModel> lastSelectedCells = {};
  final Map<String, ManageWaitingTasks<void>> _saveExecutors = {};
  final ManageWaitingTasks<void> _saveLastSelectionExecutor = ManageWaitingTasks<void>();
  final ManageWaitingTasks<AnalysisResult> _calculateExecutor =
      ManageWaitingTasks<AnalysisResult>();

  // --- usecases ---
  final SaveSheetDataUseCase _saveSheetDataUseCase;

  // getters
  SheetModel get currentSheet => sheet;
  Map<String, ManageWaitingTasks<void>> get saveExecutors => _saveExecutors;
  ManageWaitingTasks<void> get saveLastSelectionExecutor => _saveLastSelectionExecutor;
  SheetContent get sheetContent => sheet.sheetContent;
  int get rowCount => sheet.sheetContent.table.length;
  int get colCount => rowCount > 0 ? sheet.sheetContent.table[0].length : 0;
  ManageWaitingTasks<AnalysisResult> get calculateExecutor =>
      _calculateExecutor;

  SheetDataController({
    required GetSheetDataUseCase getDataUseCase,
    required SaveSheetDataUseCase saveSheetDataUseCase,
  })  : _saveSheetDataUseCase = saveSheetDataUseCase;

  void scheduleSheetSave(int saveDelayMs) {
    _saveExecutors[sheetName]!.execute(() async {
      await _saveSheetDataUseCase.saveSheet(sheetName, sheet);
      await Future.delayed(Duration(milliseconds: saveDelayMs));
    });
  }
}