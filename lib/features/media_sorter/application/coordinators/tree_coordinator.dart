import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/analysis_data_store.dart';

class TreeCoordinator extends ChangeNotifier {
  final AnalysisDataStore analysisDataStore;
  final TreeController treeController;
  final SelectionController selectionController;

  TreeCoordinator(this.analysisDataStore, this.treeController, this.selectionController) {
    treeController.addListener(() {
      notifyListeners();
    });
  }

  void onNodeTapped(NodeStruct node) {
    switch (node.idOnTap) {
      case TreeController.onTapKey:
        onTapCellSelect(node);
        break;
      case TreeController.setPrimarySelectionKey:
        selectionController.setPrimarySelection(
          node.rowId!,
          node.colId!,
          false,
        );
        break;
    }
  }

  void onTapCellSelect(NodeStruct node) {
    if (node.rowId != null) {
      selectionController.setPrimarySelection(
        node.rowId!,
        0,
        false,
      );
      return;
    }

    List<Cell> cells = [];
    List<MapEntry> entries = [];

    if (node.colId != SpreadsheetConstants.notUsedCst) {
      entries = analysisDataStore.currentSheetAnalysisResult.attToRefFromAttColToCol[node.att]!.entries.toList();
    }

    if (node.instruction !=
        SpreadsheetConstants.moveToUniqueMentionSprawlCol) {
      entries.addAll(
        analysisDataStore.currentSheetAnalysisResult.attToRefFromDepColToCol[node.att]!.entries.toList(),
      );
    }

    for (final MapEntry(key: rowId, value: colIds) in entries) {
      for (final colId in colIds) {
        cells.add(Cell(rowId: rowId, colId: colId));
      }
    }
    treeController.handleSelectionCycling(
      node,
      cells,
    );
  }
}