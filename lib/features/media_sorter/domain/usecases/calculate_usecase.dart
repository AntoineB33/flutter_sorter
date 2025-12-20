import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'dart:collection';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/dyn_and_int.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/instr_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/isolate_messages.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/nodes_usecase.dart';

class CalculateUsecase {
  final Object dataPackage;
  final AnalysisResult result;
  late final NodesUsecase nodesUsecase;

  List<List<String>> table = [];
  List<String> columnTypes = [];

  final NodeStruct errorRoot = NodeStruct(
    instruction: SpreadsheetConstants.errorMsg,
    newChildren: [],
    hideIfEmpty: true,
  );
  final NodeStruct warningRoot = NodeStruct(
    instruction: SpreadsheetConstants.warningMsg,
    newChildren: [],
    hideIfEmpty: true,
  );
  final NodeStruct mentionsRoot = NodeStruct(
    instruction: SpreadsheetConstants.selectionMsg,
    newChildren: [],
  );
  final NodeStruct searchRoot = NodeStruct(
    instruction: SpreadsheetConstants.searchMsg,
    newChildren: [],
  );
  final NodeStruct categoriesRoot = NodeStruct(
    instruction: SpreadsheetConstants.categoryMsg,
    newChildren: [],
  );
  final NodeStruct distPairsRoot = NodeStruct(
    instruction: SpreadsheetConstants.distPairsMsg,
    newChildren: [],
  );

  /// 2D table of attribute identifiers (row index or name)
  /// mentioned in each cell.
  List<List<HashSet<Attribute>>> tableToAtt = [];
  Map<String, Cell> names = {};
  Map<String, List<int>> attToCol = {};
  List<int> nameIndexes = [];
  List<int> pathIndexes = [];

  /// Maps attribute identifiers (row index or name)
  /// to a map of pointers (row index) to the column index,
  /// in this direction so it is easy to diffuse characteristics to pointers.
  Map<Attribute, Map<int, int>> attToRefFromAttColToCol = {};
  Map<int, Map<Attribute, int>> rowToAttToCol = {};

  /// Maps attribute identifiers (row index or name)
  /// to a map of mentioners (row index) to the column index
  Map<Attribute, Map<int, List<int>>> attToRefFromDepColToCol = {};
  List<Map<InstrStruct, int>> instrTable = [];
  Map<int, HashSet<Attribute>> colToAtt = {};
  List<bool> isMedium = [];

  static const patternDistance = SpreadsheetConstants.patternDistance;
  static const patternAreas = SpreadsheetConstants.patternAreas;
  static const all = SpreadsheetConstants.all;
  static const notUsedCst = SpreadsheetConstants.notUsedCst;

  int get rowCount => table.length;
  int get colCount => rowCount > 0 ? table[0].length : 0;

  CalculateUsecase(this.dataPackage, this.columnTypes)
    : result = AnalysisResult() {
    nodesUsecase = NodesUsecase(result);
  }

  IsolateMessage getMessage(
    List<List<String>> table,
    List<String> columnTypes,
  ) {
    if (table.length < 5000) {
      return RawDataMessage(table: table, columnTypes: columnTypes);
    } else {
      // TODO: Handle edge cases for data containing ';;;' or '|||'
      // Optimization: Using a safer separator or standard JSON
      // But keeping your logic for the example:
      final String combined = table.map((row) => row.join(';;;')).join('|||');
      final Uint8List bytes = utf8.encode(combined);
      final transferable = TransferableTypedData.fromList([bytes]);

      return TransferableDataMessage(
        dataPackage: transferable,
        columnTypes: columnTypes,
      );
    }
  }

  AnalysisResult run() {
    _decodeData();
    _getEverything();

    var result = AnalysisResult();
    result.errorRoot.newChildren = errorRoot.newChildren;
    result.warningRoot.newChildren = warningRoot.newChildren;
    result.mentionsRoot.newChildren = mentionsRoot.newChildren;
    result.searchRoot.newChildren = searchRoot.newChildren;
    result.categoriesRoot.newChildren = categoriesRoot.newChildren;
    result.distPairsRoot.newChildren = distPairsRoot.newChildren;

    result.tableToAtt = tableToAtt;
    result.names = names;
    result.attToCol = attToCol;
    result.nameIndexes = nameIndexes;

    result.pathIndexes = pathIndexes;
    result.attToRefFromAttColToCol = attToRefFromAttColToCol;
    result.attToRefFromDepColToCol = attToRefFromDepColToCol;
    result.rowToAtt = rowToAttToCol;
    result.toMentioners = attToRefFromDepColToCol;
    result.instrTable = instrTable;
    result.colToAtt = colToAtt;
    return result;
  }

  void _decodeData() {
    if (dataPackage is TransferableTypedData) {
      // 1. Materialize bytes and decode to String
      // We synchronize execution here to get the raw bytes out of the transferable wrapper
      final Uint8List bytes = (dataPackage as TransferableTypedData)
          .materialize()
          .asUint8List();
      final String giantString = utf8.decode(bytes);

      // 2. Reconstruct List<List<String>>
      // First split by Row Delimiter (|||), then by Cell Delimiter (;;;)
      table = giantString
          .split('|||')
          .map((rowString) => rowString.split(';;;'))
          .toList();
    } else if (dataPackage is List<List<String>>) {
      table = dataPackage as List<List<String>>;
    } else {
      throw Exception("Invalid data package type");
    }
  }

  String getColumnType(int col) {
    if (col >= colCount) return ColumnType.attributes.name;
    return columnTypes[col];
  }

  List<String> generateUniqueStrings(int n) {
    const charset = 'abcdefghijklmnopqrstuvwxyz';
    List<String> result = [];
    int length = 1;

    // Dart version of the generator "product"
    Iterable<String> product(String chars, int repeat) sync* {
      if (repeat == 0) {
        yield "";
      } else {
        for (var c in chars.split('')) {
          for (var suffix in product(chars, repeat - 1)) {
            yield c + suffix;
          }
        }
      }
    }

    while (result.length < n) {
      for (final combo in product(charset, length)) {
        result.add(combo);
        if (result.length == n) {
          return result;
        }
      }
      length++;
    }

    return result;
  }

  int getIndexFromString(String s) {
    int result = 0;
    for (int i = 0; i < s.length; i++) {
      int codeUnit = s.codeUnitAt(i);

      // Validate: ASCII for 'a' is 97, 'z' is 122.
      // If it's outside this range, it's not a lowercase letter.
      if (codeUnit < 97 || codeUnit > 122) {
        throw FormatException(
          "Invalid character '${s[i]}' at index $i. Input must only contain lowercase letters (a-z).",
        );
      }

      // 'a' (97) becomes 0, 'b' (98) becomes 1, etc.
      int value = codeUnit - 97;
      result = result * 26 + value;
    }
    return result;
  }

  List<Cell> findPath(
    dynamic graph,
    int start,
    int end, {
    bool reverse = true,
  }) {
    int row = start;
    List<Cell> path = [];
    while (true) {
      if (graph[row]![end] != -1) {
        path.add(Cell(row: end, col: graph[row]![end]!));
        return reverse ? path.reversed.toList() : path;
      }
      for (final child in graph[row]!.keys) {
        if (graph[child]!.containsKey(end)) {
          path.add(Cell(row: child, col: graph[row]![child]!));
          row = child;
          break;
        }
      }
    }
  }

  void dfsIterative(
    Map<dynamic, Map<dynamic, int>> graph,
    dynamic accumulator,
    String warningMsgPrefix,
  ) {
    final visited = <dynamic>{};
    final completed = <dynamic>{};
    List<dynamic> path = [];

    final List<NodeStruct> redundantRef = [];
    for (final start in graph.keys) {
      if (visited.contains(start)) continue;
      final stack = [start];

      while (stack.isNotEmpty) {
        final node = stack[stack.length - 1]; // peek
        if (path.isNotEmpty && path[path.length - 1] == node) {
          Map nodeChildren = accumulator[node] ?? {};

          for (final child in nodeChildren.keys) {
            Map<dynamic, int>? childMap = graph[child];
            if (childMap != null) {
              for (final grandChild in childMap.keys) {
                if (!nodeChildren.containsKey(grandChild)) {
                  nodeChildren[grandChild] = -1;
                } else if (nodeChildren[grandChild] != -1) {
                  var newPath =
                      [
                            ...findPath(graph, child, grandChild),
                            Cell(row: node, col: graph[child]![node]!),
                          ]
                          .map(
                            (k) => NodeStruct(
                              instruction: SpreadsheetConstants.cell,
                              cell: k,
                            ),
                          )
                          .toList();
                  redundantRef.add(
                    NodeStruct(
                      instruction: SpreadsheetConstants.cell,
                      message:
                          "$warningMsgPrefix \"$grandChild\" already pointed",
                      att: Attribute(row: node, col: nodeChildren[grandChild]),
                      newChildren: newPath,
                    ),
                  );
                }
              }
            }
          }

          completed.add(node);
          path.removeLast();
          stack.removeLast();
          continue;
        }

        if (visited.contains(node)) {
          stack.removeLast(); // already processed
          continue;
        }

        visited.add(node);
        path.add(node);

        final neighborsMap = graph[node] ?? {};
        final neighbors = neighborsMap.keys.toList();

        for (int i = neighbors.length - 1; i >= 0; i--) {
          final child = neighbors[i];
          if (!visited.contains(child)) {
            stack.add(child);
          } else if (!completed.contains(child)) {
            final cycle = path.sublist(path.indexOf(child));
            final cyclePathNodes = cycle
                .map(
                  (k) => NodeStruct(
                    instruction: SpreadsheetConstants.row,
                    rowId: k,
                  ),
                )
                .toList();
            errorRoot.newChildren!.add(
              NodeStruct(
                instruction: SpreadsheetConstants.cycleDetected,
                newChildren: cyclePathNodes,
              ),
            );
            return;
          }
        }
      }
    }

    // Add redundant reference warningRoot
    if (redundantRef.isNotEmpty) {
      warningRoot.newChildren!.add(
        NodeStruct(
          message: "redundant references found",
          newChildren: redundantRef,
        ),
      );
    }
  }

  List<List<int>> getIntervals(String intervalStr, int row, int col) {
    // First, parse the positions of intervals
    var intervals = [[], []];
    var negPos = intervalStr.split("|");
    var positive = 0;

    for (var negPosPart in [negPos[0], negPos[2]]) {
      var parts = negPosPart.split("_");
      for (var part in parts) {
        if (part.isEmpty) {
          intervals[positive].add([null, null]);
        } else if (part.contains(":")) {
          var [startStr, endStr] = part.split(":");

          var start = int.tryParse(startStr);
          start ??= double.infinity.toInt();

          var end = int.tryParse(endStr);
          end ??= double.infinity.toInt();

          if (positive == 0) {
            start = -start;
            end = -end;
          }
          intervals[positive].add([start, end]);
        } else {
          var num = int.parse(part);
          intervals[positive].add([num, num]);
        }
      }
      positive = 1;
    }

    // Now calculate underscore intervals
    List<List<int>> resultList = [];
    positive = 0;

    for (var negPosPart in intervals) {
      for (var i = 0; i < negPosPart.length - 1; i++) {
        var endOfCurrent = negPosPart[i][1];
        var startOfNext = negPosPart[i + 1][0];

        if (endOfCurrent == null) {
          if (positive == 0) {
            endOfCurrent = -double.infinity.toInt();
          } else if (resultList.isNotEmpty &&
              resultList[resultList.length - 1][1] == -1) {
            endOfCurrent = resultList[resultList.length - 1][0] - 1;
            resultList.removeLast();
          } else {
            endOfCurrent = 0;
          }
        }

        if (startOfNext == null) {
          if (positive == 0) {
            startOfNext = 0;
          } else {
            startOfNext = double.infinity.toInt();
          }
        }

        if (startOfNext - endOfCurrent <= 1) {
          errorRoot.newChildren!.add(
            NodeStruct(
              instruction: SpreadsheetConstants.cell,
              message:
                  "Invalid interval: overlapping or adjacent intervals found.",
              rowId: row,
              colId: col,
            ),
          );
          return [];
        }

        resultList.add([endOfCurrent + 1, startOfNext - 1]);
      }
      positive = 1;
    }

    return resultList;
  }

  Attribute getAttAndCol(String attWritten, int rowId, int colId) {
    Attribute att = Attribute();
    List<String> splitStr = attWritten.split(".");
    String name = attWritten;
    int attColId = notUsedCst;
    if (splitStr.length == 2) {
      name = splitStr[1];
      attColId = getIndexFromString(splitStr[0]);
      if (attColId < 0 || attColId >= colCount) {
        warningRoot.newChildren!.add(
          NodeStruct(
            message: "Column ${splitStr[0]} does not exist",
            att: Attribute(row: rowId, col: colId),
          ),
        );
        return att;
      }
    } else if (splitStr.length > 2) {
      errorRoot.newChildren!.add(
        NodeStruct(
          message: "Invalid attribute format: too many '.' characters",
          att: Attribute(row: rowId, col: colId),
        ),
      );
      return att;
    }
    var fromDep =
        columnTypes[colId] != ColumnType.attributes.name &&
        columnTypes[colId] != ColumnType.sprawl.name;
    final numK = int.tryParse(name);
    if (numK != null) {
      if (attColId != notUsedCst) {
        errorRoot.newChildren!.add(
          NodeStruct(
            message:
                "Cannot use both column and row index for attribute reference",
            att: Attribute(row: rowId, col: colId),
          ),
        );
        return att;
      }
      if (numK < 1 || numK > rowCount - 1) {
        warningRoot.newChildren!.add(
          NodeStruct(
            message: "$name points to an empty row $numK",
            att: Attribute(row: rowId, col: colId),
          ),
        );
      }
      att = Attribute(row: numK);
    } else {
      // TODO: validate attribute name
      if (attColId != notUsedCst) {
        if (columnTypes[attColId] != ColumnType.attributes.name &&
            columnTypes[attColId] != ColumnType.sprawl.name) {
          errorRoot.newChildren!.add(
            NodeStruct(
              message:
                  "Column ${nodesUsecase.getColumnLabel(attColId)} is not an attribute column",
              att: Attribute(row: rowId, col: colId),
            ),
          );
          return att;
        }
        if (fromDep) {
          att = Attribute(name: name, col: attColId);
          if (!attToRefFromAttColToCol.containsKey(att)) {
            colToAtt[notUsedCst]!.add(att);
          }
        } else if (attColId != colId) {
          warningRoot.newChildren!.add(
            NodeStruct(
              message:
                  "Attribute column ${nodesUsecase.getColumnLabel(attColId)} differs from current column ${nodesUsecase.getColumnLabel(colId)}",
              att: Attribute(row: rowId, col: colId),
            ),
          );
        }
      } else if (!fromDep) {
        attColId = colId;
      }
      att = Attribute(name: name, col: attColId);
    }
    tableToAtt[rowId][colId].add(att);
    if (!fromDep) {
      rowToAttToCol[rowId]![att] = colId;
    }
    colToAtt[attColId]!.add(att);
    if (!attToCol.containsKey(attWritten)) {
      attToCol[attWritten] = [];
    }
    if (attColId != all) {
      if (attToCol[attWritten]!.contains(attColId) == false) {
        attToCol[attWritten]!.add(attColId);
      }
    }
    return att;
  }

  void _getCategories() {
    // final saved = {
    //   input: { name: name, table: table, columnTypes: columnTypes },
    //   output: { errorRoot: errorRoot },
    // };

    if (errorRoot.newChildren!.isNotEmpty) {
      return;
    }
    
    isMedium = List<bool>.filled(rowCount, false);
    for (int rowId = 1; rowId < rowCount; rowId++) {
      for (int colId = 0; colId < rowCount; colId++) {
        isMedium[rowId] = isMedium[rowId] || columnTypes[colId] == ColumnType.filePath.name ||
          columnTypes[colId] == ColumnType.urls.name;
      }
    }

    colToAtt = {};
    Map<Attribute, List<int>> attToDist = {};
    DynAndInt firstElement = DynAndInt(-1, -1);
    DynAndInt lastElement = DynAndInt(-1, -1);
    final Map fstCat = {};
    final Map lstCat = {};
    colToAtt[all] = HashSet<Attribute>();
    colToAtt[notUsedCst] = HashSet<Attribute>();
    for (int colId = 0; colId < colCount; colId++) {
      if (columnTypes[colId] == ColumnType.attributes.name ||
          columnTypes[colId] == ColumnType.sprawl.name) {
        colToAtt[colId] = HashSet<Attribute>();
      }
    }
    List<NodeStruct> children = [];
    attToRefFromAttColToCol = {};
    attToCol = {};
    rowToAttToCol = {for (var i = 0; i < rowCount; i++) i: {}};
    for (int rowId = 1; rowId < rowCount; rowId++) {
      final row = table[rowId];
      for (int colId = 0; colId < rowCount; colId++) {
        final isSprawl = columnTypes[colId] == ColumnType.sprawl.name;
        if (columnTypes[colId] == ColumnType.attributes.name || isSprawl) {
          if (row[colId].isEmpty) {
            continue;
          }
          final cellList = row[colId].split("; ");
          for (String attWritten in cellList) {
            if (attWritten.isEmpty) {
              errorRoot.newChildren!.add(
                NodeStruct(
                  message: "empty attribute name",
                  att: Attribute(row: rowId, col: colId),
                ),
              );
              return;
            }

            bool isFst = attWritten.endsWith("-fst");
            bool isLst = false;

            if (isFst) {
              attWritten = attWritten
                  .substring(0, attWritten.length - 4)
                  .trim();
            } else if (attWritten == "fst") {
              if (firstElement.dyn != -1) {
                errorRoot.newChildren!.add(
                  NodeStruct(
                    message: "multiple 'fst' found",
                    newChildren: [
                      NodeStruct(
                        att: Attribute(
                          row: firstElement.dyn,
                          col: firstElement.id,
                        ),
                      ),
                      NodeStruct(
                        att: Attribute(row: rowId, col: colId),
                      ),
                    ],
                  ),
                );
                return;
              }
              firstElement = DynAndInt(rowId, colId);
              continue;
            } else if ((isLst = attWritten.endsWith("-lst"))) {
              attWritten = attWritten
                  .substring(0, attWritten.length - 4)
                  .trim();
            } else if (attWritten == "lst") {
              if (lastElement.dyn != -1) {
                errorRoot.newChildren!.add(
                  NodeStruct(
                    message: "multiple 'lst' found",
                    newChildren: [
                      NodeStruct(
                        att: Attribute(
                          row: lastElement.dyn,
                          col: lastElement.id,
                        ),
                      ),
                      NodeStruct(
                        att: Attribute(row: rowId, col: colId),
                      ),
                    ],
                  ),
                );
                return;
              }
              lastElement = DynAndInt(rowId, colId);
              continue;
            } else if (attWritten.contains("-fst")) {
              errorRoot.newChildren!.add(
                NodeStruct(
                  message: "'-fst' is not at the end of $attWritten",
                  att: Attribute(row: rowId, col: colId),
                ),
              );
              return;
            }

            Attribute att = getAttAndCol(attWritten, rowId, colId);
            if (errorRoot.newChildren!.isNotEmpty) {
              return;
            }

            if (!attToRefFromAttColToCol.containsKey(att)) {
              attToRefFromAttColToCol[att] = {};
              if (isSprawl) {
                attToDist[att] = [];
              }
            }

            if (!attToRefFromAttColToCol[att]!.containsKey(rowId)) {
              attToRefFromAttColToCol[att]![rowId] = colId;
              if (isSprawl) {
                attToDist[att]!.add(rowId);
              }
            } else {
              children.add(
                NodeStruct(
                  att: Attribute(row: rowId, col: colId),
                ),
              );
            }

            if (isFst) {
              fstCat[rowId] = DynAndInt(att, colId);
            } else if (isLst) {
              lstCat[rowId] = DynAndInt(att, colId);
            }
          }
        }
      }
    }
    if (children.isNotEmpty) {
      warningRoot.newChildren!.add(
        NodeStruct(
          message: "redundant attributes found",
          newChildren: children,
        ),
      );
    }

    dfsIterative(attToRefFromAttColToCol, attToRefFromAttColToCol, "attribute");

    if (errorRoot.newChildren!.isNotEmpty) {
      return;
    }

    List<List<String>> urls = List.generate(
      rowCount,
      (i) => List.generate(pathIndexes.length, (j) => table[i][pathIndexes[j]]),
    );

    var urlFrom = List.generate(rowCount, (i) => -1);
    for (int i = 1; i < rowCount; i++) {
      final row = table[i];
      Attribute att = Attribute(row: i, col: all);
      if (isMedium[i] && attToRefFromAttColToCol.containsKey(att)) {
        for (final k in attToRefFromAttColToCol[att]!.keys) {
          if (isMedium[k]) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "URL conflict",
                startOpen: true,
                newChildren: [
                  NodeStruct(
                    message: "path 1",
                    startOpen: true,
                    newChildren:
                        findPath(attToRefFromAttColToCol, urlFrom[k], k)
                            .map(
                              (x) => NodeStruct(
                                att: Attribute(row: x.row, col: x.col),
                              ),
                            )
                            .toList(),
                  ),
                  NodeStruct(
                    message: "path 2",
                    startOpen: true,
                    newChildren: findPath(attToRefFromAttColToCol, i, k)
                        .map(
                          (x) => NodeStruct(
                            att: Attribute(row: x.row, col: x.col),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            );
            return;
          }
          if (!attToRefFromAttColToCol.containsKey(att)) {
            urls[k] = List.generate(
              pathIndexes.length,
              (j) => row[pathIndexes[j]],
            );
            urlFrom[k] = i;
          }
        }
      }
    }

    final validRowIndexes = [];
    final newIndexes = List.generate(rowCount, (i) => i);
    final toOldIndexes = [];
    final catRows = [];
    int newIndex = 0;
    for (int i = 1; i < rowCount; i++) {
      if (isMedium[i]) {
        validRowIndexes.add(i);
        newIndexes[i] = newIndex;
        newIndex++;
        toOldIndexes.add(i);
      } else {
        catRows.add(i);
      }
    }

    if (validRowIndexes.isEmpty) {
      warningRoot.newChildren!.add(
        NodeStruct(message: "No valid rows found in the table!"),
      );
      return;
    }

    // Build categories and distance pairs
    for (var col in [...List.generate(colCount, (index) => index + 1), all]) {
      if (!colToAtt.containsKey(col) || colToAtt[col]!.isEmpty) {
        continue;
      }
      var attrs = colToAtt[col]!;
      List<NodeStruct> catColChildren = [];
      List<NodeStruct> spColChildren = [];
      for (final attr in attrs) {
        catColChildren.add(NodeStruct(att: attr));

        var rowsList = attToDist[attr]!;
        if (rowsList.length < 2) {
          warningRoot.newChildren!.add(
            NodeStruct(
              message: "Only one row for sprawl attribute \"${attr.name}\"",
              att: attr,
            ),
          );
          continue;
        }
        rowsList = rowsList..sort();
        final distPairs = List.filled(rowsList.length - 2, 0);
        int minDist = double.infinity.toInt();
        for (var i = 0; i < rowsList.length - 2; i++) {
          var d = (rowsList[i] - rowsList[i + 1]).abs();
          for (var k = rowsList[i] + 1; k < rowsList[i + 1]; k++) {
            if (!isMedium[k]) {
              d--;
            }
          }
          distPairs[i] = d;
          if (d < minDist) {
            minDist = d;
          }
        }
        spColChildren.add(
          NodeStruct(
            att: Attribute(name: attr.name),
            newChildren: distPairs.asMap().entries.map((entry) {
              final idx = entry.key;
              final d = entry.value;
              return NodeStruct(
                message:
                    "($d) ${nodesUsecase.getRowName(rowsList[idx])} - ${nodesUsecase.getRowName(rowsList[idx + 1])}",
                newChildren: [
                  NodeStruct(att: Attribute(row: rowsList[idx])),
                  NodeStruct(att: Attribute(row: rowsList[idx + 1])),
                ],
                dist: d,
              );
            }).toList()..sort((a, b) => a.dist! - b.dist!),
            minDist: minDist,
          ),
        );
      }
      categoriesRoot.newChildren!.add(
        NodeStruct(
          colId: col,
          newChildren: catColChildren
            ..sort(
              (a, b) =>
                  col != all ? a.name!.compareTo(b.name!) : a.row! - b.row!,
            ),
        ),
      );
      distPairsRoot.newChildren!.add(
        NodeStruct(
          att: Attribute(col: col),
          newChildren: spColChildren..sort((a, b) => a.minDist! - b.minDist!),
        ),
      );
    }

    instrTable = List.generate(rowCount, (_) => {});

    for (final MapEntry(key: k, value: v) in fstCat.entries) {
      if (isMedium[k]) {
        var t = v.att;
        while (fstCat.containsKey(t)) {
          t = fstCat[t]!.att;
        }
        for (final i in attToRefFromAttColToCol[t]!.keys) {
          if (i != k) {
            instrTable[i][InstrStruct(
                  true,
                  false,
                  [newIndexes[k]],
                  [
                    [-double.infinity.toInt(), -1],
                  ],
                )] =
                v.col;
          }
        }
      }
    }

    for (final MapEntry(key: k, value: v) in lstCat.entries) {
      if (isMedium[k]) {
        var t = v.att;
        while (lstCat.containsKey(t)) {
          t = lstCat[t]!.att;
        }
        for (final i in attToRefFromAttColToCol[t]!.keys) {
          if (i != k) {
            instrTable[i][InstrStruct(
                  true,
                  false,
                  [newIndexes[k]],
                  [
                    [1, double.infinity.toInt()],
                  ],
                )] =
                v.col;
          }
        }
      }
    }

    if (firstElement.dyn != -1) {
      if (attToRefFromAttColToCol.containsKey(firstElement.dyn)) {
        if (attToRefFromAttColToCol[firstElement.dyn]!.keys.length > 1 ||
            attToRefFromAttColToCol[firstElement.dyn]!.keys.length == 1 &&
                isMedium[firstElement.dyn]) {
          children = attToRefFromAttColToCol[firstElement.dyn]!.keys
              .map(
                (k) => NodeStruct(
                  att: Attribute(
                    row: k,
                    col: attToRefFromAttColToCol[firstElement.dyn]![k]!,
                  ),
                ),
              )
              .toList();
          children.add(
            NodeStruct(
              att: Attribute(row: firstElement.dyn, col: firstElement.id),
            ),
          );
          errorRoot.newChildren!.add(
            NodeStruct(message: "multiple 'fst' found", newChildren: children),
          );
          return;
        }
      }
      for (final i in validRowIndexes) {
        if (i != firstElement.dyn) {
          instrTable[i][InstrStruct(
                true,
                false,
                [newIndexes[firstElement.dyn]],
                [
                  [-double.infinity.toInt(), -1],
                ],
              )] =
              firstElement.id;
        }
      }
    }

    if (lastElement.dyn != -1) {
      if (attToRefFromAttColToCol.containsKey(lastElement.dyn)) {
        if (attToRefFromAttColToCol[lastElement.dyn]!.keys.length > 1 ||
            attToRefFromAttColToCol[lastElement.dyn]!.keys.length == 1 &&
                isMedium[lastElement.dyn]) {
          children = attToRefFromAttColToCol[lastElement.dyn]!.keys
              .map(
                (k) => NodeStruct(
                  att: Attribute(
                    row: k,
                    col: attToRefFromAttColToCol[lastElement.dyn]![k]!,
                  ),
                ),
              )
              .toList();
          children.add(
            NodeStruct(
              att: Attribute(row: lastElement.dyn, col: lastElement.id),
            ),
          );
          errorRoot.newChildren!.add(
            NodeStruct(message: "multiple 'lst' found", newChildren: children),
          );
          return;
        }
      }
      for (final i in validRowIndexes) {
        if (i != lastElement.dyn) {
          instrTable[i][InstrStruct(
                true,
                false,
                [newIndexes[lastElement.dyn]],
                [
                  [1, double.infinity.toInt()],
                ],
              )] =
              lastElement.id;
        }
      }
    }

    final depPattern = table[0].map((cell) => cell.split(".")).toList();

    final Map<int, Map<int, (Attribute, bool, RegExpMatch, List<List<int>>)>>
    depCache = {};
    for (int rowId = 1; rowId < rowCount; rowId++) {
      if (!isMedium[rowId] &&
          !(attToRefFromAttColToCol.containsKey(Attribute(row: rowId)))) {
        continue;
      }

      final row = table[rowId];
      for (int colId = 0; colId < row.length; colId++) {
        if (columnTypes[colId] == ColumnType.dependencies.name &&
            row[colId].isNotEmpty) {
          // TODO: OR and AND
          String instr = row[colId];
          if (instr.isEmpty) continue;
          final instrSplit = instr.split("_");
          if (instrSplit.length != depPattern[colId].length - 1 &&
              depPattern[colId].length > 1) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message:
                    "$instr does not match dependencies pattern ${depPattern[colId]}",
                att: Attribute(row: rowId, col: colId),
              ),
            );
            return;
          }

          if (depPattern[colId].length > 1) {
            instr =
                depPattern[colId][0] +
                instrSplit
                    .asMap()
                    .entries
                    .map((entry) {
                      final idx = entry.key;
                      final split = entry.value;
                      return split + depPattern[colId][idx + 1];
                    })
                    .join("");
          }

          var match = RegExp(patternDistance).firstMatch(instr);
          List<List<int>> intervals = [];
          var isConstraint = match == null;

          if (isConstraint) {
            match = RegExp(patternAreas).firstMatch(instr);
            if (match == null) {
              errorRoot.newChildren!.add(
                NodeStruct(
                  message: "$instr does not match expected format",
                  att: Attribute(row: rowId, col: colId),
                ),
              );
              return;
            }
            intervals = getIntervals(instr, rowId, colId);
            if (errorRoot.newChildren!.isNotEmpty) {
              return;
            }
          }

          Attribute att = getAttAndCol(match.namedGroup('att')!, rowId, colId);
          if (errorRoot.newChildren!.isNotEmpty) {
            return;
          }
          depCache[rowId] ??= {};
          depCache[rowId]![colId] = (att, isConstraint, match, intervals);
        }
      }
    }

    attToRefFromDepColToCol = {};
    for (var i = 0; i < rowCount; i++) {
      for (var j = 0; j < colCount; j++) {
        if (columnTypes[j] == ColumnType.dependencies.name) {
          for (final n in tableToAtt[i][j]) {
            if (!attToRefFromDepColToCol.containsKey(n)) {
              attToRefFromDepColToCol[n] = {};
            }
            if (!attToRefFromDepColToCol[n]!.containsKey(i)) {
              attToRefFromDepColToCol[n]![i] = [];
            }
            attToRefFromDepColToCol[n]![i]!.add(j);
          }
        }
      }
    }

    List<NodeStruct> unusedChildren = [];
    List<NodeStruct> ambiguousChildren = [];
    for (Attribute att in colToAtt[notUsedCst]!.toList()) {
      if (attToCol[att.name]!.isEmpty) {
        unusedChildren.add(NodeStruct(att: att));
      } else {
        colToAtt[notUsedCst]!.remove(att);
        if (attToCol[att.name]!.length == 1) {
          Attribute newAtt = Attribute(
            name: att.name,
            col: attToCol[att.name]![0],
          );
          for (int rowId in attToRefFromDepColToCol[att]!.keys) {
            for (int colId in attToRefFromDepColToCol[att]![rowId]!) {
              tableToAtt[rowId][colId].remove(att);
              tableToAtt[rowId][colId].add(newAtt);
            }
          }
        } else {
          ambiguousChildren.add(NodeStruct(att: att));
        }
      }
    }
    if (ambiguousChildren.isNotEmpty) {
      errorRoot.newChildren!.add(
        NodeStruct(
          message: "ambiguous attributes found",
          newChildren: ambiguousChildren,
        ),
      );
      return;
    }
    if (unusedChildren.isNotEmpty) {
      warningRoot.newChildren!.add(
        NodeStruct(
          message: "unused attributes found",
          newChildren: unusedChildren,
        ),
      );
    }

    for (int rowId = 1; rowId < rowCount; rowId++) {
      if (!isMedium[rowId] &&
          !(attToRefFromAttColToCol.containsKey(Attribute(row: rowId)))) {
        continue;
      }

      final row = table[rowId];
      for (int colId = 0; colId < row.length; colId++) {
        if (columnTypes[colId] == ColumnType.dependencies.name &&
            row[colId].isNotEmpty) {
          var att = depCache[rowId]![colId]!.$1;
          var isConstraint = depCache[rowId]![colId]!.$2;
          var match = depCache[rowId]![colId]!.$3;
          var intervals = depCache[rowId]![colId]!.$4;

          final numbers = [];
          for (final r in attToRefFromAttColToCol[att]!.keys) {
            if (isMedium[r]) {
              numbers.add(r);
            }
          }
          final mappedNumbers = numbers.map((x) => newIndexes[x]).toList();
          var instruction = InstrStruct(
            isConstraint,
            match.namedGroup('any') != null,
            mappedNumbers,
            intervals,
          );
          if (instrTable[rowId].containsKey(instruction)) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "duplicate instruction",
                att: Attribute(row: rowId, col: colId),
              ),
            );
          } else {
            instrTable[rowId][instruction] = colId;
          }
        }
      }
    }

    dfsIterative(rowToAttToCol, instrTable, "instruction");

    // // Detect cycles in instrTable
    // bool hasCycle(instrTable, visited, List<DynAndInt> stack, node, {bool after = true}) {
    //   stack.add(DynAndInt(node, id));
    //   visited.add(node);

    //   for (final neighbor in instrTable[node]) {
    //     if (
    //       neighbor.any ||
    //       !neighbor.isConstraint ||
    //       (after
    //         ? neighbor.intervals[0][0] != -double.infinity.toInt() ||
    //           neighbor.intervals[0][1] != -1
    //         : neighbor.intervals[neighbor.intervals.length - 1][0] != 1 ||
    //           neighbor.intervals[neighbor.intervals.length - 1][1] != double.infinity.toInt())
    //     ) {
    //       continue;
    //     }

    //     for (final target in neighbor.numbers) {
    //       if (!visited.has(target)) {
    //         if (hasCycle(instrTable, visited, stack, target, after: after)) {
    //           return true;
    //         }
    //       } else {
    //         final idx = stack.indexOf(target);
    //         if (idx != -1) {
    //           stack.removeRange(0, idx);
    //           stack.add(target);
    //           return true;
    //         }
    //       }
    //     }
    //   }
    //   stack.removeLast();
    //   return false;
    // }

    // for (var p = 0; p <= 1; p++) {
    //   Set<int> visited = {};
    //   List<int> stack = [];
    //   for (var i = 0; i < instrTable.length; i++) {
    //     if (hasCycle(instrTable, visited, stack, i, after: p == 1)) {
    //       children = stack.asMap().entries.map((entry) {
    //         var path = entry.value;
    //         if (path.length === 1) {
    //           return new NodeStruct({ id: path[0] });
    //         } else {
    //           return new NodeStruct({
    //             id: path[0],
    //             newChildren: path.sublist(1).map((p) => new NodeStruct({ id: p })),
    //           });
    //         }
    //       });
    //       errorRoot.newChildren!.add(NodeStruct(
    //           message: "Cycle detected in ${p == 1 ? "after" : "before"} constraints",
    //           newChildren: children,
    //         ),
    //       );
    //       return;
    //     }
    //   }
    // }

    urls = validRowIndexes.asMap().entries.map((i) {
      return urls[i.value];
    }).toList();

    // TODO: solve sorting pb
    return;
  }

  void _getEverything() {
    debugPrint("Processing spreadsheet data...");
    errorRoot.newChildren!.clear();
    warningRoot.newChildren!.clear();
    for (final row in table) {
      for (int idx = 0; idx < row.length; idx++) {
        row[idx] = row[idx].trim().toLowerCase();
      }
    }
    nameIndexes = [];
    pathIndexes = [];
    for (int index = 0; index < colCount; index++) {
      final role = getColumnType(index);
      if (role == ColumnType.names.name) {
        nameIndexes.add(index);
      } else if (role == ColumnType.filePath.name) {
        pathIndexes.add(index);
      }
    }
    tableToAtt = List.generate(
      rowCount,
      (_) => List.generate(colCount, (_) => HashSet<Attribute>()),
    );
    for (int i = 1; i < rowCount; i++) {
      for (int j in nameIndexes) {
        var cellElements = table[i][j].split(";");
        for (int k = 0; k < cellElements.length; k++) {
          cellElements[k] = cellElements[k].trim().toLowerCase();
          if (cellElements[k].isNotEmpty) {
            tableToAtt[i][j].add(Attribute(name: cellElements[k]));
          }
        }
      }
    }
    for (int i = 1; i < rowCount; i++) {
      for (int j in nameIndexes) {
        for (final att in tableToAtt[i][j]) {
          if (att.name == null) {
            continue;
          }

          if (int.tryParse(att.name!) != null) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "${att.name} is not a valid name",
                att: Attribute(row: i, col: j),
              ),
            );
            return;
          }

          final match = RegExp(r' -(\w+)$').firstMatch(att.name!);
          if (att.name!.contains("_") ||
              att.name!.contains(":") ||
              att.name!.contains("|") ||
              (match != null && !["fst", "lst"].contains(match.group(1)))) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "${att.name} contains invalid characters (_ : | -)",
                att: Attribute(row: i, col: j),
              ),
            );
          }

          final parenMatch = RegExp(r'(\(\d+\))$').firstMatch(att.name!);
          if (parenMatch != null) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "${att.name} contains invalid parentheses",
                att: Attribute(row: i, col: j),
              ),
            );
          }

          if (["fst", "lst"].contains(att.name)) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "${att.name} is a reserved name",
                att: Attribute(row: i, col: j),
              ),
            );
          }

          if (names.containsKey(att.name)) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "name ${att.name} used two times",
                newChildren: [
                  NodeStruct(
                    att: Attribute(row: i, col: j),
                  ),
                  NodeStruct(
                    att: Attribute(
                      row: names[att.name]!.row,
                      col: names[att.name]!.col,
                    ),
                  ),
                ],
              ),
            );
          }
          names[att.name!] = Cell(row: i, col: j);
        }
      }
    }
    _getCategories();
  }
}
