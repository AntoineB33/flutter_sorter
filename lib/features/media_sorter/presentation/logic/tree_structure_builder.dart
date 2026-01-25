import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';

/// Type definition for the selection callback to decouple the builder from the manager
typedef OnTreeCellSelected = void Function(
  int row,
  int col,
  bool keepSelection,
  bool updateMentions,
);

class TreeStructureBuilder {
  final SheetDataController _dataController;
  final SelectionController _selectionController;
  final TreeController _treeController;
  final OnTreeCellSelected _onCellSelected;

  TreeStructureBuilder({
    required SheetDataController dataController,
    required SelectionController selectionController,
    required TreeController treeController,
    required OnTreeCellSelected onCellSelected,
  })  : _dataController = dataController,
        _selectionController = selectionController,
        _treeController = treeController,
        _onCellSelected = onCellSelected;

  // --- Core Entry Point ---

  void populateTree(List<NodeStruct> roots) {
    if (_treeController.noResult) return;

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

  void _populateNode(NodeStruct node) {
    bool populateChildren = node.newChildren == null;
    if (populateChildren) {
      node.newChildren = [];
    }
    switch (node.instruction) {
      case SpreadsheetConstants.refFromAttColMsg:
        if (populateChildren) {
          for (int pointerRowId
              in _treeController.attToRefFromAttColToCol[node.att]!.keys) {
            node.newChildren!.add(NodeStruct(rowId: pointerRowId));
          }
        }
        break;
      case SpreadsheetConstants.refFromDepColMsg:
        if (populateChildren) {
          for (int pointerRowId
              in _treeController.attToRefFromDepColToCol[node.att]!.keys) {
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
        _treeController.populateAttToRefFromDepColNode(node, populateChildren);
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
          if (_treeController.attToCol.containsKey(node.name)) {
            if (_treeController.attToCol[node.name]! !=
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
              _treeController.populateAttToRefFromDepColNode(
                node,
                populateChildren,
              );
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
      if (_treeController.attToRefFromAttColToCol.containsKey(node.att)) {
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
      if (_treeController.attToRefFromDepColToCol.containsKey(node.att)) {
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
      node.onTap = (n) {
        if (node.rowId != null) {
          _onCellSelected(node.rowId!, 0, false, false);
          return;
        }

        List<Cell> cells = [];
        List<MapEntry> entries = [];

        if (node.colId != SpreadsheetConstants.notUsedCst) {
          entries = _treeController.attToRefFromAttColToCol[node.att]!.entries
              .toList();
        }

        if (node.instruction !=
            SpreadsheetConstants.moveToUniqueMentionSprawlCol) {
          entries.addAll(
            _treeController.attToRefFromDepColToCol[node.att]!.entries.toList(),
          );
        }

        for (final MapEntry(key: rowId, value: colIds) in entries) {
          for (final colId in colIds) {
            cells.add(Cell(rowId: rowId, colId: colId));
          }
        }
        _handleSelectionCycling(node, cells);
      };
      node.defaultOnTap = false;
    }
  }

  void _populateCellNode(NodeStruct node, bool populateChildren) {
    int rowId = node.rowId!;
    int colId = node.colId!;
    node.cellsToSelect = node.cells;

    if (rowId >= _dataController.rowCount ||
        colId >= _dataController.colCount) {
      return;
    }

    if (node.message == null) {
      if (node.instruction == SpreadsheetConstants.selectionMsg) {
        node.message =
            '${GetNames.getColumnLabel(colId)}$rowId selected: ${_dataController.getContent(rowId, colId)}';
      } else {
        node.message =
            '${GetNames.getColumnLabel(colId)}$rowId: ${_dataController.getContent(rowId, colId)}';
      }
    }

    if (node.defaultOnTap) {
      node.onTap = (n) {
        _onCellSelected(node.rowId!, node.colId!, false, false);
      };
      node.defaultOnTap = false;
    }

    if (!populateChildren) return;

    node.newChildren = [];

    // Check specific column types directly
    final colType = _dataController.sheetContent.columnTypes[colId];
    if (colType == ColumnType.names ||
        colType == ColumnType.filePath ||
        colType == ColumnType.urls) {
      node.newChildren!.add(
        NodeStruct(
          message: _dataController.sheetContent.table[rowId][colId],
          att: Attribute.row(rowId),
        ),
      );
      return;
    }

    if (_treeController.tableToAtt.length <= rowId ||
        _treeController.tableToAtt[rowId].length <= colId) {
      return;
    }

    for (Attribute att in _treeController.tableToAtt[rowId][colId]) {
      node.newChildren!.add(NodeStruct(att: att));
    }
  }

  void _populateRowNode(NodeStruct node, bool populateChildren) {
    int rowId = node.rowId!;
    node.message ??= GetNames.getRowName(
      _treeController.nameIndexes,
      _treeController.tableToAtt,
      rowId,
    );
    if (!populateChildren) return;

    List<NodeStruct> rowCells = [];
    for (int colId = 0; colId < _dataController.colCount; colId++) {
      if (_dataController.sheetContent.table[rowId][colId].isNotEmpty) {
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
    _populateAttributeNode(node, true);
  }

  void _populateColumnNode(NodeStruct node, bool populateChildren) {
    node.message ??= node.colId == -1
        ? "Rows"
        : 'Column ${GetNames.getColumnLabel(node.colId!)} "${_dataController.sheetContent.table[0][node.colId!]}"';
    if (!populateChildren) return;

    if (_treeController.colToAtt.containsKey(node.colId)) {
      for (final attCol in _treeController.colToAtt[node.colId]!) {
        node.newChildren!.add(NodeStruct(att: attCol));
      }
    }
  }

  // --- Tap Logic Helpers ---

  void _handleSelectionCycling(NodeStruct node, List<Cell> cells) {
    int found = -1;
    for (int i = 0; i < cells.length; i++) {
      final child = cells[i];
      if (_selectionController.primarySelectedCell.x == child.rowId &&
          _selectionController.primarySelectedCell.y == child.colId) {
        found = i;
        break;
      }
    }

    int index = (found == -1) ? 0 : (found + 1) % cells.length;
    _onCellSelected(cells[index].rowId, cells[index].colId, false, false);
  }

  void _handleCycleDetectedTap(NodeStruct node) {
    node.onTap = (n) {
      int found = -1;
      for (int i = 0; i < n.newChildren!.length; i++) {
        final child = n.newChildren![i];
        if (_selectionController.primarySelectedCell.x == child.rowId) {
          found = i;
          break;
        }
      }
      if (found == -1) {
        _onCellSelected(
          n.newChildren![0].rowId!,
          n.newChildren![0].colId!,
          false,
          false,
        );
      } else {
        final nextChild = n.newChildren![(found + 1) % n.newChildren!.length];
        _onCellSelected(nextChild.rowId!, nextChild.colId!, false, false);
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
          if (_selectionController.primarySelectedCell.x == child.rowId &&
              _selectionController.primarySelectedCell.y == child.colId) {
            found = i;
            break;
          }
        }
        final nextIndex =
            (found == -1) ? 0 : (found + 1) % node.cellsToSelect!.length;
        _onCellSelected(
          node.cellsToSelect![nextIndex].rowId,
          node.cellsToSelect![nextIndex].colId,
          false,
          false,
        );
      };
      node.defaultOnTap = false;
    }
  }
}