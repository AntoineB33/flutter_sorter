import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree/tree_controller.dart';

class TreeManager extends ChangeNotifier {
  final TreeController treeController;

  TreeManager(this.treeController) {
    treeController.addListener(() {
      notifyListeners();
    });
  }

  void onNodeTapped(NodeStruct node) {
    switch (node.idOnTap) {
      case SpreadsheetConstants.moveToUniqueMentionSprawlCol:
        treeController.onTapMoveToUniqueMentionSprawlCol(node);
        break;
      default:
        if (node.defaultOnTap) {
          treeController.onTapCellSelect(node);
        }
    }
  }

  void onTapCellSelect(NodeStruct node) {
    if (node.rowId != null) {
      (
        currentSheetName,
        node.rowId!,
        0,
        false,
      );
      return;
    }

    List<Cell> cells = [];
    List<MapEntry> entries = [];

    if (node.colId != SpreadsheetConstants.notUsedCst) {
      entries = result.attToRefFromAttColToCol[node.att]!.entries.toList();
    }

    if (node.instruction !=
        SpreadsheetConstants.moveToUniqueMentionSprawlCol) {
      entries.addAll(
        result.attToRefFromDepColToCol[node.att]!.entries.toList(),
      );
    }

    for (final MapEntry(key: rowId, value: colIds) in entries) {
      for (final colId in colIds) {
        cells.add(Cell(rowId: rowId, colId: colId));
      }
    }
    _handleSelectionCycling(
      selection,
      lastSelectionBySheet,
      currentSheetName,
      node,
      cells,
    );
  }
}