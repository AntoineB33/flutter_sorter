import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/application/coordinators/history_coordinator.dart';
import 'package:trying_flutter/features/media_sorter/application/state/workbook_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/managers/spreadsheet_keyboard_delegate.dart';

class GlobalManager extends ChangeNotifier {
  final HistoryCoordinator historyManager;
  final SelectionController selectionController;
  final SortController sortController;
  final TreeController treeController;
  final GridController gridController;
  final SpreadsheetKeyboardDelegate spreadsheetKeyboardDelegate;
  final WorkbookController workbookController;

  GlobalManager(
    this.historyManager,
    this.selectionController,
    this.sortController,
    this.treeController,
    this.gridController,
    this.spreadsheetKeyboardDelegate,
    this.workbookController,
  ) {
    historyManager.addListener(() {
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

  @override
  void dispose() {
    historyManager.dispose();
    selectionController.dispose();
    sortController.dispose();
    treeController.dispose();
    gridController.dispose();
    workbookController.dispose();
    super.dispose();
  }
}
