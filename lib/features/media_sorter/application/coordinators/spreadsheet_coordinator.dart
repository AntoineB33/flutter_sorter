import 'dart:async';

import 'package:trying_flutter/features/media_sorter/application/state/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';

class SpreadsheetCoordinator {
  final HistoryController historyController;
  final SheetDataController sheetDataController;
  final GridController gridController;
  final SortController sortController;
  final SelectionController selectionController;
  
  StreamSubscription? _mergedSubscription;

  SpreadsheetCoordinator(this.historyController, this.sheetDataController, this.gridController, this.sortController, this.selectionController) {
    _mergedSubscription = Rx.merge([
      historyController.updateDataStream,
      sheetDataController.updateDataStream,
    ]).listen((updateRequest) {
      update(updateRequest.updateData, updateRequest.updateHistory);
    });
  }
  
  void dispose() {
    _mergedSubscription?.cancel();
  }

  void update(UpdateData updateData, bool updateHistory) {
    sheetDataController.update(updateData);
    if (updateHistory) {
      historyController.commitHistory(updateData);
    }
    gridController.adjustRowHeightAfterUpdate(updateData);
    sortController.calculateOnChange();
  }

}