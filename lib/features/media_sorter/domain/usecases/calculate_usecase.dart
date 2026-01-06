import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'dart:collection';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
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
  List<ColumnType> columnTypes = [];

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
  Map<Attribute, Map<int, List<int>>> attToRefFromAttColToCol = {};

  /// Maps attribute identifiers (row index or name)
  /// to a map of mentioners (row index) to the column index
  Map<Attribute, Map<int, List<int>>> attToRefFromDepColToCol = {};
  List<Map<InstrStruct, int>> instrTable = [];
  Map<int, HashSet<Attribute>> colToAtt = {};
  List<bool> isMedium = [];

  static const int maxInt = -1 >>> 1;
  static const patternDistance = SpreadsheetConstants.patternDistance;
  static const patternAreas = SpreadsheetConstants.patternAreas;
  static const all = SpreadsheetConstants.all;
  static const notUsedCst = SpreadsheetConstants.notUsedCst;
  static const List<int> added = [];

  int get rowCount => table.length;
  int get colCount => rowCount > 0 ? table[0].length : 0;

  CalculateUsecase(this.dataPackage, this.columnTypes)
    : result = AnalysisResult() {
    nodesUsecase = NodesUsecase(result);
  }
  
  ColumnType getColumnType(int col) {
    if (col >= colCount) return ColumnType.attributes;
    return columnTypes[col];
  }

  IsolateMessage getMessage(
    List<List<String>> table,
    List<ColumnType> columnTypes,
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
    result.categoriesRoot.newChildren = categoriesRoot.newChildren;
    result.distPairsRoot.newChildren = distPairsRoot.newChildren;

    result.tableToAtt = tableToAtt;
    result.names = names;
    result.attToCol = attToCol;
    result.nameIndexes = nameIndexes;

    result.pathIndexes = pathIndexes;
    result.attToRefFromAttColToCol = attToRefFromAttColToCol;
    result.attToRefFromDepColToCol = attToRefFromDepColToCol;
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

  List<List<Cell>> findPath(
    Map<Attribute, Map<int, List<int>>> graph,
    Attribute start,
    int end, {
    bool reverse = true,
  }) {
    Attribute att = start;
    List<List<Cell>> path = [];
    while (true) {
      if (graph[att]![end] != added) {
        List<Cell> cells = graph[att]![end]!
            .map((colId) => Cell(rowId: end, colId: colId))
            .toList();
        path.add(cells);
        return reverse ? path.reversed.toList() : path;
      }
      for (final rowId in graph[att]!.keys) {
        Attribute childAtt = Attribute.row(rowId);
        if (graph[childAtt]!.containsKey(end)) {
          List<Cell> cells = graph[att]![rowId]!
              .map((colId) => Cell(rowId: rowId, colId: colId))
              .toList();
          path.add(cells);
          att = childAtt;
          break;
        }
      }
    }
  }

  void dfsIterative(
    Map<Attribute, Map<int, List<int>>> graph,
    String warningMsgPrefix,
  ) {
    final visited = <Attribute>{};
    final completed = <Attribute>{};
    List<Attribute> path = [];

    final List<NodeStruct> redundantRef = [];
    for (final start in graph.keys) {
      if (visited.contains(start)) continue;
      final stack = [start];

      while (stack.isNotEmpty) {
        Attribute att = stack[stack.length - 1]; // peek
        if (path.isNotEmpty && path[path.length - 1] == att) {
          Map<int, List<int>> rowsToCol = graph[att] ?? {};

          for (final rowId in rowsToCol.keys.toList()) {
            Map<int, List<int>>? childRowsToCol = graph[Attribute.row(rowId)];
            if (childRowsToCol != null) {
              for (int childRowId in childRowsToCol.keys) {
                if (!rowsToCol.containsKey(childRowId)) {
                  rowsToCol[childRowId] = added;
                } else if (rowsToCol[childRowId] != added) {
                  var newPath = findPath(graph, Attribute.row(childRowId), rowId)
                    .map(
                      (k) => NodeStruct(
                        instruction: SpreadsheetConstants.cell,
                        cells: k,
                      ),
                    ).toList();
                  redundantRef.add(
                    NodeStruct(
                      instruction: SpreadsheetConstants.cell,
                      message:
                          "$warningMsgPrefix \"$childRowId\" already pointed",
                      cells: rowsToCol[childRowId]!
                          .map((colId) => Cell(rowId: childRowId, colId: colId))
                          .toList(),
                      newChildren: newPath,
                    ),
                  );
                }
              }
            }
          }

          completed.add(att);
          path.removeLast();
          stack.removeLast();
          continue;
        }

        if (visited.contains(att)) {
          stack.removeLast(); // already processed
          continue;
        }

        visited.add(att);
        path.add(att);

        final neighborsMap = graph[att] ?? {};
        final neighbors = neighborsMap.keys.toList();

        for (int i = neighbors.length - 1; i >= 0; i--) {
          int child = neighbors[i];
          Attribute childAtt = Attribute.row(child);
          if (!visited.contains(childAtt)) {
            stack.add(childAtt);
          } else if (!completed.contains(childAtt)) {
            final cycle = path.sublist(path.indexOf(childAtt));
            final cyclePathNodes = cycle
                .map(
                  (k) => NodeStruct(
                    instruction: SpreadsheetConstants.row,
                    att: k,
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
          start ??= maxInt;

          var end = int.tryParse(endStr);
          end ??= maxInt;

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
            endOfCurrent = -maxInt;
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
            startOfNext = maxInt;
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
            cell: Cell(rowId: rowId, colId: colId),
          ),
        );
        return att;
      }
    } else if (splitStr.length > 2) {
      errorRoot.newChildren!.add(
        NodeStruct(
          message: "Invalid attribute format: too many '.' characters",
          cell: Cell(rowId: rowId, colId: colId),
        ),
      );
      return att;
    }
    var fromDep =
        columnTypes[colId] != ColumnType.attributes &&
        columnTypes[colId] != ColumnType.sprawl;
    int? numK = int.tryParse(name);
    numK ??= names[name]?.rowId;
    if (numK != null) {
      if (attColId != notUsedCst) {
        errorRoot.newChildren!.add(
          NodeStruct(
            message:
                "Cannot use both column and row index for attribute reference",
            cell: Cell(rowId: rowId, colId: colId),
          ),
        );
        return att;
      }
      if (numK < 1 || numK > rowCount - 1) {
        warningRoot.newChildren!.add(
          NodeStruct(
            message: "$name points to an empty row $numK",
            cell: Cell(rowId: rowId, colId: colId),
          ),
        );
      }
      att = Attribute.row(numK);
    } else {
      // TODO: validate attribute name
      if (attColId != notUsedCst) {
        if (columnTypes[attColId] != ColumnType.attributes &&
            columnTypes[attColId] != ColumnType.sprawl) {
          errorRoot.newChildren!.add(
            NodeStruct(
              message:
                  "Column ${nodesUsecase.getColumnLabel(attColId)} is not an attribute column",
              cell: Cell(rowId: rowId, colId: colId),
            ),
          );
          return att;
        }
        if (fromDep) {
          att = Attribute(name: name, colId: attColId);
          if (!attToRefFromAttColToCol.containsKey(att)) {
            colToAtt[notUsedCst]!.add(att);
          }
        } else if (attColId != colId) {
          warningRoot.newChildren!.add(
            NodeStruct(
              message:
                  "Attribute column ${nodesUsecase.getColumnLabel(attColId)} differs from current column ${nodesUsecase.getColumnLabel(colId)}",
              cell: Cell(rowId: rowId, colId: colId),
            ),
          );
        }
      } else if (!fromDep) {
        attColId = colId;
      }
      att = Attribute(name: name, colId: attColId);
      colToAtt[attColId]!.add(att);
      if (!attToCol.containsKey(attWritten)) {
        attToCol[attWritten] = [];
      }
      if (attColId != all) {
        if (attToCol[attWritten]!.contains(attColId) == false) {
          attToCol[attWritten]!.add(attColId);
        }
      }
    }
    tableToAtt[rowId][colId].add(att);
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
      for (int colId = 0; colId < colCount; colId++) {
        if (columnTypes[colId] == ColumnType.filePath ||
            columnTypes[colId] == ColumnType.urls) {
          isMedium[rowId] = isMedium[rowId] || table[rowId][colId].isNotEmpty;
        }
      }
    }

    colToAtt = {};
    Map<Attribute, List<int>> attToDist = {};
    Cell? firstElement;
    Cell? lastElement;
    final Map<int, List<(Attribute, int)>> fstCat = {};
    final Map<int, List<(Attribute, int)>> lstCat = {};
    colToAtt[all] = HashSet<Attribute>();
    colToAtt[notUsedCst] = HashSet<Attribute>();
    for (int colId = 0; colId < colCount; colId++) {
      if (columnTypes[colId] == ColumnType.attributes ||
          columnTypes[colId] == ColumnType.sprawl) {
        colToAtt[colId] = HashSet<Attribute>();
      }
    }
    List<NodeStruct> children = [];
    attToRefFromAttColToCol = {};
    attToCol = {};
    for (int rowId = 1; rowId < rowCount; rowId++) {
      final row = table[rowId];
      for (int colId = 0; colId < colCount; colId++) {
        final isSprawl = columnTypes[colId] == ColumnType.sprawl;
        if (columnTypes[colId] == ColumnType.attributes || isSprawl) {
          if (row[colId].isEmpty) {
            continue;
          }
          final cellList = row[colId].split(";");
          for (String attWritten in cellList) {
            if (attWritten.isEmpty) {
              errorRoot.newChildren!.add(
                NodeStruct(
                  message: "empty attribute name",
                  cell: Cell(rowId: rowId, colId: colId),
                ),
              );
              return;
            }

            bool isFst = attWritten.endsWith("-appear_fst");
            bool isLst = attWritten.endsWith("-appear_lst");

            if (isFst) {
              attWritten = attWritten
                  .substring(0, attWritten.length - 4)
                  .trim();
            } else if (attWritten == "fst") {
              if (firstElement != null) {
                errorRoot.newChildren!.add(
                  NodeStruct(
                    message: "multiple 'fst' found",
                    newChildren: [
                      NodeStruct(cell: firstElement),
                      NodeStruct(
                        cell: Cell(rowId: rowId, colId: colId),
                      ),
                    ],
                  ),
                );
                return;
              }
              firstElement = Cell(rowId: rowId, colId: colId);
              continue;
            } else if (isLst) {
              attWritten = attWritten
                  .substring(0, attWritten.length - 4)
                  .trim();
            } else if (attWritten == "lst") {
              if (lastElement != null) {
                errorRoot.newChildren!.add(
                  NodeStruct(
                    message: "multiple 'lst' found",
                    newChildren: [
                      NodeStruct(cell: lastElement),
                      NodeStruct(
                        cell: Cell(rowId: rowId, colId: colId),
                      ),
                    ],
                  ),
                );
                return;
              }
              lastElement = Cell(rowId: rowId, colId: colId);
              continue;
            } else if (attWritten.contains("-appear_fst")) {
              errorRoot.newChildren!.add(
                NodeStruct(
                  message: "'-appear_fst' is not at the end of $attWritten",
                  cell: Cell(rowId: rowId, colId: colId),
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
              attToRefFromAttColToCol[att]![rowId] = [colId];
              if (isSprawl) {
                attToDist[att]!.add(rowId);
              }
            } else {
              if (children.isEmpty || children[children.length - 1].att != att || children[children.length - 1].newChildren![0].rowId != rowId) {
                children.add(
                  NodeStruct(
                    att: att,
                    newChildren: [],
                  ),
                );
              }
              children[children.length - 1].newChildren!.add(
                NodeStruct(rowId: rowId, colId: colId)
              );
            }

            if (isFst) {
              fstCat[rowId]!.add((att, colId));
            } else if (isLst) {
              lstCat[rowId]!.add((att, colId));
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

    dfsIterative(attToRefFromAttColToCol, "attribute");

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
      Attribute att = Attribute.row(i);
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
                        findPath(attToRefFromAttColToCol, Attribute.row(urlFrom[k]), k)
                            .map(
                              (x) => NodeStruct(
                                cells: x
                                    .map(
                                      (y) => Cell(rowId: y.rowId, colId: y.colId),
                                    )
                                    .toList(),
                              ),
                            )
                            .toList(),
                  ),
                  NodeStruct(
                    message: "path 2",
                    startOpen: true,
                    newChildren: findPath(attToRefFromAttColToCol, Attribute.row(i), k)
                        .map(
                          (x) => NodeStruct(
                            cells: x
                                .map(
                                  (y) => Cell(rowId: y.rowId, colId: y.colId),
                                )
                                .toList(),
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
    List<NodeStruct> onlyOneMediumDist = [];
    for (var col in [...List.generate(colCount, (index) => index + 1), all]) {
      if (!colToAtt.containsKey(col) || colToAtt[col]!.isEmpty) {
        continue;
      }
      var attrs = colToAtt[col]!;
      List<NodeStruct> catColChildren = [];
      List<NodeStruct> spColChildren = [];
      for (final attr in attrs) {
        catColChildren.add(NodeStruct(att: attr));

        if (!attToDist.containsKey(attr)) {
          continue;
        }
        var rowsList = attToDist[attr]!;
        if (rowsList.length == 1) {
          onlyOneMediumDist.add(
            NodeStruct(att: attr),
          );
          continue;
        }
        rowsList = rowsList..sort();
        final distPairs = List.filled(rowsList.length - 2, 0);
        int minDist = maxInt;
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
                  NodeStruct(att: Attribute.row(rowsList[idx])),
                  NodeStruct(att: Attribute.row(rowsList[idx + 1])),
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
                  col != all ? a.name!.compareTo(b.name!) : a.rowId! - b.rowId!,
            ),
        ),
      );
      distPairsRoot.newChildren!.add(
        NodeStruct(
          att: Attribute(colId: col),
          newChildren: spColChildren..sort((a, b) => a.minDist! - b.minDist!),
        ),
      );
    }
    if (onlyOneMediumDist.isNotEmpty) {
      warningRoot.newChildren!.add(
        NodeStruct(
          message:
              "Attributes with only one medium in sprawl columns found",
          newChildren: onlyOneMediumDist,
        ),
      );
    }

    instrTable = List.generate(rowCount, (_) => {});

    //TODO: att1 with "att2 -appear_fst" means the first medium with att2 is a att1
    //TODO: att1 with "att2 -fst" means all media with att1 come before other media with att2
    // for (final MapEntry(key: k, value: vList) in fstCat.entries) {
    //   if (isMedium[k]) {
    //     for (final v in vList) {
    //       var t = v.$1;
    //       while (fstCat.containsKey(t)) {
    //         t = fstCat[t.rowId]!.$1;
    //       }
    //       for (final i in attToRefFromAttColToCol[t]!.keys) {
    //         if (i != k) {
    //           instrTable[i][InstrStruct(
    //                 true,
    //                 false,
    //                 [newIndexes[k]],
    //                 [
    //                   [-maxInt, -1],
    //                 ],
    //               )] =
    //               v.$2;
    //         }
    //       }
    //     }
    //   }
    // }

    // for (final MapEntry(key: k, value: v) in lstCat.entries) {
    //   if (isMedium[k]) {
    //     var t = v.$1;
    //     while (lstCat.containsKey(t)) {
    //       t = lstCat[t.rowId]!.$1;
    //     }
    //     for (final i in attToRefFromAttColToCol[t]!.keys) {
    //       if (i != k) {
    //         instrTable[i][InstrStruct(
    //               true,
    //               false,
    //               [newIndexes[k]],
    //               [
    //                 [1, maxInt],
    //               ],
    //             )] =
    //             v.$2;
    //       }
    //     }
    //   }
    // }

    // if (firstElement != null) {
    //   Attribute att = Attribute.row(rowId: firstElement.rowId);
    //   if (attToRefFromAttColToCol.containsKey(att)) {
    //     if (attToRefFromAttColToCol[att]!.keys.length > 1 ||
    //         attToRefFromAttColToCol[att]!.keys.length == 1 &&
    //             isMedium[firstElement.rowId]) {
    //       children = attToRefFromAttColToCol[att]!.keys
    //           .map(
    //             (k) => NodeStruct(
    //               cell: Cell(
    //                 rowId: k,
    //                 colId: attToRefFromAttColToCol[att]![k]!,
    //               ),
    //             ),
    //           )
    //           .toList();
    //       children.add(NodeStruct(cell: firstElement));
    //       errorRoot.newChildren!.add(
    //         NodeStruct(message: "multiple 'fst' found", newChildren: children),
    //       );
    //       return;
    //     }
    //   }
    //   for (final i in validRowIndexes) {
    //     if (i != firstElement.rowId) {
    //       instrTable[i][InstrStruct(
    //             true,
    //             false,
    //             [newIndexes[firstElement.rowId]],
    //             [
    //               [-maxInt, -1],
    //             ],
    //           )] =
    //           firstElement.colId;
    //     }
    //   }
    // }

    // if (lastElement != null) {
    //   Attribute att = Attribute.row(rowId: lastElement.rowId);
    //   if (attToRefFromAttColToCol.containsKey(att)) {
    //     if (attToRefFromAttColToCol[att]!.keys.length > 1 ||
    //         attToRefFromAttColToCol[att]!.keys.length == 1 &&
    //             isMedium[lastElement.rowId]) {
    //       children = attToRefFromAttColToCol[att]!.keys
    //           .map(
    //             (k) => NodeStruct(
    //               cell: Cell(
    //                 rowId: k,
    //                 colId: attToRefFromAttColToCol[att]![k]!,
    //               ),
    //             ),
    //           )
    //           .toList();
    //       children.add(NodeStruct(cell: lastElement));
    //       errorRoot.newChildren!.add(
    //         NodeStruct(message: "multiple 'lst' found", newChildren: children),
    //       );
    //       return;
    //     }
    //   }
    //   for (final i in validRowIndexes) {
    //     if (i != lastElement.rowId) {
    //       instrTable[i][InstrStruct(
    //             true,
    //             false,
    //             [newIndexes[lastElement.rowId]],
    //             [
    //               [1, maxInt],
    //             ],
    //           )] =
    //           lastElement.colId;
    //     }
    //   }
    // }

    final depPattern = table[0].map((cell) => cell.split(".")).toList();

    final Map<int, Map<int, (Attribute, bool, RegExpMatch, List<List<int>>)>>
    depCache = {};
    for (int rowId = 1; rowId < rowCount; rowId++) {
      if (!isMedium[rowId] &&
          !(attToRefFromAttColToCol.containsKey(Attribute.row(rowId)))) {
        continue;
      }

      final row = table[rowId];
      for (int colId = 0; colId < row.length; colId++) {
        if (columnTypes[colId] == ColumnType.dependencies &&
            row[colId].isNotEmpty) {
          // TODO: OR and AND
          for(String instr in row[colId].split(";")) {
            if (instr.isEmpty) continue;
            final instrSplit = instr.split("_");
            if (instrSplit.length != depPattern[colId].length - 1 &&
                depPattern[colId].length > 1) {
              errorRoot.newChildren!.add(
                NodeStruct(
                  message:
                      "$instr does not match dependencies pattern ${depPattern[colId]}",
                  cell: Cell(rowId: rowId, colId: colId),
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
                    cell: Cell(rowId: rowId, colId: colId),
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
    }

    attToRefFromDepColToCol = {};
    for (var i = 0; i < rowCount; i++) {
      for (var j = 0; j < colCount; j++) {
        if (columnTypes[j] == ColumnType.dependencies) {
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
            colId: attToCol[att.name]![0],
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
          !(attToRefFromAttColToCol.containsKey(Attribute.row(rowId)))) {
        continue;
      }

      final row = table[rowId];
      for (int colId = 0; colId < row.length; colId++) {
        if (columnTypes[colId] == ColumnType.dependencies &&
            row[colId].isNotEmpty) {
          var att = depCache[rowId]![colId]!.$1;
          var isConstraint = depCache[rowId]![colId]!.$2;
          var match = depCache[rowId]![colId]!.$3;
          var intervals = depCache[rowId]![colId]!.$4;

          final numbers = [];
          if (att.rowId != null) {
            numbers.add(att.rowId);
          } else {
            for (int r in attToRefFromAttColToCol[att]?.keys ?? []) {
              if (isMedium[r]) {
                numbers.add(r);
              }
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
                cell: Cell(rowId: rowId, colId: colId),
              ),
            );
          } else {
            instrTable[rowId][instruction] = colId;
          }
        }
      }
    }

    for (Attribute att in attToRefFromAttColToCol.keys) {
      if (att.rowId == null) {
        continue;
      }
      for (final rowId in attToRefFromAttColToCol[att]!.keys) {
        for (InstrStruct instr in instrTable[att.rowId!].keys) {
          if (!instrTable[rowId].containsKey(instr)) {
            instrTable[rowId][instr] = -1;
          }
        }
      }
    }

    // // Detect cycles in instrTable
    // bool hasCycle(instrTable, visited, List<DynAndInt> stack, node, {bool after = true}) {
    //   stack.add(DynAndInt(node, id));
    //   visited.add(node);

    //   for (final neighbor in instrTable[node]) {
    //     if (
    //       neighbor.any ||
    //       !neighbor.isConstraint ||
    //       (after
    //         ? neighbor.intervals[0][0] != -maxInt ||
    //           neighbor.intervals[0][1] != -1
    //         : neighbor.intervals[neighbor.intervals.length - 1][0] != 1 ||
    //           neighbor.intervals[neighbor.intervals.length - 1][1] != maxInt)
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

    
    int n = validRowIndexes.length;
    final solver = RangeConstraintSolver(n);

    // for (int rowId = 0; rowId < validRowIndexes.length; rowId++) {
    //   for (final instr in instrTable[rowId].keys) {
    //     if (!instr.isConstraint) {
    //       continue;
    //     }
    //     for (final target in instr.numbers) {
    //       solver.addConstraint(
    //         newIndexes[rowId],
    //         target,
    //         (dist) {
    //           for (final interval in instr.intervals) {
    //             if (dist >= interval[0] && dist <= interval[1]) {
    //               return true;
    //             }
    //           }
    //           return false;
    //         },
    //       );
    //     }
    //   }
    // }

    // Example constraints:
    // 0 is 3 places before 2 (dist -3) or 5+ places after (dist 5+)
    solver.addConstraint(0, 2, (dist) => dist == -3 || dist >= 5);

    // 3 is just before 4 (-1), or anywhere after (> 0)
    solver.addConstraint(3, 4, (dist) => dist == -1 || dist > 0);

    final results = solver.solve(true);
    if (results.isEmpty) {
      errorRoot.newChildren!.add(
        NodeStruct(
          message: "No valid ordering found for media",
        ),
      );
      return;
    }

    // TODO: solve sorting pb
    return;
  }

  void _getEverything() {
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
      if (role == ColumnType.names) {
        nameIndexes.add(index);
      } else if (role == ColumnType.filePath) {
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
                cell: Cell(rowId: i, colId: j),
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
                cell: Cell(rowId: i, colId: j),
              ),
            );
          }

          final parenMatch = RegExp(r'(\(\d+\))$').firstMatch(att.name!);
          if (parenMatch != null) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "${att.name} contains invalid parentheses",
                cell: Cell(rowId: i, colId: j),
              ),
            );
          }

          if (["fst", "lst"].contains(att.name)) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "${att.name} is a reserved name",
                cell: Cell(rowId: i, colId: j),
              ),
            );
          }

          if (names.containsKey(att.name)) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "name ${att.name} used two times",
                newChildren: [
                  NodeStruct(
                    cell: Cell(rowId: i, colId: j),
                  ),
                  NodeStruct(
                    cell: Cell(
                      rowId: names[att.name]!.rowId,
                      colId: names[att.name]!.colId,
                    ),
                  ),
                ],
              ),
            );
          }
          names[att.name!] = Cell(rowId: i, colId: j);
        }
      }
    }
    _getCategories();
  }
}






typedef Condition = bool Function(int dist);

class Constraint {
  final int otherVal;
  final Condition condition;

  Constraint(this.otherVal, this.condition);
}

class RangeConstraintSolver {
  final int n;
  final Map<int, List<Constraint>> constraints = {};
  final List<int> pos;

  RangeConstraintSolver(this.n) : pos = List.filled(n, -1) {
    for (int i = 0; i < n; i++) {
      constraints[i] = [];
    }
  }

  /// Adds a constraint between value [a] and value [b].
  /// The condition is based on the distance: pos[a] - pos[b].
  void addConstraint(int a, int b, Condition condition) {
    // Add forward constraint
    constraints[a]?.add(Constraint(b, condition));

    // Add inverse constraint: if dist = pos_a - pos_b, 
    // then inverse dist' = pos_b - pos_a = -dist.
    constraints[b]?.add(Constraint(a, (int dist) => condition(-dist)));
  }

  bool _isSafe(int val, int depth) {
    final relevantConstraints = constraints[val] ?? [];
    for (var constraint in relevantConstraints) {
      int otherPos = pos[constraint.otherVal];
      
      // If the other value isn't placed yet, the constraint can't be violated.
      if (otherPos != -1) {
        int dist = depth - otherPos;
        if (!constraint.condition(dist)) {
          return false;
        }
      }
    }
    return true;
  }

  List<List<int>> solve(bool justOne) {
    List<List<int>> solutions = [];
    List<int> solution = List.filled(n, 0);
    List<bool> used = List.filled(n, false);
    List<int> nextCandidate = List.filled(n, 0);

    int depth = 0;
    while (depth >= 0) {
      bool placed = false;
      int startVal = nextCandidate[depth];

      for (int val = startVal; val < n; val++) {
        if (!used[val]) {
          if (_isSafe(val, depth)) {
            // Place value
            solution[depth] = val;
            pos[val] = depth;
            used[val] = true;

            nextCandidate[depth] = val + 1;
            depth++;

            if (depth < n) {
              nextCandidate[depth] = 0;
            }
            placed = true;
            break;
          }
        }
      }

      if (placed) {
        if (depth == n) {
          // Found a solution: create a copy of the current state
          solutions.add(List.from(solution));
          if (justOne) {
            break;
          }
          
          // Backtrack to find more solutions
          depth--;
          int valToRemove = solution[depth];
          used[valToRemove] = false;
          pos[valToRemove] = -1;
        }
      } else {
        // Backtrack
        nextCandidate[depth] = 0;
        depth--;
        if (depth >= 0) {
          int valToRemove = solution[depth];
          used[valToRemove] = false;
          pos[valToRemove] = -1;
        }
      }
    }

    return solutions;
  }
}
