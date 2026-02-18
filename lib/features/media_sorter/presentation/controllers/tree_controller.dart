import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/analysis_data_store.dart';

class TreeController extends ChangeNotifier {
  // --- states ---
  final AnalysisDataStore analysisStore;
  final NodeStruct mentionsRoot = NodeStruct(
    instruction: SpreadsheetConstants.selectionMsg,
  );
  final NodeStruct searchRoot = NodeStruct(
    instruction: SpreadsheetConstants.searchMsg,
  );

  late Function(
    String currentSheetName,
    int row,
    int col,
    bool keepSelection, {
    bool scrollTo,
  })
  onCellSelected;
  late String Function(List<List<String>> table, int row, int col)
  getCellContent;
  late Function(
    NodeStruct node,
    bool isExpanded,
  ) toggleNodeExpansion;

  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) =>
      content.table.isNotEmpty ? content.table[0].length : 0;

  TreeController({
    required this.analysisStore,
  });

  void populateAllTrees(
    SelectionData selection,
    Map<String, SelectionData> lastSelectionBySheet,
    SortStatus sortStatus,
    String currentSheetName,
    SheetData sheet,
    AnalysisResult result,
  ) {
    populateTree(
      lastSelectionBySheet,
      sortStatus,
      currentSheetName,
      sheet,
      result,
      [
        result.errorRoot,
        result.warningRoot,
        mentionsRoot,
        searchRoot,
        result.categoriesRoot,
        result.distPairsRoot,
      ],
    );
  }

  void populateTree(
    Map<String, SelectionData> lastSelectionBySheet,
    SortStatus sortStatus,
    String currentSheetName,
    SheetData sheet,
    AnalysisResult result,
    List<NodeStruct> roots,
  ) {
    if (!sortStatus.resultCalculated) return;

    for (final root in roots) {
      var stack = [root];
      while (stack.isNotEmpty) {
        var node = stack.removeLast();
        _populateNode(
          lastSelectionBySheet,
          currentSheetName,
          sheet,
          result,
          node,
        ); // Internal call
        if (node.isExpanded) {
          _handleExpansion(node, stack);
        }
        node.children = node.newChildren!;
      }
    }
  }

  // --- Helper Logic ---

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

  void _populateNode(
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
    SheetData sheet,
    AnalysisResult result,
    NodeStruct node,
  ) {
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
        _populateAttributeNode(
          lastSelectionBySheet,
          currentSheetName,
          result,
          node,
          populateChildren,
        );
        break;
      case SpreadsheetConstants.cycleDetected:
        _handleCycleDetectedTap(
          node,
          lastSelectionBySheet,
          currentSheetName,
        );
        break;
      case SpreadsheetConstants.attToRefFromDepCol:
        // Delegates back to specific logic inside TreeController if strictly necessary,
        // or move that logic here as well.
        populateAttToRefFromDepColNode(result, node, populateChildren);
        break;
      default:
        _populateNodeDefault(
          lastSelectionBySheet,
          currentSheetName,
          result,
          sheet,
          node,
          populateChildren,
        );
        break;
    }
  }

  void _populateNodeDefault(
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
    AnalysisResult result,
    SheetData sheet,
    NodeStruct node,
    bool populateChildren,
  ) {
    if (node.rowId != null) {
      if (node.colId != null) {
        if (node.name != null) {
          throw UnimplementedError(
            "CellWithName with name, row and col not implemented",
          );
        } else {
          _populateCellNode(
            lastSelectionBySheet,
            currentSheetName,
            sheet.sheetContent,
            result,
            node,
            populateChildren,
          );
        }
      } else {
        if (node.name != null) {
          throw UnimplementedError(
            "CellWithName with name and row not implemented",
          );
        } else {
          _populateRowNode(
            sheet.sheetContent,
            result,
            lastSelectionBySheet,
            currentSheetName,
            node,
            populateChildren,
          );
        }
      }
    } else {
      if (node.colId != null) {
        if (node.name != null) {
          _populateAttributeNode(
            lastSelectionBySheet,
            currentSheetName,
            result,
            node,
            populateChildren,
          );
        } else {
          _populateColumnNode(
            lastSelectionBySheet,
            currentSheetName,
            sheet.sheetContent,
            result,
            node,
            populateChildren,
          );
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
    _handleDefaultTapLogic(
      node,
      lastSelectionBySheet,
      currentSheetName,
    );
  }

  void _populateAttributeNode(
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
    AnalysisResult result,
    NodeStruct node,
    bool populateChildren,
  ) {
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

    SelectionData selection = lastSelectionBySheet[currentSheetName]!;
    if (node.defaultOnTap) {
      node.onTap = (n) {
        if (node.rowId != null) {
          onCellSelected(
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
      };
      node.defaultOnTap = false;
    }
  }

  void _populateCellNode(
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
    SheetContent sheetContent,
    AnalysisResult lastAnalysis,
    NodeStruct node,
    bool populateChildren,
  ) {
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
      node.onTap = (n) {
        onCellSelected(
          currentSheetName,
          node.rowId!,
          node.colId!,
          false,
        );
      };
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

    if (lastAnalysis.tableToAtt.length <= rowId ||
        lastAnalysis.tableToAtt[rowId].length <= colId) {
      return;
    }

    for (Attribute att in lastAnalysis.tableToAtt[rowId][colId]) {
      node.newChildren!.add(NodeStruct(att: att));
    }
  }

  void _populateRowNode(
    SheetContent sheetContent,
    AnalysisResult lastAnalysis,
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
    NodeStruct node,
    bool populateChildren,
  ) {
    int rowId = node.rowId!;
    node.message ??= GetNames.getRowName(
      lastAnalysis.nameIndexes,
      lastAnalysis.tableToAtt,
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
      lastAnalysis,
      node,
      true,
    );
  }

  void _populateColumnNode(
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
    SheetContent sheetContent,
    AnalysisResult lastAnalysis,
    NodeStruct node,
    bool populateChildren,
  ) {
    node.message ??= node.colId == -1
        ? "Rows"
        : 'Column ${GetNames.getColumnLabel(node.colId!)} "${sheetContent.table[0][node.colId!]}"';
    if (!populateChildren) return;

    if (lastAnalysis.colToAtt.containsKey(node.colId)) {
      for (final attCol in lastAnalysis.colToAtt[node.colId]!) {
        node.newChildren!.add(NodeStruct(att: attCol));
      }
    }
  }

  // --- Tap Logic Helpers ---

  void _handleSelectionCycling(
    SelectionData selection,
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
    NodeStruct node,
    List<Cell> cells,
  ) {
    int found = -1;
    for (int i = 0; i < cells.length; i++) {
      final child = cells[i];
      if (selection.primarySelectedCell.x == child.rowId &&
          selection.primarySelectedCell.y == child.colId) {
        found = i;
        break;
      }
    }

    int index = (found == -1) ? 0 : (found + 1) % cells.length;
    onCellSelected(
      currentSheetName,
      cells[index].rowId,
      cells[index].colId,
      false,
    );
  }

  void _handleCycleDetectedTap(
    NodeStruct node,
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
  ) {
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
        onCellSelected(
          currentSheetName,
          n.newChildren![0].rowId!,
          n.newChildren![0].colId!,
          false,
        );
      } else {
        final nextChild = n.newChildren![(found + 1) % n.newChildren!.length];
        onCellSelected(
          currentSheetName,
          nextChild.rowId!,
          nextChild.colId!,
          false,
        );
      }
    };
  }

  void _handleDefaultTapLogic(
    NodeStruct node,
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
  ) {
    SelectionData selection = lastSelectionBySheet[currentSheetName]!;
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
        onCellSelected(
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

  void updateMentionsContext(
    Map<String, SelectionData> lastSelectionBySheet,
    SortStatus sortStatus,
    String currentSheetName,
    SheetData sheet,
    AnalysisResult result,
    int row,
    int col,
  ) {
    updateMentionsRoot(row, col);
    populateTree(
      lastSelectionBySheet,
      sortStatus,
      currentSheetName,
      sheet,
      result,
      [mentionsRoot],
    );
  }

  void clearMentionsRoot() {
    mentionsRoot.newChildren = null;
  }

  void updateMentionsRoot(int row, int col) {
    clearMentionsRoot();
    mentionsRoot.rowId = row;
    mentionsRoot.colId = col;
  }

  void clearSearchRoot() {
    searchRoot.newChildren = null;
  }

  // Method to allow Controller to toggle expansion
  void nodeExpansion(
    SheetData sheet,
    AnalysisResult result,
    Map<String, SelectionData> lastSelectionBySheet,
    SortStatus sortStatus,
    String currentSheetName,
    NodeStruct node,
    bool isExpanded,
  ) {
    node.isExpanded = isExpanded;
    for (NodeStruct child in node.newChildren ?? []) {
      child.isExpanded = false;
    }
    populateTree(
      lastSelectionBySheet,
      sortStatus,
      currentSheetName,
      sheet,
      result,
      [node],
    );
    notifyListeners();
  }

  

  /// Call this when the Controller finishes a calculation.
  /// The Manager takes ownership of updating the tree state.
  void onAnalysisComplete(
    AnalysisResult result,
    Point<int> primarySelectedCell,
  ) {
    _treeController.clearMentionsRoot();
    _treeController.clearSearchRoot();
    _treeController.populateAllTrees(
      selectionController.selection,
      selectionController.lastSelectionBySheet,
      sortController.sortStatusBySheet[currentSheetName]!,
      currentSheetName,
      sheet,
      result,
    );
  }
}
