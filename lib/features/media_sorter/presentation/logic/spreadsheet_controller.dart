import 'dart:math';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/spreadsheet_scroll_request.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/delegates/spreadsheet_keyboard_delegate.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/delegates/spreadsheet_layout_delegate.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/services/sheet_loader_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/services/spreadsheet_clipboard_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/tree_structure_builder.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/check_valid_strings.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart'; // Import AnalysisResult
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';

class SpreadsheetController extends ChangeNotifier {
  // --- dependencies ---
  final GridController _gridController;
  final HistoryController _historyController;
  final SelectionController _selectionController;
  final SheetDataController _dataController;
  final TreeController _treeController;
  final SpreadsheetStreamController _streamController;
  final SortController _sortController;

  // --- usecases ---
  final SaveSheetDataUseCase _saveSheetDataUseCase = SaveSheetDataUseCase(
    SheetRepositoryImpl(FileSheetLocalDataSource()),
  );
  final GetSheetDataUseCase _getDataUseCase = GetSheetDataUseCase(
    SheetRepositoryImpl(FileSheetLocalDataSource()),
  );
  final CalculationService calculationService = CalculationService();
  final ParsePasteDataUseCase _parsePasteDataUseCase = ParsePasteDataUseCase();

  // --- getters ---
  int get rowCount => _dataController.rowCount;
  int get colCount => _dataController.colCount;
  SheetData get sheet => _dataController.sheet;
  SheetContent get sheetContent => _dataController.sheetContent;
  List<String> get sheetNames => _dataController.sheetNames;
  NodeStruct get errorRoot => _treeController.errorRoot;
  NodeStruct get warningRoot => _treeController.warningRoot;
  NodeStruct get mentionsRoot => _treeController.mentionsRoot;
  NodeStruct get searchRoot => _treeController.searchRoot;
  NodeStruct get categoriesRoot => _treeController.categoriesRoot;
  NodeStruct get distPairsRoot => _treeController.distPairsRoot;
  Stream<SpreadsheetScrollRequest> get scrollStream =>
      _streamController.scrollStream;
  bool get editingMode => _selectionController.editingMode;
  int get tableViewRows => _selectionController.tableViewRows;
  int get tableViewCols => _selectionController.tableViewCols;
  Point<int> get primarySelectedCell =>
      _selectionController.primarySelectedCell;
  String get previousContent => _selectionController.selection.previousContent;
  bool get findingBestSort => _sortController.findingBestSort;

  // --- redirections ---
  KeyEventResult handleKeyboard(BuildContext context, KeyEvent event) =>
      _keyboardDelegate.handle(context, event);

  // --- Helper ---
  late final TreeStructureBuilder _treeBuilder;
  late final SheetLoaderService _sheetLoaderService;

  // Delegates
  late final SpreadsheetKeyboardDelegate _keyboardDelegate;
  late final SpreadsheetLayoutDelegate _layoutDelegate;

  // Services
  late final SpreadsheetClipboardService _clipboardService;

  SpreadsheetController(
    this._gridController,
    this._historyController,
    this._selectionController,
    this._dataController,
    this._treeController,
    this._streamController,
    this._sortController,
  ) {
    // Initialize the builder passing the required controllers and the callback
    _treeBuilder = TreeStructureBuilder(
      dataController: _dataController,
      selectionController: _selectionController,
      treeController: _treeController,
      onCellSelected: (row, col, keep, updateMentions) {
        setPrimarySelection(row, col, keep, updateMentions);
      },
    );
    _sheetLoaderService = SheetLoaderService(
      _gridController,
      _selectionController,
      _dataController,
      _streamController,
      _saveSheetDataUseCase,
      _getDataUseCase,
      notifyListeners,
      updateRowColCount,
      saveAndCalculate,
    );
    _clipboardService = SpreadsheetClipboardService(_dataController);
    _keyboardDelegate = SpreadsheetKeyboardDelegate(this);
    _layoutDelegate = SpreadsheetLayoutDelegate(
      this,
      _gridController,
      _selectionController,
      _dataController,
    );
    init();
  }
}
