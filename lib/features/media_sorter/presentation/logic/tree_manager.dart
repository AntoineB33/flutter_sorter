import 'dart:math';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/calculate_usecase.dart';
import '../../domain/usecases/get_sheet_data_usecase.dart';
import '../../domain/usecases/save_sheet_data_usecase.dart'; // Assume created
import '../../domain/entities/column_type.dart';
import '../../domain/usecases/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import '../../domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/isolate_messages.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/instr_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/nodes_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/tree_manager.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/selection_manager.dart';
import '../controllers/spreadsheet_controller.dart';
import '../../domain/entities/node_struct.dart';
// ... import other entities

class TreeManager {
  // Pass the controller (or specific state) to the manager so it can access data
  final SpreadsheetController _controller;

  TreeManager(this._controller);
  

  void populateCellNode(NodeStruct node, bool populateChildren) {
    int rowId = node.rowId!;
    int colId = node.colId!;
    node.cellsToSelect = node.cells;
    if (rowId >= _controller.rowCount || colId >= _controller.colCount) return;
    if (node.message == null) {
      if (node.instruction == SpreadsheetConstants.selectionMsg) {
        node.message =
            '${_controller.getColumnLabel(colId)}$rowId selected: ${_controller.table[rowId][colId]}';
      } else {
        node.message = '${_controller.getColumnLabel(colId)}$rowId: ${_controller.table[rowId][colId]}';
      }
    }
    if (!populateChildren) {
      return;
    }
    node.newChildren = [];
    if (_controller.columnTypes[colId] == ColumnType.names.name ||
        _controller.columnTypes[colId] == ColumnType.filePath.name ||
        _controller.columnTypes[colId] == ColumnType.urls.name) {
      node.newChildren!.add(
        NodeStruct(
          message: _controller.table[rowId][colId],
          att: Attribute.row(rowId),
        ),
      );
      return;
    }
    for (Attribute att in _controller.tableToAtt[rowId][colId]) {
      node.newChildren!.add(NodeStruct(att: att));
    }
  }

  void populateAttributeNode(NodeStruct node, bool populateChildren) {
    if (populateChildren) {
      if (_controller.attToRefFromAttColToCol.containsKey(node.att)) {
        node.newChildren!.add(
          NodeStruct(
            instruction: SpreadsheetConstants.refFromAttColMsg,
            att: node.att,
          ),
        );
      } else {
        node.newChildren!.add(
          NodeStruct(
            message: 'No references from attribute columns found',
          ),
        );
      }
      if (_controller.attToRefFromDepColToCol.containsKey(node.att)) {
        node.newChildren!.add(
          NodeStruct(
            instruction: SpreadsheetConstants.refFromDepColMsg,
            att: node.att,
          ),
        );
      } else {
        node.newChildren!.add(
          NodeStruct(
            message: 'No references from dependence columns found',
          ),
        );
      }
    }
    node.message ??= node.name;
    if (node.defaultOnTap) {
      node.onTap = (n) {
        List<Cell> cells = [];
        List<MapEntry> entries = _controller.attToRefFromAttColToCol[node.att]!.entries.toList();
        if (node.instruction !=
            SpreadsheetConstants.moveToUniqueMentionSprawlCol) {
          entries.addAll(_controller.attToRefFromDepColToCol[node.att]!.entries.toList());
        }
        for (final MapEntry(key: rowId, value: colIds) in entries) {
          for (final colId in colIds) {
            cells.add(Cell(rowId: rowId, colId: colId));
          }
        }
        int found = -1;
        for (int i = 0; i < cells.length; i++) {
          final child = cells[i];
          if (_controller.selectionStart.x == child.rowId && _controller.selectionStart.y == child.colId) {
            found = i;
            break;
          }
        }
        if (found == -1) {
          _controller.selectCell(cells[0].rowId, 0);
        } else {
          _controller.selectCell(
            cells[(found + 1) % cells.length].rowId,
            cells[(found + 1) % cells.length].colId,
          );
        }
      };
      node.defaultOnTap = false;
    }
  }

  void populateRowNode(NodeStruct node, bool populateChildren) {
    int rowId = node.rowId!;
    node.message ??= _controller.nodesUsecase.getRowName(rowId);
    if (!populateChildren) {
      return;
    }
    List<NodeStruct> rowCells = [];
    for (int colId = 0; colId < _controller.colCount; colId++) {
      if (_controller.table[rowId][colId].isNotEmpty) {
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
    populateAttributeNode(node, true);
  }

  void populateColumnNode(NodeStruct node, bool populateChildren) {
    node.message ??=
        'Column ${_controller.getColumnLabel(node.colId!)} "${_controller.table[0][node.colId!]}"';
    if (!populateChildren) {
      return;
    }
    for (final attCol in _controller.colToAtt[node.colId]!) {
      node.newChildren!.add(NodeStruct(att: attCol));
    }
  }

  void populateAttToRefFromDepColNode(NodeStruct node, bool populateChildren) {
    if (!populateChildren) {
      return;
    }
    for (final rowId
        in _controller.attToRefFromDepColToCol[Attribute(name: node.name)]!.keys) {
      node.newChildren!.add(NodeStruct(rowId: rowId));
    }
  }

  void populateNodeDefault(NodeStruct node, bool populateChildren) {
    if (node.rowId != null) {
      if (node.colId != null) {
        if (node.name != null) {
          throw UnimplementedError(
            "CellWithName with name, row and col not implemented",
          );
        } else {
          populateCellNode(node, populateChildren);
        }
      } else {
        if (node.name != null) {
          throw UnimplementedError(
            "CellWithName with name and row not implemented",
          );
        } else {
          populateRowNode(node, populateChildren);
        }
      }
    } else {
      if (node.colId != null) {
        if (node.name != null) {
          populateAttributeNode(node, populateChildren);
        } else {
          populateColumnNode(node, populateChildren);
        }
      } else {
        if (node.name != null) {
          if (_controller.attToCol.containsKey(node.name)) {
            if (_controller.attToCol[node.name]! != [SpreadsheetConstants.notUsedCst]) {
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
              populateAttToRefFromDepColNode(node, populateChildren);
            }
          } else {
            debugPrint(
              "populateNode: Unhandled CellWithName with name only: ${node.name}",
            );
          }
        }
      }
    }
    if (node.defaultOnTap) {
      if (node.cellsToSelect == null) {
        List<Cell> cells = [];
        for (final child in node.children) {
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
        if (cells.isEmpty) {
          return;
        }
        node.cellsToSelect = cells;
      }
      node.onTap = (n) {
        if (node.cellsToSelect == null || node.cellsToSelect!.isEmpty) {
          return;
        }
        int found = -1;
        for (int i = 0; i < node.cellsToSelect!.length; i++) {
          final child = node.cellsToSelect![i];
          if (_controller.selectionStart.x == child.rowId && _controller.selectionStart.y == child.colId) {
            found = i;
            break;
          }
        }
        if (found == -1) {
          _controller.selectCell(node.cellsToSelect![0].rowId, 0);
        } else {
          _controller.selectCell(
            node.cellsToSelect![(found + 1) % node.cellsToSelect!.length].rowId,
            node.cellsToSelect![(found + 1) % node.cellsToSelect!.length].colId,
          );
        }
      };
      node.defaultOnTap = false;
    }
  }

  void populateNode(NodeStruct node) {
    bool populateChildren = node.newChildren == null;
    if (populateChildren) {
      node.newChildren = [];
    }
    switch (node.instruction) {
      case SpreadsheetConstants.refFromAttColMsg:
        if (populateChildren) {
          for (int pointerRowId in _controller.attToRefFromAttColToCol[node.att]!.keys) {
            node.newChildren!.add(NodeStruct(rowId: pointerRowId));
          }
        }
        break;
      case SpreadsheetConstants.refFromDepColMsg:
        if (populateChildren) {
          for (int pointerRowId in _controller.attToRefFromDepColToCol[node.att]!.keys) {
            node.newChildren!.add(NodeStruct(rowId: pointerRowId));
          }
        }
        break;
      case SpreadsheetConstants.nodeAttributeMsg:
        populateAttributeNode(node, populateChildren);
        break;
      case SpreadsheetConstants.cell:
        populateCellNode(node, populateChildren);
        break;
      case SpreadsheetConstants.cycleDetected:
        node.onTap = (n) {
          int found = -1;
          for (int i = 0; i < n.newChildren!.length; i++) {
            final child = n.newChildren![i];
            if (_controller.selectionStart.x == child.rowId) {
              found = i;
              break;
            }
          }
          if (found == -1) {
            _controller.selectCell(n.newChildren![0].rowId!, 0);
          } else {
            _controller.selectCell(
              n.newChildren![(found + 1) % n.newChildren!.length].rowId!,
              0,
            );
          }
        };
        break;
      case SpreadsheetConstants.attToRefFromDepCol:
        populateAttToRefFromDepColNode(node, populateChildren);
        break;
      default:
        populateNodeDefault(node, populateChildren);
        break;
    }
  }

  void populateTree(List<NodeStruct> roots) {
    // TODO keep same expansion if the user just moved, or even if there have been changes
    // List<int> newRowIndexes = [];
    // List<int> newColIndexes = [];
    // Map<String, String> newNameToOldName = {};
    for (final root in roots) {
      var stack = [root];
      while (stack.isNotEmpty) {
        var node = stack.removeLast();
        populateNode(node);
        if (node.isExpanded) {
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
        node.children = node.newChildren!;
      }
    }
  }
}