import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history/history_manager.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history/history_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data/sheet_data_manager.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/workbook_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/analysis_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/selection_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/sort_status_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/check_valid_strings.dart';
import 'package:trying_flutter/utils/logger.dart';
import 'dart:math';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/spreadsheet_scroll_request.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/managers/spreadsheet_keyboard_delegate.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart'; // Import AnalysisResult
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';



class GlobalManager extends ChangeNotifier {
  final HistoryManager historyManager;
  final SheetDataManager sheetDataManager;
  final SelectionController selectionController;
  final SortController sortController;
  final TreeController treeController;
  final GridController gridController;
  final SpreadsheetKeyboardDelegate spreadsheetKeyboardDelegate;
  final WorkbookController workbookController;
  final SpreadsheetStreamController spreadsheetStreamController;
  
  GlobalManager(this.historyManager, this.sheetDataManager, this.selectionController, this.sortController, this.treeController, this.gridController, this.spreadsheetKeyboardDelegate, this.workbookController, this.spreadsheetStreamController) {
    historyManager.addListener(() {
      notifyListeners();
    });
    sheetDataManager.addListener(() {
      notifyListeners();
    });
    selectionController.addListener(() {
      notifyListeners();
    });
    sortController.addListener(() {
      notifyListeners();
    });
    treeController.addListener(() {
      notifyListeners();
    });
    workbookController.addListener(() {
      notifyListeners();
    });
  }

  
}