import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import '../../domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart'; // Import AnalysisResult
import 'spreadsheet_controller.dart';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/calculate_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/instr_struct.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';

class TreeController extends ChangeNotifier {
  final SpreadsheetController _controller;
  final GetNames _getNames = GetNames();

  // --- STATE HELD BY MANAGER ---
  AnalysisResult _lastAnalysis = AnalysisResult.empty();

  final NodeStruct mentionsRoot = NodeStruct(
    instruction: SpreadsheetConstants.selectionMsg,
  );

  final NodeStruct searchRoot = NodeStruct(
    instruction: SpreadsheetConstants.searchMsg,
  );

  NodeStruct get errorRoot => _lastAnalysis.errorRoot;
  NodeStruct get warningRoot => _lastAnalysis.warningRoot;
  NodeStruct get categoriesRoot => _lastAnalysis.categoriesRoot;
  NodeStruct get distPairsRoot => _lastAnalysis.distPairsRoot;

  List<int> get pathIndexes => _lastAnalysis.pathIndexes;

  Map<Attribute, Map<int, Cols>> get attToRefFromAttColToCol =>
      _lastAnalysis.attToRefFromAttColToCol;
  Map<Attribute, Map<int, List<int>>> get attToRefFromDepColToCol =>
      _lastAnalysis.attToRefFromDepColToCol;

  /// Maps attribute identifiers (row index or name)
  /// to a map of mentioners (row index) to the column index
  Map<Attribute, Map<int, List<int>>> get toMentioners =>
      _lastAnalysis.toMentioners;
  List<Map<InstrStruct, Cell>> get instrTable => _lastAnalysis.instrTable;
  Map<int, HashSet<Attribute>> get colToAtt => _lastAnalysis.colToAtt;

  int rowCount = 0;
  int colCount = 0;

  TreeController(this._controller);

  /// Call this when the Controller finishes a calculation.
  /// The Manager takes ownership of updating the tree state.
  void onAnalysisComplete(
    AnalysisResult result,
    Point<int> primarySelectedCell,
    int rowCount,
    int colCount,
  ) {
    _lastAnalysis = result;
    this.rowCount = rowCount;
    this.colCount = colCount;

    // Reset specific roots
    mentionsRoot.newChildren = null;
    mentionsRoot.rowId = primarySelectedCell.x;
    mentionsRoot.colId = primarySelectedCell.y;
    searchRoot.newChildren = null;

    // Populate the full tree using the new result
    populateTree([
      result.errorRoot,
      result.warningRoot,
      mentionsRoot,
      searchRoot,
      result.categoriesRoot,
      result.distPairsRoot,
    ]);
  }

  // --- LOGIC ---

  void populateCellNode(NodeStruct node, bool populateChildren) {
    int rowId = node.rowId!;
    int colId = node.colId!;
    node.cellsToSelect = node.cells;

    if (rowId >= rowCount || colId >= colCount) return;

    if (node.message == null) {
      if (node.instruction == SpreadsheetConstants.selectionMsg) {
        node.message =
            '${_getNames.getColumnLabel(colId)}$rowId selected: ${_controller.sheetContent.table[rowId][colId]}';
      } else {
        node.message =
            '${_getNames.getColumnLabel(colId)}$rowId: ${_controller.sheetContent.table[rowId][colId]}';
      }
    }

    if (node.defaultOnTap) {
      node.onTap = (n) {
        _controller.setPrimarySelection(node.rowId!, node.colId!, false, false);
      };
      node.defaultOnTap = false;
    }

    if (!populateChildren) return;

    node.newChildren = [];

    // Simple column types (names, files, urls) don't need deep analysis data
    if (_controller.sheetContent.columnTypes[colId] == ColumnType.names ||
        _controller.sheetContent.columnTypes[colId] == ColumnType.filePath ||
        _controller.sheetContent.columnTypes[colId] == ColumnType.urls) {
      node.newChildren!.add(
        NodeStruct(
          message: _controller.sheetContent.table[rowId][colId],
          att: Attribute.row(rowId),
        ),
      );
      return;
    }

    // Use LOCAL _lastAnalysis state instead of _controller lookup
    if (_lastAnalysis.tableToAtt.length <= rowId ||
        _lastAnalysis.tableToAtt[rowId].length <= colId) {
      return;
    }

    for (Attribute att in _lastAnalysis.tableToAtt[rowId][colId]) {
      node.newChildren!.add(NodeStruct(att: att));
    }
  }

  void populateAttributeNode(NodeStruct node, bool populateChildren) {
    if (populateChildren) {
      if (_lastAnalysis.attToRefFromAttColToCol.containsKey(node.att)) {
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
      if (_lastAnalysis.attToRefFromDepColToCol.containsKey(node.att)) {
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
          _controller.setPrimarySelection(node.rowId!, 0, false, false);
          return;
        }

        List<Cell> cells = [];
        List<MapEntry> entries = [];

        if (node.colId != SpreadsheetConstants.notUsedCst) {
          entries = _lastAnalysis.attToRefFromAttColToCol[node.att]!.entries
              .toList();
        }

        if (node.instruction !=
            SpreadsheetConstants.moveToUniqueMentionSprawlCol) {
          entries.addAll(
            _lastAnalysis.attToRefFromDepColToCol[node.att]!.entries.toList(),
          );
        }

        for (final MapEntry(key: rowId, value: colIds) in entries) {
          for (final colId in colIds) {
            cells.add(Cell(rowId: rowId, colId: colId));
          }
        }

        // ... (Selection logic remains the same, invoking _controller.setPrimarySelection)
        _handleSelectionLogic(node, cells);
      };
      node.defaultOnTap = false;
    }
  }

  // Extracted selection logic to keep populateAttributeNode cleaner
  void _handleSelectionLogic(NodeStruct node, List<Cell> cells) {
    int found = -1;
    for (int i = 0; i < cells.length; i++) {
      final child = cells[i];
      if (_controller.primarySelectedCell.x == child.rowId &&
          _controller.primarySelectedCell.y == child.colId) {
        found = i;
        break;
      }
    }

    int index = (found == -1) ? 0 : (found + 1) % cells.length;
    _controller.setPrimarySelection(
      cells[index].rowId,
      cells[index].colId,
      false,
      false,
    );
  }

  void populateRowNode(NodeStruct node, bool populateChildren) {
    int rowId = node.rowId!;
    node.message ??= _getNames.getRowName(_lastAnalysis, rowId);
    if (!populateChildren) return;

    List<NodeStruct> rowCells = [];
    for (int colId = 0; colId < _controller.colCount; colId++) {
      if (_controller.sheetContent.table[rowId][colId].isNotEmpty) {
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
    node.message ??= node.colId == -1
        ? "Rows"
        : 'Column ${_getNames.getColumnLabel(node.colId!)} "${_controller.sheetContent.table[0][node.colId!]}"';
    if (!populateChildren) return;

    if (_lastAnalysis.colToAtt.containsKey(node.colId)) {
      for (final attCol in _lastAnalysis.colToAtt[node.colId]!) {
        node.newChildren!.add(NodeStruct(att: attCol));
      }
    }
  }

  void populateAttToRefFromDepColNode(NodeStruct node, bool populateChildren) {
    if (!populateChildren) return;

    final attribute = Attribute(name: node.name);
    for (final rowId
        in _lastAnalysis.attToRefFromDepColToCol[attribute]!.keys) {
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
          if (_lastAnalysis.attToCol.containsKey(node.name)) {
            if (_lastAnalysis.attToCol[node.name]! !=
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
    // ... (Keep existing defaultOnTap logic, but use _controller for actions only)
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
          if (_controller.primarySelectedCell.x == child.rowId &&
              _controller.primarySelectedCell.y == child.colId) {
            found = i;
            break;
          }
        }
        if (found == -1) {
          _controller.setPrimarySelection(
            node.cellsToSelect![0].rowId,
            node.cellsToSelect![0].colId,
            false,
            false,
          );
        } else {
          _controller.setPrimarySelection(
            node.cellsToSelect![(found + 1) % node.cellsToSelect!.length].rowId,
            node.cellsToSelect![(found + 1) % node.cellsToSelect!.length].colId,
            false,
            false,
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
          for (int pointerRowId
              in _lastAnalysis.attToRefFromAttColToCol[node.att]!.keys) {
            node.newChildren!.add(NodeStruct(rowId: pointerRowId));
          }
        }
        break;
      case SpreadsheetConstants.refFromDepColMsg:
        if (populateChildren) {
          for (int pointerRowId
              in _lastAnalysis.attToRefFromDepColToCol[node.att]!.keys) {
            node.newChildren!.add(NodeStruct(rowId: pointerRowId));
          }
        }
        break;
      case SpreadsheetConstants.nodeAttributeMsg:
        populateAttributeNode(node, populateChildren);
        break;
      case SpreadsheetConstants.cycleDetected:
        node.onTap = (n) {
          int found = -1;
          for (int i = 0; i < n.newChildren!.length; i++) {
            final child = n.newChildren![i];
            if (_controller.primarySelectedCell.x == child.rowId) {
              found = i;
              break;
            }
          }
          if (found == -1) {
            _controller.setPrimarySelection(
              n.newChildren![0].rowId!,
              n.newChildren![0].colId!,
              false,
              false,
            );
          } else {
            _controller.setPrimarySelection(
              n.newChildren![(found + 1) % n.newChildren!.length].rowId!,
              n.newChildren![(found + 1) % n.newChildren!.length].colId!,
              false,
              false,
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
    if (_lastAnalysis.noResult) return;

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

  // Method to allow Controller to toggle expansion
  void toggleNodeExpansion(NodeStruct node, bool isExpanded) {
    node.isExpanded = isExpanded;
    for (NodeStruct child in node.newChildren ?? []) {
      child.isExpanded = false;
    }
    populateTree([node]);
  }
}
