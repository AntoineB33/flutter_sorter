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
  void populateAllTrees(
    NodeStruct mentionsRoot,
    NodeStruct searchRoot,
  ) {
    String currentSheetId = workbookCache.currentSheetId;
    AnalysisResult result = analysisCache.getAnalysisResult(currentSheetId);
    populateTree([
      result.errorRoot,
      result.warningRoot,
      mentionsRoot,
      searchRoot,
      result.categoriesRoot,
      result.distPairsRoot,
    ]);
  }
  
  @override
  bool isRowValid(
    int rowId,
  ) {
    String currentSheetId = workbookCache.currentSheetId;
    if (sortStatusCache.getAnalysisDone(currentSheetId)) {
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

  @override
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

  
  @override
  void populateTree(List<NodeStruct> roots) {
    for (final root in roots) {
      var stack = [root];
      while (stack.isNotEmpty) {
        var node = stack.removeLast();
        _populateNode(node); // Internal call
        if (node.isExpanded) {
          _handleExpansion(node, stack);
        }
        node.children = node.newChildren!;
      }
    }
  }

  // Method to allow Controller to toggle expansion
  void nodeExpansion(NodeStruct node, bool isExpanded) {
    node.isExpanded = isExpanded;
    for (NodeStruct child in node.newChildren ?? []) {
      child.isExpanded = false;
    }
    populateTree([node]);
    notifyListeners();
  }

  void _handleExpansion(NodeStruct node, List<NodeStruct> stack) {
    for (int i = 0; i < node.children.length; i++) {
      var obj = node.children[i];
      if (!obj.isExpanded) {
        break;
      }
      for (int j = 0; j < node.newChildren!.length; j++) {
        var newObj = node.newChildren![j];
        if (!newObj.isExpanded && obj == newObj) {
          newObj.isExpanded = true;
          break;
        }
      }
    }
    for (final child in node.children) {
      child.isExpanded = child.startOpen || child.isExpanded;
    }
    if (node.isExpanded) {
      for (final child in node.newChildren!) {
        stack.add(child);
      }
    }
  }

  void _populateNode(NodeStruct node) {
    bool populateChildren = node.newChildren == null;
    if (populateChildren) {
      node.newChildren = [];
    }
    switch (node.instruction) {
      case SpreadsheetConstants.refFromAttColMsg:
        if (populateChildren) {
          for (int pointerRowId
              in result.attToRefFromAttColToCol[node.att]!.keys) {
            node.newChildren!.add(NodeStruct(rowId: pointerRowId));
          }
        }
        break;
      case SpreadsheetConstants.refFromDepColMsg:
        if (populateChildren) {
          for (int pointerRowId
              in result.attToRefFromDepColToCol[node.att]!.keys) {
            node.newChildren!.add(NodeStruct(rowId: pointerRowId));
          }
        }
        break;
      case SpreadsheetConstants.nodeAttributeMsg:
        _populateAttributeNode(node, populateChildren);
        break;
      case SpreadsheetConstants.cycleDetected:
        _handleCycleDetectedTap(node);
        break;
      case SpreadsheetConstants.attToRefFromDepCol:
        // Delegates back to specific logic inside TreeController if strictly necessary,
        // or move that logic here as well.
        populateAttToRefFromDepColNode(result, node, populateChildren);
        break;
      default:
        _populateNodeDefault(node, populateChildren);
        break;
    }
  }

  void _populateNodeDefault(NodeStruct node, bool populateChildren) {
    if (node.rowId != null) {
      if (node.colId != null) {
        if (node.name != null) {
          throw UnimplementedError(
            "CellWithName with name, row and col not implemented",
          );
        } else {
          _populateCellNode(node, populateChildren);
        }
      } else {
        if (node.name != null) {
          throw UnimplementedError(
            "CellWithName with name and row not implemented",
          );
        } else {
          _populateRowNode(node, populateChildren);
        }
      }
    } else {
      if (node.colId != null) {
        if (node.name != null) {
          _populateAttributeNode(node, populateChildren);
        } else {
          _populateColumnNode(node, populateChildren);
        }
      } else {
        if (node.name != null) {
          if (result.attToCol.containsKey(node.name)) {
            if (result.attToCol[node.name]! !=
                [SpreadsheetConstants.notUsedCst]) {
              node.newChildren!.add(
                NodeStruct(
                  instruction: SpreadsheetConstants.attToRefFromDepCol,
                  name: node.name,
                ),
              );
              node.newChildren!.add(
                NodeStruct(
                  instruction: SpreadsheetConstants.attToCol,
                  name: node.name,
                ),
              );
            } else {
              populateAttToRefFromDepColNode(result, node, populateChildren);
            }
          } else {
            debugPrint(
              "populateNode: Unhandled CellWithName with name only: ${node.name}",
            );
          }
        }
      }
    }
    _handleDefaultTapLogic(node);
  }

  void _populateAttributeNode(NodeStruct node, bool populateChildren) {
    if (populateChildren) {
      if (result.attToRefFromAttColToCol.containsKey(node.att)) {
        node.newChildren!.add(
          NodeStruct(
            instruction: SpreadsheetConstants.refFromAttColMsg,
            att: node.att,
          ),
        );
      } else {
        node.newChildren!.add(
          NodeStruct(message: 'No references from attribute columns found'),
        );
      }
      if (result.attToRefFromDepColToCol.containsKey(node.att)) {
        node.newChildren!.add(
          NodeStruct(
            instruction: SpreadsheetConstants.refFromDepColMsg,
            att: node.att,
          ),
        );
      } else {
        node.newChildren!.add(
          NodeStruct(message: 'No references from dependence columns found'),
        );
      }
    }

    node.message ??= node.name;

    if (node.defaultOnTap) {
      node.idOnTap = onTapKey;
      node.defaultOnTap = false;
    }
  }

  void _populateCellNode(NodeStruct node, bool populateChildren) {
    int rowId = node.rowId!;
    int colId = node.colId!;
    node.cellsToSelect = node.cells;

    if (rowId >= rowCount(sheetContent) || colId >= colCount(sheetContent)) {
      return;
    }

    if (node.message == null) {
      if (node.instruction == SpreadsheetConstants.selectionMsg) {
        node.message =
            '${GetNames.getColumnLabel(colId)}$rowId selected: ${sheetContent.table[rowId][colId]}';
      } else {
        node.message =
            '${GetNames.getColumnLabel(colId)}$rowId: ${sheetContent.table[rowId][colId]}';
      }
    }
    if (node.defaultOnTap) {
      node.idOnTap = setPrimarySelectionKey;
      node.defaultOnTap = false;
    }

    if (!populateChildren) return;

    node.newChildren = [];

    // Check specific column types directly
    final colType = sheetContent.columnTypes[colId];
    if (colType == ColumnType.names ||
        colType == ColumnType.filePath ||
        colType == ColumnType.urls) {
      node.newChildren!.add(
        NodeStruct(
          message: sheetContent.table[rowId][colId],
          att: Attribute.row(rowId),
        ),
      );
      return;
    }

    if (result.tableToAtt.length <= rowId ||
        result.tableToAtt[rowId].length <= colId) {
      return;
    }

    for (Attribute att in result.tableToAtt[rowId][colId]) {
      node.newChildren!.add(NodeStruct(att: att));
    }
  }

  void _populateRowNode(NodeStruct node, bool populateChildren) {
    int rowId = node.rowId!;
    node.message ??= GetNames.getRowName(
      result.nameIndexes,
      result.tableToAtt,
      rowId,
    );
    if (!populateChildren) return;

    List<NodeStruct> rowCells = [];
    for (int colId = 0; colId < sheetContent.columnTypes.length; colId++) {
      if (getCellContent(sheetContent.table, rowId, colId).isNotEmpty) {
        rowCells.add(
          NodeStruct(
            cell: Cell(rowId: rowId, colId: colId),
          ),
        );
      }
    }

    if (rowCells.isNotEmpty) {
      node.newChildren!.add(
        NodeStruct(message: 'Content of the row', newChildren: rowCells),
      );
    }
    _populateAttributeNode(
      lastSelectionBySheet,
      currentSheetName,
      result,
      node,
      true,
    );
  }

  void _populateColumnNode(NodeStruct node, bool populateChildren) {
    node.message ??= node.colId == -1
        ? "Rows"
        : 'Column ${GetNames.getColumnLabel(node.colId!)} "${sheetContent.table[0][node.colId!]}"';
    if (!populateChildren) return;

    if (result.colToAtt.containsKey(node.colId)) {
      for (final attCol in result.colToAtt[node.colId]!) {
        node.newChildren!.add(NodeStruct(att: attCol));
      }
    }
  }

  // --- Tap Logic Helpers ---

  void _handleCycleDetectedTap(NodeStruct node) {
    SelectionData selection = lastSelectionBySheet[currentSheetName]!;
    node.onTap = (n) {
      int found = -1;
      for (int i = 0; i < n.newChildren!.length; i++) {
        final child = n.newChildren![i];
        if (selection.primarySelectedCell.x == child.rowId) {
          found = i;
          break;
        }
      }
      if (found == -1) {
        selectionController.setPrimarySelection(
          currentSheetName,
          n.newChildren![0].rowId!,
          n.newChildren![0].colId!,
          false,
        );
      } else {
        final nextChild = n.newChildren![(found + 1) % n.newChildren!.length];
        selectionController.setPrimarySelection(
          currentSheetName,
          nextChild.rowId!,
          nextChild.colId!,
          false,
        );
      }
    };
  }

  void _handleDefaultTapLogic(NodeStruct node) {
    if (node.defaultOnTap) {
      if (node.cellsToSelect == null) {
        node.cellsToSelect = node.cells;
        if (node.cellsToSelect == null || node.cellsToSelect!.isEmpty) {
          List<Cell> cells = [];
          for (final child in node.newChildren ?? []) {
            if (child.rowId != null) {
              if (child.colId != null) {
                cells.add(Cell(rowId: child.rowId!, colId: child.colId!));
              } else {
                cells.add(Cell(rowId: child.rowId!, colId: 0));
              }
            } else if (child.colId != null) {
              cells.add(Cell(rowId: 0, colId: child.colId!));
            }
          }
          node.cellsToSelect = cells;
        }
      }
      node.onTap = (n) {
        if (node.cellsToSelect == null || node.cellsToSelect!.isEmpty) {
          return;
        }
        int found = -1;
        for (int i = 0; i < node.cellsToSelect!.length; i++) {
          final child = node.cellsToSelect![i];
          if (selection.primarySelectedCell.x == child.rowId &&
              selection.primarySelectedCell.y == child.colId) {
            found = i;
            break;
          }
        }
        final nextIndex = (found == -1)
            ? 0
            : (found + 1) % node.cellsToSelect!.length;
        selectionController.setPrimarySelection(
          currentSheetName,
          node.cellsToSelect![nextIndex].rowId,
          node.cellsToSelect![nextIndex].colId,
          false,
        );
      };
      node.defaultOnTap = false;
    }
  }

  void populateAttToRefFromDepColNode(
    AnalysisResult result,
    NodeStruct node,
    bool populateChildren,
  ) {
    if (!populateChildren) return;

    final attribute = Attribute(name: node.name);
    for (final rowId in result.attToRefFromDepColToCol[attribute]!.keys) {
      node.newChildren!.add(NodeStruct(rowId: rowId));
    }
  }

  Future<void> saveAnalysisResult(
    String sheetName,
    AnalysisResult result,
  ) async {
    _saveResultExecutors[sheetName] ??= ManageWaitingTasks<void>(
      Duration(milliseconds: SpreadsheetConstants.saveAnalysisResultDelayMs),
    );
    _saveResultExecutors[sheetName]!.execute(() async {
      await saveSheetDataUseCase.saveAnalysisResult(sheetName, result);
    });
  }
}
