import 'dart:async';
import 'dart:math';

import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sort_status_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/tree_repository.dart';
import 'package:trying_flutter/utils/logger.dart';

class TreeRepositoryImpl implements TreeRepository {
  final AnalysisResultCache analysisCache;
  final LoadedSheetsCache loadedSheetsCache;
  final SelectionCache selectionDataStore;
  final SortStatusCache sortStatusCache;
  final WorkbookCache workbookCache;

  TreeRepositoryImpl(
    this.analysisCache,
    this.loadedSheetsCache,
    this.selectionDataStore,
    this.sortStatusCache,
    this.workbookCache,
  );
  
  int rowCount(String sheetId) {
    return loadedSheetsCache.rowCount(sheetId);
  }

  int colCount(String sheetId) {
    return loadedSheetsCache.colCount(sheetId);
  }
  
  @override
  bool isRowValid(
    int rowId,
  ) {
    String currentSheetId = workbookCache.currentSheetId;
    if (sortStatusCache.analysisDone(currentSheetId)) {
      return rowId < analysisCache.isMedium(currentSheetId).length && analysisCache.isMedium(currentSheetId)[rowId];
    }
    if (rowId == 0) {
      return false;
    }
    for (
      int srcColId = 0;
      srcColId < colCount(currentSheetId);
      srcColId++
    ) {
      if (GetNames.isSourceColumn(loadedSheetsCache.getSheetContent(currentSheetId).columnTypes[srcColId]) &&
          loadedSheetsCache.getCellContent(currentSheetId, rowId, srcColId).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

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
      entries = analysisCache
          .getAnalysisResult(loadedSheetsCache.currentSheetId)
          .attToRefFromAttColToCol[node.att]!
          .entries
          .toList();
    }

    if (node.instruction != SpreadsheetConstants.moveToUniqueMentionSprawlCol) {
      entries.addAll(
        analysisCache
            .getAnalysisResult(loadedSheetsCache.currentSheetId)
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
