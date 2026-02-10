import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/isolate_message.dart';
import 'dart:collection';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/instr_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';

class Cols {
  final List<int> colIndexes = [];
  final List<bool> toInformFstDep = [];
  Cols();

  factory Cols.fromJson(Map<String, dynamic> json) {
    final colIndexes = List<int>.from(json['colIndexes'] as List<dynamic>);
    final toInformFstDep = List<bool>.from(json['toInformFstDep'] as List<dynamic>);
    final cols = Cols();
    cols.colIndexes.addAll(colIndexes);
    cols.toInformFstDep.addAll(toInformFstDep);
    return cols;
  }

  Map<String, dynamic> toJson() {
    return {
      'colIndexes': colIndexes,
      'toInformFstDep': toInformFstDep,
    };
  }
}

class CalculateUsecase {
  final Either<TransferableTypedData, List<List<String>>> dataPackage;
  final AnalysisResult result = AnalysisResult.empty();

  SheetContent? _sheetContent;
  List<List<String>> get table => _sheetContent!.table;
  List<ColumnType> get columnTypes => _sheetContent!.columnTypes;

  NodeStruct get errorRoot => result.errorRoot;
  NodeStruct get warningRoot => result.warningRoot;
  NodeStruct get categoriesRoot => result.categoriesRoot;
  NodeStruct get distPairsRoot => result.distPairsRoot;
  List<List<HashSet<Attribute>>> get tableToAtt => result.tableToAtt;

  Map<String, Cell> get names => result.names;
  Map<String, List<int>> get attToCol => result.attToCol;
  List<int> get nameIndexes => result.nameIndexes;
  List<int> get pathIndexes => result.pathIndexes;
  List<int> get validRowIndexes => result.validRowIndexes;
  List<List<StrInt>> get formatedTable => result.formatedTable;

  /// Maps attribute identifiers (row index or name)
  /// to a map of pointers (row index) to the column index,
  /// in this direction so it is easy to diffuse characteristics to pointers.
  Map<Attribute, Map<int, Cols>> get attToRefFromAttColToCol =>
      result.attToRefFromAttColToCol;
  Map<Attribute, Map<int, List<int>>> get attToRefFromDepColToCol =>
      result.attToRefFromDepColToCol;
  List<HashSet<int>> get rowToRefFromAttCol => result.rowToRefFromAttCol;

  List<Map<InstrStruct, Cell>> get instrTable => result.instrTable;
  set instrTable(List<Map<InstrStruct, Cell>> value) {
    result.instrTable = value;
  }

  Map<int, HashSet<Attribute>> get colToAtt => result.colToAtt;
  List<bool> get isMedium => result.isMedium;

  static const int maxInt = -1 >>> 1;
  static const patternDistance = SpreadsheetConstants.patternDistance;
  static const patternAreas = SpreadsheetConstants.patternAreas;
  static const all = SpreadsheetConstants.all;
  static const notUsedCst = SpreadsheetConstants.notUsedCst;
  static Cols added = Cols();

  int get rowCount => _sheetContent!.table.length;
  int get colCount => rowCount > 0 ? _sheetContent!.table[0].length : 0;

  final List<ColumnType> columnTypes0;

  CalculateUsecase(IsolateMessage message)
    : dataPackage = message.table,
      columnTypes0 = message.columnTypes;

  AnalysisResult run() {
    _decodeData(dataPackage);
    _getEverything();
    getRules(result);
    return result;
  }

  void _decodeData(
    Either<TransferableTypedData, List<List<String>>> dataPackage,
  ) {
    List<List<String>> table = [];
    dataPackage.fold(
      (transferable) {
        final Uint8List receivedBytes = transferable
            .materialize()
            .asUint8List();
        final List<dynamic> decodedTable = jsonDecode(
          utf8.decode(receivedBytes),
        );
        table = decodedTable
            .map((row) => (row as List).cast<String>())
            .toList();
      },
      (rawTable) {
        table = rawTable;
      },
    );
    _sheetContent = SheetContent(table: table, columnTypes: columnTypes0);
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
        return -1;
      }

      // 'a' (97) becomes 0, 'b' (98) becomes 1, etc.
      int value = codeUnit - 97;
      result = result * 26 + value;
    }
    return result;
  }

  List<List<Cell>> findPath(
    Map<Attribute, Map<int, Cols>> graph,
    Attribute start,
    int end, {
    bool reverse = true,
  }) {
    Attribute att = start;
    List<List<Cell>> path = [];
    while (true) {
      if (graph[att]![end] != added && att != start) {
        List<Cell> cells = graph[att]![end]!.colIndexes
            .map((colId) => Cell(rowId: end, colId: colId))
            .toList();
        path.add(cells);
        return reverse ? path.reversed.toList() : path;
      }
      for (final rowId in graph[att]!.keys) {
        Attribute childAtt = Attribute.row(rowId);
        if (graph.containsKey(childAtt) && graph[childAtt]!.containsKey(end)) {
          List<Cell> cells = graph[att]![rowId]!.colIndexes
              .map((colId) => Cell(rowId: rowId, colId: colId))
              .toList();
          path.add(cells);
          att = childAtt;
          break;
        }
      }
    }
  }

  void dfsIterative(Map<Attribute, Map<int, Cols>> graph) {
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
          Map<int, Cols> rowsToCol = graph[att] ?? {};

          for (final rowId in rowsToCol.keys.toList()) {
            Map<int, Cols>? childRowsToCol = graph[Attribute.row(rowId)];
            if (childRowsToCol != null) {
              for (int childRowId in childRowsToCol.keys) {
                if (!rowsToCol.containsKey(childRowId)) {
                  rowsToCol[childRowId] = added;
                } else if (rowsToCol[childRowId] != added &&
                    rowsToCol[childRowId]!.toInformFstDep.contains(false)) {
                  List<NodeStruct> newPath = findPath(
                    graph,
                    att,
                    childRowId,
                  ).map((k) => NodeStruct(cells: k)).toList();
                  for (int nodeId = 0; nodeId < newPath.length; nodeId++) {
                    newPath[nodeId].message =
                        "${GetNames.getAttName(result.nameIndexes, result.tableToAtt, newPath[nodeId].att!)} points to row ${GetNames.getAttName(result.nameIndexes, result.tableToAtt, nodeId < newPath.length - 1 ? newPath[nodeId + 1].att! : att)}";
                  }
                  redundantRef.add(
                    NodeStruct(
                      message:
                          "${GetNames.getAttName(result.nameIndexes, result.tableToAtt, att)} already pointed",
                      cells: rowsToCol[childRowId]!.colIndexes
                          .where(
                            (colId) =>
                                !rowsToCol[childRowId]!.toInformFstDep[colId],
                          )
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
                  (k) =>
                      NodeStruct(instruction: SpreadsheetConstants.row, att: k),
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
    List<List<int>> intervals = [];
    List<String> negPos = intervalStr.split("|");
    int? start;
    int? end;

    for (final (positive, negPosPart) in [negPos[0], negPos[2]].indexed) {
      var parts = negPosPart.split("-");
      for (final (index, part) in parts.indexed) {
        if (part.isNotEmpty) {
          List<String> splitPart = part.split("_");
          if (splitPart.length != 2) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "Invalid interval format: missing '_' in \"$part\"",
                rowId: row,
                colId: col,
              ),
            );
            return [];
          }
          var [startStr, endStr] = splitPart;
          start = int.tryParse(startStr);
          end = int.tryParse(endStr);
          if (start == null) {
            if (positive == 0 && index == 0) {
              start = maxInt;
            } else if (positive == 1 && index == 0) {
              start = 1;
            } else {
              errorRoot.newChildren!.add(
                NodeStruct(
                  message: "Invalid interval start: $startStr",
                  rowId: row,
                  colId: col,
                ),
              );
              return [];
            }
          }
          if (end == null) {
            if (positive == 0 && index == parts.length - 1) {
              end = 1;
            } else if (positive == 1 && index == parts.length - 1) {
              end = maxInt;
            } else {
              errorRoot.newChildren!.add(
                NodeStruct(
                  message: "Invalid interval end: $endStr",
                  rowId: row,
                  colId: col,
                ),
              );
              return [];
            }
          }
          if (positive == 0) {
            intervals.add([-end, -start]);
          } else {
            intervals.add([start, end]);
          }
        }
      }
    }
    return intervals;
  }

  bool isValidAttName(String attName) {
    if (attName.contains(SpreadsheetConstants.appearFirst) ||
        attName.contains(SpreadsheetConstants.appearLast) ||
        attName.contains(SpreadsheetConstants.first) ||
        attName.contains(SpreadsheetConstants.last) ||
        attName.trim().isEmpty) {
      return false;
    }
    return true;
  }

  Attribute getAttAndCol(String attWritten, int rowId, int colId) {
    Attribute att = Attribute();
    List<String> splitStr = attWritten.split(".");
    String name = attWritten;
    int attColId = notUsedCst;
    int startStrRowId = 0;
    if (splitStr.length == 2) {
      name = splitStr[1];
      startStrRowId += splitStr[0].length;
      attColId = table[0].indexOf(splitStr[0]);
      if (attColId == -1) {
        attColId = getIndexFromString(splitStr[0]);
      }
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
    int? intNameSaved = numK;
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
      if (intNameSaved != null) {
        formatedTable[rowId][colId].strings.last += attWritten.substring(
          0,
          startStrRowId,
        );
        formatedTable[rowId][colId].integers.add(numK);
        formatedTable[rowId][colId].strings.add(
          attWritten.substring(startStrRowId + name.length),
        );
      } else {
        formatedTable[rowId][colId].strings.last += attWritten;
      }
      att = Attribute.row(numK);
      attColId = all;
    } else {
      if (!isValidAttName(name)) {
        errorRoot.newChildren!.add(
          NodeStruct(
            message: "Invalid attribute name: \"$name\"",
            rowId: rowId,
            colId: colId,
          ),
        );
        return att;
      }
      if (attColId != notUsedCst) {
        if (columnTypes[attColId] != ColumnType.attributes &&
            columnTypes[attColId] != ColumnType.sprawl) {
          errorRoot.newChildren!.add(
            NodeStruct(
              message:
                  "Column ${GetNames.getColumnLabel(attColId)} is not an attribute column",
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
                  "Attribute column ${GetNames.getColumnLabel(attColId)} differs from current column ${GetNames.getColumnLabel(colId)}",
              cell: Cell(rowId: rowId, colId: colId),
            ),
          );
        }
      } else if (!fromDep) {
        attColId = colId;
      }
      att = Attribute(name: name, colId: attColId);
      if (!attToCol.containsKey(attWritten)) {
        attToCol[attWritten] = [];
      }
      if (attColId != all) {
        if (attToCol[attWritten]!.contains(attColId) == false) {
          attToCol[attWritten]!.add(attColId);
        }
      }
    }
    colToAtt[attColId]!.add(att);
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

    isMedium..clear()..addAll(List<bool>.filled(rowCount, false));
    for (int rowId = 1; rowId < rowCount; rowId++) {
      for (int colId = 0; colId < colCount; colId++) {
        if (GetNames.isSourceColumn(columnTypes[colId])) {
          isMedium[rowId] = isMedium[rowId] || table[rowId][colId].isNotEmpty;
        }
      }
    }

    colToAtt.clear();
    Map<Attribute, List<int>> attToDist = {};
    final Map<int, Map<Attribute, Cell>> isFstToAppear = {};
    final Map<int, Map<Attribute, Cell>> isLstToAppear = {};
    final Map<int, Map<Attribute, Cell>> beforeAllOthers = {};
    final Map<int, Map<Attribute, Cell>> afterAllOthers = {};
    colToAtt[all] = HashSet<Attribute>();
    colToAtt[notUsedCst] = HashSet<Attribute>();
    for (int colId = 0; colId < colCount; colId++) {
      if (columnTypes[colId] == ColumnType.attributes ||
          columnTypes[colId] == ColumnType.sprawl) {
        colToAtt[colId] = HashSet<Attribute>();
      }
    }
    List<NodeStruct> children = [];
    attToRefFromAttColToCol.clear();
    attToCol.clear();
    rowToRefFromAttCol
      ..clear()
      ..addAll(List.generate(rowCount, (i) => HashSet<int>()));
    formatedTable
      ..clear()
      ..addAll(
        List.generate(
          rowCount,
          (i) => List.generate(colCount, (j) => StrInt()),
        ),
      );
    for (int colId = 0; colId < colCount; colId++) {
      int index = getIndexFromString(table[0][colId]);
      if (index > 0 && index < colCount) {
        errorRoot.newChildren!.add(
          NodeStruct(
            message:
                "Column header ${GetNames.getColumnLabel(colId)} \"${table[0][colId]}\" conflicts with Column header ${GetNames.getColumnLabel(index)} \"${table[0][index]}\"",
            cell: Cell(rowId: 0, colId: colId),
          ),
        );
        return;
      }
    }
    for (int rowId = 1; rowId < rowCount; rowId++) {
      final row = table[rowId];
      for (int colId = 0; colId < colCount; colId++) {
        final isSprawl = columnTypes[colId] == ColumnType.sprawl;
        if (columnTypes[colId] == ColumnType.attributes || isSprawl) {
          if (row[colId].isEmpty) {
            continue;
          }
          final cellList = row[colId].split(";");
          for (String attWrittenNotTrimed in cellList) {
            String attWritten = attWrittenNotTrimed.trim();
            if (attWritten.isEmpty) {
              errorRoot.newChildren!.add(
                NodeStruct(
                  message: "empty attribute name",
                  cell: Cell(rowId: rowId, colId: colId),
                ),
              );
              return;
            }

            bool isAppearFst = attWritten.endsWith(
              SpreadsheetConstants.appearFirst,
            );
            bool isAppearLst = attWritten.endsWith(
              SpreadsheetConstants.appearLast,
            );
            bool isFst = attWritten.endsWith(SpreadsheetConstants.first);
            bool isLst = attWritten.endsWith(SpreadsheetConstants.last);
            Cell cell = Cell(rowId: rowId, colId: colId);
            if (isAppearFst || isAppearLst) {
              attWritten = attWritten
                  .substring(0, attWritten.length - 11)
                  .trim();
            } else if (isFst || isLst) {
              attWritten = attWritten
                  .substring(0, attWritten.length - 4)
                  .trim();
            } else if (attWritten == "fst") {
              beforeAllOthers[rowId] ??= {};
              beforeAllOthers[rowId]![Attribute.row(all)] = cell;
              continue;
            } else if (attWritten == "lst") {
              afterAllOthers[rowId] ??= {};
              afterAllOthers[rowId]![Attribute.row(all)] = cell;
              continue;
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
              attToRefFromAttColToCol[att]![rowId] = Cols();
              if (att.isRow()) {
                rowToRefFromAttCol[rowId].add(att.rowId!);
              }
              if (isSprawl) {
                attToDist[att]!.add(rowId);
              }
            } else {
              if (children.isEmpty ||
                  children[children.length - 1].att != att ||
                  children[children.length - 1].newChildren![0].rowId !=
                      rowId) {
                children.add(NodeStruct(att: att, newChildren: []));
              }
              children[children.length - 1].newChildren!.add(
                NodeStruct(rowId: rowId, colId: colId),
              );
            }
            attToRefFromAttColToCol[att]![rowId]!.colIndexes.add(colId);
            if (isAppearFst) {
              isFstToAppear[rowId] ??= {};
              isFstToAppear[rowId]![att] = cell;
            } else if (isAppearLst) {
              isLstToAppear[rowId] ??= {};
              isLstToAppear[rowId]![att] = cell;
            } else if (isFst) {
              beforeAllOthers[rowId] ??= {};
              beforeAllOthers[rowId]![att] = cell;
            } else if (isLst) {
              afterAllOthers[rowId] ??= {};
              afterAllOthers[rowId]![att] = cell;
            }
            attToRefFromAttColToCol[att]![rowId]!.toInformFstDep.add(
              isAppearFst || isAppearLst || isFst || isLst,
            );
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

    dfsIterative(attToRefFromAttColToCol);

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
                        findPath(
                              attToRefFromAttColToCol,
                              Attribute.row(urlFrom[k]),
                              k,
                            )
                            .map(
                              (x) => NodeStruct(
                                cells: x
                                    .map(
                                      (y) =>
                                          Cell(rowId: y.rowId, colId: y.colId),
                                    )
                                    .toList(),
                              ),
                            )
                            .toList(),
                  ),
                  NodeStruct(
                    message: "path 2",
                    startOpen: true,
                    newChildren:
                        findPath(attToRefFromAttColToCol, Attribute.row(i), k)
                            .map(
                              (x) => NodeStruct(
                                cells: x
                                    .map(
                                      (y) =>
                                          Cell(rowId: y.rowId, colId: y.colId),
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

    validRowIndexes.clear();
    final newIndexes = List.generate(rowCount, (i) => i);
    final catRows = [];
    int newIndex = 0;
    final List<int> newIndexList = [];
    for (int i = 1; i < rowCount; i++) {
      if (isMedium[i]) {
        validRowIndexes.add(i);
        newIndexes[i] = newIndex;
        newIndexList.add(newIndex);
        newIndex++;
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
          onlyOneMediumDist.add(NodeStruct(att: attr));
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
                    "($d) ${GetNames.getRowName(result.nameIndexes, result.tableToAtt, rowsList[idx])} - ${GetNames.getRowName(result.nameIndexes, result.tableToAtt, rowsList[idx + 1])}",
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
          message: "Attributes with only one medium in sprawl columns found",
          newChildren: onlyOneMediumDist,
        ),
      );
    }

    instrTable
      ..clear()
      ..addAll(List.generate(rowCount, (_) => {}));

    List<Attribute> stack = [];
    for (final MapEntry(key: k, value: vMap) in isFstToAppear.entries) {
      for (Attribute a in isFstToAppear[k]?.keys ?? []) {
        if (a.rowId == all && isFstToAppear[k]!.keys.length > 1) {
          warningRoot.newChildren!.add(
            NodeStruct(
              message:
                  "useless '${SpreadsheetConstants.appearFirst}' since it is first to all others",
              cell: isFstToAppear[k]![a]!,
            ),
          );
        }
      }
      if (isMedium[k]) {
        for (Attribute a in isFstToAppear[k]?.keys ?? []) {
          stack.add(a);
        }
        while (stack.isNotEmpty) {
          Attribute currAtt = stack.removeLast();
          if (isFstToAppear[currAtt.rowId]?.keys != null) {
            for (Attribute a in isFstToAppear[currAtt.rowId]?.keys ?? []) {
              stack.add(a);
            }
          } else if (currAtt.rowId == all) {
            instrTable[k][InstrStruct(
              true,
              false,
              newIndexList.where((entry) => entry != newIndexes[k]).toList(),
              [
                [-maxInt, -1],
              ],
            )] = vMap
                .values
                .first;
          } else {
            instrTable[k][InstrStruct(
                  true,
                  false,
                  attToRefFromAttColToCol[currAtt]!.keys
                      .where((key) => isMedium[key] && key != k)
                      .map((entry) => newIndexes[entry])
                      .toList(),
                  [
                    [-maxInt, -1],
                  ],
                )] =
                vMap.values.first;
          }
        }
      }
    }
    stack = [];
    for (final MapEntry(key: k, value: vMap) in isLstToAppear.entries) {
      for (Attribute a in isLstToAppear[k]?.keys ?? []) {
        if (a.rowId == all && isLstToAppear[k]!.keys.length > 1) {
          warningRoot.newChildren!.add(
            NodeStruct(
              message:
                  "useless '${SpreadsheetConstants.appearLast}' since it is last to all others",
              cell: isLstToAppear[k]![a]!,
            ),
          );
        }
      }
      if (isMedium[k]) {
        for (Attribute a in isLstToAppear[k]?.keys ?? []) {
          stack.add(a);
        }
        while (stack.isNotEmpty) {
          Attribute currAtt = stack.removeLast();
          if (isLstToAppear[currAtt.rowId]?.keys != null) {
            for (Attribute a in isLstToAppear[currAtt.rowId]?.keys ?? []) {
              stack.add(a);
            }
          } else if (currAtt.rowId == all) {
            instrTable[k][InstrStruct(
              true,
              false,
              newIndexList.where((entry) => entry != newIndexes[k]).toList(),
              [
                [1, maxInt],
              ],
            )] = vMap
                .values
                .first;
          } else {
            instrTable[k][InstrStruct(
                  true,
                  false,
                  attToRefFromAttColToCol[currAtt]!.keys
                      .where((key) => isMedium[key] && key != k)
                      .map((entry) => newIndexes[entry])
                      .toList(),
                  [
                    [1, maxInt],
                  ],
                )] =
                vMap.values.first;
          }
        }
      }
    }
    for (final MapEntry(key: k, value: vMap) in beforeAllOthers.entries) {
      for (Attribute a in beforeAllOthers[k]?.keys ?? []) {
        if (a.rowId == all && beforeAllOthers[k]!.keys.length > 1) {
          warningRoot.newChildren!.add(
            NodeStruct(
              message:
                  "useless '${SpreadsheetConstants.first}' since it is before all others",
              cell: beforeAllOthers[k]![a]!,
            ),
          );
        }
      }
      if (isMedium[k]) {
        for (Attribute a in beforeAllOthers[k]?.keys ?? []) {
          if (a.rowId == all) {
            instrTable[k][InstrStruct(
              true,
              false,
              newIndexList.where((entry) => entry != newIndexes[k]).toList(),
              [
                [-maxInt, -1],
              ],
            )] = vMap
                .values
                .first;
          } else {
            instrTable[k][InstrStruct(
                  true,
                  false,
                  attToRefFromAttColToCol[a]!.keys
                      .where((key) => isMedium[key] && key != k)
                      .map((entry) => newIndexes[entry])
                      .toList(),
                  [
                    [-maxInt, -1],
                  ],
                )] =
                vMap.values.first;
          }
        }
      }
    }
    for (final MapEntry(key: k, value: vMap) in afterAllOthers.entries) {
      for (Attribute a in afterAllOthers[k]?.keys ?? []) {
        if (a.rowId == all && afterAllOthers[k]!.keys.length > 1) {
          warningRoot.newChildren!.add(
            NodeStruct(
              message:
                  "useless '${SpreadsheetConstants.last}' since it is after all others",
              cell: afterAllOthers[k]![a]!,
            ),
          );
        }
      }
      if (isMedium[k]) {
        for (Attribute a in afterAllOthers[k]?.keys ?? []) {
          if (a.rowId == all) {
            instrTable[k][InstrStruct(
              true,
              false,
              newIndexList.where((entry) => entry != newIndexes[k]).toList(),
              [
                [1, maxInt],
              ],
            )] = vMap
                .values
                .first;
          } else {
            instrTable[k][InstrStruct(
                  true,
                  false,
                  attToRefFromAttColToCol[a]!.keys
                      .where((key) => isMedium[key] && key != k)
                      .map((entry) => newIndexes[entry])
                      .toList(),
                  [
                    [1, maxInt],
                  ],
                )] =
                vMap.values.first;
          }
        }
      }
    }

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

    final depPattern = table[0].map((cell) => cell.split("#")).toList();

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
          bool firstInstr = true;
          for (String instr in row[colId].split(";")) {
            instr = instr.trim();
            if (instr.isEmpty) continue;
            final instrSplit = instr.split("#");
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
            List<int> separations = [];
            if (depPattern[colId].length > 1) {
              instr = depPattern[colId][0];
              separations.add(instr.length);
              for (int i = 1; i < depPattern[colId].length; i++) {
                instr += instrSplit[i - 1] + depPattern[colId][i];
                separations.add(separations.last + instrSplit[i - 1].length);
                separations.add(separations.last + depPattern[colId][i].length);
              }
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
            formatedTable[rowId][colId].strings.last +=
                (firstInstr ? "" : "; ") +
                (match.group(1) ?? "") +
                (match.group(2) ?? "");
            firstInstr = false;
            Attribute att = getAttAndCol(
              match.namedGroup('att')!,
              rowId,
              colId,
            );
            if (errorRoot.newChildren!.isNotEmpty) {
              return;
            }
            formatedTable[rowId][colId].strings.last += match.group(4) ?? "";
            int nameLength = match.namedGroup('att')!.length;
            if (separations.isNotEmpty) {
              int lastStrLen = formatedTable[rowId][colId].strings.last.length;
              int startAttPos = instr.length - lastStrLen - nameLength;
              if (lastStrLen < instr.length) {
                int separationId = separations.indexWhere(
                  (e) => e > startAttPos,
                );
                int separation = separations[separationId];
                if (separationId % 2 == 0 ||
                    separation - startAttPos < nameLength) {
                  errorRoot.newChildren!.add(
                    NodeStruct(
                      message: "Attribute reference overlaps with header",
                      cell: Cell(rowId: rowId, colId: colId),
                    ),
                  );
                  return;
                }
              }
              int strId = formatedTable[rowId][colId].strings.length - 1;
              int startStrIdInSplit = lastStrLen - instr.length;
              if (lastStrLen < instr.length) {
                startStrIdInSplit =
                    formatedTable[rowId][colId].strings[strId].length -
                    startAttPos;
                strId--;
              } else {
                startAttPos = maxInt;
              }
              int correctId = 0;
              if (separations[0] != 0) {
                formatedTable[rowId][colId].strings[strId].replaceRange(
                  startStrIdInSplit,
                  startStrIdInSplit + separations[0],
                  "#",
                );
                correctId = separations[0] - 1;
              }
              int strIdNext = strId + 1;
              for (int i = 2; i < separations.length; i += 2) {
                if (separations[i] > startAttPos) {
                  strId = strIdNext;
                  startStrIdInSplit = 0;
                }
                formatedTable[rowId][colId].strings[strId].replaceRange(
                  startStrIdInSplit + separations[i - 1] - correctId,
                  startStrIdInSplit + separations[i] - correctId,
                  "#",
                );
                correctId += separations[i] - separations[i - 1] - 1;
              }
            }
            depCache[rowId] ??= {};
            depCache[rowId]![colId] = (att, isConstraint, match, intervals);
          }
        }
      }
    }

    attToRefFromDepColToCol.clear();
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
          if (att.rowId != null && isMedium[att.rowId!]) {
            numbers.add(att.rowId);
          }
          for (int r in attToRefFromAttColToCol[att]?.keys ?? []) {
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
            warningRoot.newChildren!.add(
              NodeStruct(
                message: "duplicate instruction",
                newChildren: [
                  NodeStruct(cell: instrTable[rowId][instruction]),
                  NodeStruct(
                    cell: Cell(rowId: rowId, colId: colId),
                  ),
                ],
              ),
            );
          } else {
            instrTable[rowId][instruction] = Cell(rowId: rowId, colId: colId);
          }
        }
      }
    }

    // for (Attribute att in attToRefFromAttColToCol.keys) {
    //   if (att.rowId == null) {
    //     continue;
    //   }
    //   for (final rowId in attToRefFromAttColToCol[att]!.keys) {
    //     for (InstrStruct instr in instrTable[att.rowId!].keys) {
    //       if (!instrTable[rowId].containsKey(instr)) {
    //         instrTable[rowId][instr] = Cell(rowId: all, colId: all);
    //       }
    //     }
    //   }
    // }

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

    // final testData = TestGenerator.generateTestCaseRelative(nVal);
    // final Map<int, List<Rule>> myRules = testData['rules'];

    // // Manual Override Example
    // myRules[0] = [Rule(0, 1), Rule(-2, -2, relativeTo: 5)];
    // myRules[1] = [Rule(0, 1), Rule(-2, -2, relativeTo: 5)];

    // debugPrint("Solving for N=$nVal with Pure Dart Solver...");

    // final stopwatch = Stopwatch()..start();
    // final result = ConstrainedSortSolver.solve(nVal, myRules);
    // stopwatch.stop();

    // if (result != null) {
    //   debugPrint("Valid result found in ${stopwatch.elapsedMilliseconds}ms.");
    //   debugPrint("Result: $result");
    // } else {
    //   debugPrint("No valid sorting exists.");
    // }

    // // Example constraints:
    // // 0 is 3 places before 2 (-3), or 5+ places after (5 to maxInt)
    // // Replaces: (dist) => dist == -3 || dist >= 5
    // solver.addConstraint(0, 2, [
    //   [-3, -3],
    //   [5, maxInt]
    // ]);

    // // 3 is immediately before 4 (-1), or anywhere after (> 0)
    // // Replaces: (dist) => dist == -1 || dist > 0
    // solver.addConstraint(3, 4, [
    //   [-1, -1],
    //   [1, maxInt]
    // ]);
    instrTable = instrTable
        .asMap()
        .entries
        .where((entry) => isMedium[entry.key])
        .map((entry) => entry.value)
        .toList();
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
    nameIndexes.clear();
    pathIndexes.clear();
    for (int index = 0; index < colCount; index++) {
      final role = GetNames.getColumnType(_sheetContent!, index);
      if (role == ColumnType.names) {
        nameIndexes.add(index);
      } else if (role == ColumnType.filePath) {
        pathIndexes.add(index);
      }
    }
    tableToAtt
      ..clear()
      ..addAll(
        List.generate(
          rowCount,
          (_) => List.generate(colCount, (_) => HashSet<Attribute>()),
        ),
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
  
  void getRules(AnalysisResult result) {
    int nVal = result.instrTable.length;
    result.myRules = {};
    for (int rowId = 0; rowId < nVal; rowId++) {
      result.myRules[rowId] = [];
      for (final instr in result.instrTable[rowId].keys) {
        if (!instr.isConstraint) {
          continue;
        }
        for (int target in instr.numbers) {
          for (final interval in instr.intervals) {
            int minVal = interval[0];
            int maxVal = interval[1];
            result.myRules[rowId]!.add(
              SortingRule(
                minVal: minVal,
                maxVal: maxVal,
                relativeTo: target,
              ),
            );
          }
        }
      }
    }
  }

}
