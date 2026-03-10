import 'dart:async';
import 'dart:math';

import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/tree_repository.dart';
import 'package:trying_flutter/utils/logger.dart';

class TreeRepositoryImpl implements TreeRepository {
  final AnalysisResultCache analysisDataStore;
  final LoadedSheetsCache loadedSheetsDataStore;
  final SelectionCache selectionDataStore;

  TreeRepositoryImpl(
    this.analysisDataStore,
    this.loadedSheetsDataStore,
    this.selectionDataStore,
  );

  @override
  void onTap(NodeStruct node) {
    switch (node.idOnTap) {
      case OnTapAction.selectAttribute:
        onTapCellSelect(node);
        break;
      case OnTapAction.selectCell:
        if (node.rowId != null && node.colId != null) {
          _selectionController.add(
            SelectionRequest(
              primarySelectedCell: Point(node.rowId!, node.colId!),
            ),
          );
        }
        break;
      default:
        logger.e("No onTap handler for node: ${node.message}");
    }
  }

  void onTapCellSelect(NodeStruct node) {
    if (node.rowId != null) {
      _selectionController.add(
        SelectionRequest(primarySelectedCell: Point(node.rowId!, 0)),
      );
      return;
    }

    List<Cell> cells = [];
    List<MapEntry> entries = [];

    if (node.colId != SpreadsheetConstants.notUsedCst) {
      entries = analysisDataStore
          .getAnalysisResult(loadedSheetsDataStore.currentSheetId)
          .attToRefFromAttColToCol[node.att]!
          .entries
          .toList();
    }

    if (node.instruction != SpreadsheetConstants.moveToUniqueMentionSprawlCol) {
      entries.addAll(
        analysisDataStore
            .getAnalysisResult(loadedSheetsDataStore.currentSheetId)
            .attToRefFromDepColToCol[node.att]!
            .entries
            .toList(),
      );
    }

    for (final MapEntry(key: rowId, value: colIds) in entries) {
      for (final colId in colIds) {
        cells.add(Cell(rowId: rowId, colId: colId));
      }
    }
    _handleSelectionCycling(node, cells);
  }

  void _handleSelectionCycling(NodeStruct node, List<Cell> cells) {
    int found = -1;
    for (int i = 0; i < cells.length; i++) {
      final child = cells[i];
      if (selectionDataStore.selection.primarySelectedCell.x == child.rowId &&
          selectionDataStore.selection.primarySelectedCell.y == child.colId) {
        found = i;
        break;
      }
    }

    int index = (found == -1) ? 0 : (found + 1) % cells.length;
    _selectionController.add(
      SelectionRequest(
        primarySelectedCell: Point(cells[index].rowId, cells[index].colId),
      ),
    );
  }
}
