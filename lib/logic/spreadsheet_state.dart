import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'dart:math';
import 'dart:convert';
import '../data/models/cell.dart';
import '../data/models/node_struct.dart';
import '../data/models/column_type.dart';
import '../logger.dart';
import '../logic/async_utils.dart';
import '../logic/hungarian_algorithm.dart';
import '../data/models/dyn_and_int.dart';


class InstrStruct {
  bool isConstraint;
  bool any;
  List<int> numbers;
  List<List<int>> intervals;

  static const _equality = DeepCollectionEquality();

  InstrStruct(
    this.isConstraint,
    this.any,
    this.numbers,
    this.intervals
  );
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is InstrStruct &&
        isConstraint == other.isConstraint &&
        any == other.any &&
        // 2. Use .equals to compare the contents of the lists
        _equality.equals(other.numbers, numbers) &&
        _equality.equals(other.intervals, intervals);
  }

  @override
  int get hashCode => Object.hash(
        isConstraint,
        any,
        // 3. Use .hash separately for the lists
        _equality.hash(numbers),
        _equality.hash(intervals),
      );
}

class SpreadsheetState extends ChangeNotifier {
  static const PATTERN_DISTANCE =
    r'^(?<prefix>as far as possible from )(?<any>any)?(?<att>.+)$/';
  static const PATTERN_AREAS =
    r'^(?<prefix>.*\|)(?<any>any)?(?<att>.+)(?<suffix>\|.*)$/';
  static const rowCst = "rows";
  static const notUsedCst = "notUsed";
  String spreadsheetName = "";
  final NodeStruct errorRoot = NodeStruct(message: 'Error Log', newChildren: [], hideIfEmpty: true);
  final NodeStruct warningRoot = NodeStruct(message: 'Warning Log', newChildren: [], hideIfEmpty: true);
  final NodeStruct mentionsRoot = NodeStruct(message: 'Current selection', newChildren: []);
  final NodeStruct searchRoot = NodeStruct(message: 'Search results', newChildren: []);
  final NodeStruct categoriesRoot = NodeStruct(message: 'Categories', newChildren: []);
  final NodeStruct distPairsRoot = NodeStruct(message: 'Distance Pairs', newChildren: []);
  late List<List<String>> table = [];
  List<String> columnTypes = [];

  /// 2D table of attribute identifiers (row index or name)
  /// mentioned in each cell.
  List<List<List<AttAndCol>>> mentions = [];
  Map<String, Cell> names = {};
  Map<String, List<dynamic>> attToCol = {};
  List<int> nameIndexes = [];
  List<int> pathIndexes = [];
  /// Maps attribute identifiers (row index or name)
  /// to a map of pointers (row index) to the column index,
  /// in this direction so it is easy to diffuse characteristics to pointers.
  Map<AttAndCol, Map<int, int>> attributes = {};
  Map<int, Map<AttAndCol, int>> rowToAtt = {};
  /// Maps attribute identifiers (row index or name)
  /// to a map of mentioners (row index) to the column index
  Map<AttAndCol, Map<int, int>> toMentioners = {};
  List<Map<InstrStruct, int>> instrTable = [];
  Map<dynamic, List<AttAndCol>> colToAtt = {};
  Cell? selectionStart;
  Cell? selectionEnd;

  bool get hasSelectionRange =>
      selectionStart != null && selectionEnd != null;

  final _saveExecutor = OneSlotExecutor();

  SpreadsheetState({int rows = 30, int cols = 10}) {
    _loadLastOpenedSheet(); // <--- Add this
  }

  Future<void> _loadLastOpenedSheet() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString("last_opened_sheet");

    if (last != null && last.trim().isNotEmpty) {
      await loadSpreadsheet(last);
    }
  }

  int get rowCount => table.length;
  int get colCount => rowCount > 0 ? table[0].length : 0;

  String getColumnType(int col) {
    if (col >= colCount) return ColumnType.defaultType.name;
    return columnTypes[col];
  }

  // Select a cell
  void selectCell(int row, int col) {
    selectionStart = Cell(row: row, col: col);
    selectionEnd = selectionStart;
    populateCellNode(mentionsRoot, selectionStart!.row, selectionStart!.col);
    renderTree(mentionsRoot, container);
    notifyListeners();
  }

  void selectRange(int startRow, int startCol, int endRow, int endCol) {
    selectionStart = Cell(
      row: startRow,
      col: startCol
    );
    selectionEnd = Cell(
      row: endRow,
      col: endCol
    );
    populateCellNode(mentionsRoot, selectionStart!.row, selectionStart!.col);
    renderTree(mentionsRoot, container);
    notifyListeners();
  }

  bool isCellSelected(int row, int col) {
    if (!hasSelectionRange) return false;

    final r1 = selectionStart!.row;
    final c1 = selectionStart!.col;
    final r2 = selectionEnd!.row;
    final c2 = selectionEnd!.col;

    return row >= r1 && row <= r2 && col >= c1 && col <= c2;
  }

  // ---- Save data for current spreadsheet ----
  Future<void> saveSpreadsheet() async {
    if (spreadsheetName.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    final data = {"table": table, "columnTypes": columnTypes};

    await prefs.setString("spreadsheet_$spreadsheetName", jsonEncode(data));
  }

  Future<void> clearAllPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ---- Load spreadsheet by name ----
  Future<void> loadSpreadsheet(String name) async {
    // await clearAllPrefs();
    spreadsheetName = name.trim().toLowerCase();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      "last_opened_sheet",
      spreadsheetName,
    );

    final raw = prefs.getString("spreadsheet_$spreadsheetName");

    if (raw == null) {
      _saveExecutor.run(() async {
        getEverything();
      });
      return;
    }

    final decoded = jsonDecode(raw);

    // Restore table
    final storedGrid = (decoded["table"] as List)
        .map((row) => (row as List).map((v) => v.toString()).toList())
        .toList();

    table = List<List<String>>.generate(
      storedGrid.length,
      (r) => List<String>.filled(
        storedGrid[r].length,
        '',
        growable: true,
      ),
      growable: true,
    );
    for (int r = 0; r < storedGrid.length; r++) {
      for (int c = 0; c < storedGrid[r].length; c++) {
        table[r][c] = storedGrid[r][c];
      }
    }
    decreaseRowCount(rowCount - 1);
    decreaseColumnCount(colCount - 1);

    // Restore column types
    columnTypes = List<String>.from(decoded["columnTypes"] ?? []);

    _saveExecutor.run(() async {
      getEverything();
    });
  }

  void decreaseRowCount(int row) {
    if (row == rowCount - 1) {
      while (!table[row].any((cell) => cell.isNotEmpty) && row > 0) {
        table.removeLast();
        row--;
      }
    }
  }

  @override
  void updateCell(int row, int col, String newValue) {
    if (newValue.isNotEmpty || (row < rowCount && col < colCount)) {
      if (row >= rowCount) {
        final needed = row + 1 - rowCount;
        table.addAll(List.generate(needed, (_) => List.filled(colCount, '', growable: true)));
      }
      increaseColumnCount(col);
      table[row][col] = newValue;
    }
    if (newValue.isEmpty && row < rowCount && col < colCount && (row == rowCount - 1 || col == colCount - 1) && table[row][col].isNotEmpty) {
      decreaseRowCount(row);
      decreaseColumnCount(col);
    }
    
    _saveExecutor.run(() async {
      getEverything();
    });
  }

  // What to display in the side menu
  String get selectedCellInfo {
    if (!hasSelectionRange) {
      return "No selection";
    }

    final r1 = selectionStart!.row + 1;
    final c1 = columnName(selectionStart!.col);
    final r2 = selectionEnd!.row + 1;
    final c2 = columnName(selectionEnd!.col);

    return "Selected range: $c1$r1 → $c2$r2";
  }

  void pasteText(String rawText) {
    if (selectionStart == null) return;

    final startRow = selectionStart!.row;
    final startCol = selectionStart!.col;

    // Parse TSV (tab-separated values)
    final rows = rawText
        .replaceAll("\r", "")
        .split('\n')
        .map((r) => r.split('\t'))
        .toList();

    for (int r = 0; r < rows.length; r++) {
      for (int c = 0; c < rows[r].length; c++) {
        final targetRow = startRow + r;
        final targetCol = startCol + c;

        updateCell(targetRow, targetCol, rows[r][c]);
      }
    }
    log.info("Pasted text at $startRow, $startCol");
  }

  String columnName(int index) {
    index++;
    String name = "";
    while (index > 0) {
      int rem = (index - 1) % 26;
      name = String.fromCharCode(65 + rem) + name;
      index = (index - 1) ~/ 26;
    }
    return name;
  }

  void increaseColumnCount(int col) {
    if (col >= colCount) {
      final needed = col + 1 - colCount;
      for (var r = 0; r < rowCount; r++) {
        table[r].addAll(List.filled(needed, '', growable: true));
      }
      columnTypes.addAll(List.filled(needed, ColumnType.defaultType.name));
    }
  }

  void decreaseColumnCount(col) {
    if (col == columnTypes.length - 1) {
      bool canRemove = true;
      while (canRemove && col > 0) {
        for (var r = 0; r < rowCount; r++) {
          if (table[r][col].isNotEmpty) {
            canRemove = false;
            break;
          }
        }
        if (canRemove) {
          for (var r = 0; r < rowCount; r++) {
            table[r].removeLast();
          }
          col--;
        }
      }
      columnTypes = columnTypes.sublist(0, col + 1);
    }
  }

  @override
  void setColumnType(int col, String type) {
    if (type == ColumnType.defaultType.name) {
      if (col < colCount) {
        columnTypes[col] = type;
        decreaseColumnCount(col);
      }
    } else {
      increaseColumnCount(col);
      columnTypes[col] = type;
    }
    _saveExecutor.run(() async {
      getEverything();
    });
  }

  Future<String?> copySelectionToClipboard() async {
    if (!hasSelectionRange) return null;

    final r1 = selectionStart!.row;
    final c1 = selectionStart!.col;
    final r2 = selectionEnd!.row;
    final c2 = selectionEnd!.col;

    final buffer = StringBuffer();

    for (int r = r1; r <= r2; r++) {
      final rowValues = <String>[];
      for (int c = c1; c <= c2; c++) {
        rowValues.add(r < rowCount && c < colCount ? table[r][c] : '');
      }
      buffer.writeln(rowValues.join('\t')); // TSV format
    }

    final text = buffer.toString().trimRight();
    await Clipboard.setData(ClipboardData(text: text));
    return text;
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
          "Invalid character '${s[i]}' at index $i. Input must only contain lowercase letters (a-z)."
        );
      }

      // 'a' (97) becomes 0, 'b' (98) becomes 1, etc.
      int value = codeUnit - 97;
      result = result * 26 + value;
    }
    return result;
  }

  String getColumnLabel(int col) {
    String columnLabel = "";
    int tempCol = col + 1; // Excel columns start at 1, not 0

    // Convert column number to letters (e.g., 1 -> A, 27 -> AA)
    while (tempCol > 0) {
      int remainder = (tempCol - 1) % 26;
      columnLabel = String.fromCharCode(65 + remainder) + columnLabel;
      tempCol = (tempCol - 1) ~/ 26;
    }

    return columnLabel;
  }

  List<Cell> findPath(dynamic graph, int start, int end, {bool reverse = true}) {
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

  void dfsIterative(Map<dynamic, Map<dynamic, int>> graph, dynamic accumulator, String warningMsgPrefix) {
    final visited = <int>{};
    final completed = <int>{};
    List<dynamic> path = [];

    final List<NodeStruct> redundantRef = [];
    for (final start in graph.keys) {
      if (visited.contains(start)) continue;
      final stack = [start];

      while (stack.isNotEmpty) {
        final node = stack[stack.length - 1]; // peek
        if (path[path.length - 1] == node) {
          Map nodeChildren = accumulator[node] ?? {};

          for (final child in nodeChildren.keys) {
            Map<dynamic, int>? childMap = graph[child];
            if (childMap != null) {
              for (final grandChild in childMap.keys) {
                if (!nodeChildren.containsKey(grandChild)) {
                  nodeChildren[grandChild] = -1;
                } else if (nodeChildren[grandChild] != -1) {
                  var newPath = [...findPath(graph, child, grandChild),
                   Cell(row: node, col: graph[child]![node]!)]
                    .map((k) => NodeStruct(row: k.row, col: k.col))
                    .toList();
                  redundantRef.add(
                    NodeStruct(
                      message: "$warningMsgPrefix \"$grandChild\" already pointed",
                      row: node,
                      col: nodeChildren[grandChild],
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
            final cyclePathNodes = cycle.map((k) => NodeStruct(row: k)).toList();
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "cycle detected",
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

  String getRowName(row) { // TODO: adapt to width available
    String names = "";
    for (int colId in nameIndexes) {
      for (String name in mentions[row][colId].map((e) => e.name)) {
        if (names.isNotEmpty) {
          names += ", ";
        }
        names += '"${name.toString()}"';
      }
    }
    return "row $row: $names";
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
          } else if (
            resultList.length > 0 &&
            resultList[resultList.length - 1][1] == -1
          ) {
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
              message: "Invalid interval: overlapping or adjacent intervals found.",
              row: row,
              col: col,
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

  AttAndCol getAttAndCol(String attWritten, int rowId, int colId) {
    AttAndCol att = AttAndCol("", -1);
    List<String> splitStr = attWritten.split(".");
    String name = attWritten;
    dynamic colIdStr = notUsedCst;
    if (splitStr.length == 2) {
      name = splitStr[1];
      colIdStr = getIndexFromString(splitStr[0]);
      if (colIdStr < 0 || colIdStr >= colCount) {
        errorRoot.newChildren!.add(
          NodeStruct(
            message: "Column ${splitStr[0]} does not exist",
            row: rowId,
            col: colId,
          ),
        );
        return att;
      }
    } else if (splitStr.length > 2) {
      errorRoot.newChildren!.add(
        NodeStruct(
          message: "Invalid attribute format: too many '.' characters",
          row: rowId,
          col: colId,
        ),
      );
      return att;
    }
    final numK = int.tryParse(name);
    if (numK != null) {
      if (colIdStr != notUsedCst) {
        errorRoot.newChildren!.add(
          NodeStruct(
            message: "Cannot use both column and row index for attribute reference",
            row: rowId,
            col: colId,
          ),
        );
        return att;
      }
      if (numK < 1 || numK > rowCount - 1) {
        warningRoot.newChildren!.add(
          NodeStruct(
            message: "$name points to an empty row $numK",
            row: rowId,
            col: colId,
          ),
        );
      }
      att = AttAndCol(numK, rowCst);
    } else {
      // TODO: validate attribute name
      if (columnTypes[colId] != ColumnType.attributes.name &&
          columnTypes[colId] != ColumnType.sprawl.name) {
        colIdStr = colId;
      }
      att = AttAndCol(name, colIdStr);
    }
    mentions[rowId][colId].add(att);
    rowToAtt[rowId]![att] = colId;
    colToAtt[colId]!.add(att);
    return att;
  }

  void getCategories() {
    // final saved = {
    //   input: { name: name, table: table, columnTypes: columnTypes },
    //   output: { errorRoot: errorRoot },
    // };

    if (errorRoot.newChildren!.isNotEmpty) {
      return;
    }

    colToAtt = {};
    Map<AttAndCol, List<int>> attToDist = {};
    DynAndInt firstElement = DynAndInt(-1, -1);
    DynAndInt lastElement = DynAndInt(-1, -1);
    final Map fstCat = {};
    final Map lstCat = {};
    colToAtt[rowCst] = [];
    colToAtt[notUsedCst] = [];
    List<NodeStruct> children = [];
    attributes = {};
    attToCol = {};
    names = {};
    rowToAtt = { for (var i = 0; i < rowCount; i++) i: {} };
    for (int rowId = 1; rowId < rowCount; rowId++) {
      final row = table[rowId];
      for (int colId = 0; colId < row.length; colId++) {
        final isSprawl = columnTypes[colId] == ColumnType.sprawl.name;
        if (columnTypes[colId] == ColumnType.attributes.name || isSprawl) {
          if (row[colId].isEmpty) {
            continue;
          }
          final cellList = row[colId].split("; ");
          for (String attWritten in cellList) {
            if (attWritten.isEmpty) {
              errorRoot.newChildren!.add(
                NodeStruct(message: "empty attribute name", row: rowId, col: colId),
              );
              return;
            }

            bool isFst = attWritten.endsWith("-fst");
            bool isLst = false;

            if (isFst) {
              attWritten = attWritten.substring(0, attWritten.length - 4).trim();
            } else if (attWritten == "fst") {
              firstElement = DynAndInt(rowId, colId);
              continue;
            } else if ((isLst = attWritten.endsWith("-lst"))) {
              attWritten = attWritten.substring(0, attWritten.length - 4).trim();
            } else if (attWritten == "lst") {
              lastElement = DynAndInt(rowId, colId);
              continue;
            } else if (attWritten.contains("-fst")) {
              errorRoot.newChildren!.add(
                NodeStruct(
                  message: "'-fst' is not at the end of ${attWritten}",
                  row: rowId,
                  col: colId,
                ),
              );
              return;
            }

            AttAndCol att = getAttAndCol(attWritten, rowId, colId);
            if (errorRoot.newChildren!.isNotEmpty) {
              return;
            }
            if (att.col == rowCst) {
              if (!attToCol.containsKey(attWritten)) {
                attToCol[attWritten] = [];
              }
              if (attToCol[attWritten]!.contains(colId) == false) {
                attToCol[attWritten]!.add(colId);
              }
            }

            if (!attributes.containsKey(att)) {
              attributes[att] = {};
              if (isSprawl) {
                attToDist[att] = [];
              }
            }

            if (attributes[att]!.containsKey(rowId)) {
              attributes[att]![rowId] = colId;
              if (isSprawl) {
                attToDist[att]!.add(rowId);
              }
            } else {
              children.add(NodeStruct(row: rowId, col: colId));
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

    dfsIterative(attributes, attributes, "attribute");

    if (errorRoot.newChildren!.isNotEmpty) {
      return;
    }

    List<List<String>> urls = List.generate(
      rowCount,
      (i) => List.generate(
        pathIndexes.length,
        (j) => table[i][pathIndexes[j]],
      ),
    );

    var urlFrom = List.generate(rowCount, (i) => -1);
    for (int i = 1; i < rowCount; i++) {
      final row = table[i];
      if (urls[i].isNotEmpty && attributes.containsKey(i)) {
        for (final k in attributes[i]!.keys) {
          if (urls[k].isNotEmpty) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message:
                    "URL conflict",
                    startOpen: true,
                newChildren: [
                  NodeStruct(
                    message: "path 1",
                    startOpen: true,
                    newChildren: findPath(attributes, urlFrom[k], k)
                        .map((x) => NodeStruct(
                          row: x.row,
                          col: x.col,
                        ))
                        .toList(),
                  ),
                  NodeStruct(
                    message: "path 2",
                    startOpen: true,
                    newChildren: findPath(attributes, i, k)
                        .map((x) => NodeStruct(
                          row: x.row,
                          col: x.col,
                        ))
                        .toList(),
                  ),
                ],
              ),
            );
            return;
          }
          if (!attributes.containsKey(k)) {
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
      if (urls[i].isNotEmpty) {
        validRowIndexes.add(i);
        newIndexes[i] = newIndex;
        newIndex++;
        toOldIndexes.add(i);
      } else {
        catRows.add(i);
      }
    }

    if (validRowIndexes.isEmpty) {
      errorRoot.newChildren!.add(
        NodeStruct(message: "No valid rows found in the table!"),
      );
      return;
    }

    final Map<dynamic, NodeStruct> categoriesChildren = {};
    final Map<dynamic, NodeStruct> sprawlChildren = {};
    for (final MapEntry(key: col, value: attrs) in colToAtt.entries) {
      if (col == notUsedCst) continue;
      List<NodeStruct> catColChildren = [];
      List<NodeStruct> spColChildren = [];
      for (final attr in attrs) {
        catColChildren.add(NodeStruct(row: attr.name));

        var rowsList = attToDist[attr]!;
        if (rowsList.length < 2) {
          warningRoot.newChildren!.add(
            NodeStruct(
              message:
                  "Only one row for sprawl attribute \"${attr.name}\"",
              att: attr
            ),
          );
          continue;
        }
        rowsList = rowsList..sort();
        final distPairs = List.filled(rowsList.length - 1, 0);
        int minDist = double.infinity.toInt();
        for (var i = 0; i < rowsList.length - 1; i++) {
          var d = (rowsList[i] - rowsList[i + 1]).abs();
          for (var k = rowsList[i] + 1; k < rowsList[i + 1]; k++) {
            if (urls[k].isEmpty) {
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
            row: attr.name,
            newChildren: distPairs.asMap().entries.map((entry) {
              final idx = entry.key;
              final d = entry.value;
              return NodeStruct(
                message:
                    "($d) ${getRowName(rowsList[idx])} - ${getRowName(rowsList[idx + 1])}",
                newChildren: [
                  NodeStruct(row: rowsList[idx]),
                  NodeStruct(row: rowsList[idx + 1]),
                ],
                dist: d,
              );
            }).toList()..sort((a, b) => a.row! - b.row!),
            minDist: minDist,
          ),
        );
      }
      categoriesChildren[col] = NodeStruct(
        col: col,
        newChildren: catColChildren..sort((a, b) => a.row! - b.row!),
      );
      sprawlChildren[col] = NodeStruct(
        col: col,
        newChildren: spColChildren..sort((a, b) => a.minDist! - b.minDist!),
      );
    }
    final List<NodeStruct> categoChildrenList = [];
    final List<NodeStruct> sprawlChildrenList = [];
    for (final (
          List<NodeStruct> childrenList,
          Map<dynamic, NodeStruct> children,
        )
        in [
          (categoChildrenList, categoriesChildren),
          (sprawlChildrenList, sprawlChildren),
        ]) {
      for (int j = 0; j < colCount; j++) {
        final isSprawl = columnTypes[j] == ColumnType.sprawl.name;
        if (columnTypes[j] == ColumnType.attributes.name || isSprawl) {
          childrenList.add(children[j]!);
        }
      }
      if (children.containsKey(rowCst)) {
        childrenList.add(children[rowCst]!);
      }
    }
    categoriesRoot.newChildren = categoChildrenList;
    distPairsRoot.newChildren = sprawlChildrenList;

    instrTable = List.generate(rowCount, (_) => {});

    for (final MapEntry(key: k, value: v) in fstCat.entries) {
      if (urls[k].isNotEmpty) {
        var t = v.att;
        while (fstCat.containsKey(t)) {
          t = fstCat[t]!.att;
        }
        for (final i in attributes[t]!.keys) {
          if (i != k) {
            instrTable[i][
              InstrStruct(
                true,
                false,
                [newIndexes[k]],
                [
                  [-double.infinity.toInt(), -1],
                ],
              )
            ] = v.col;
          }
        }
      }
    }

    for (final MapEntry(key: k, value: v) in lstCat.entries) {
      if (urls[k].isNotEmpty) {
        var t = v.att;
        while (lstCat.containsKey(t)) {
          t = lstCat[t]!.att;
        }
        for (final i in attributes[t]!.keys) {
          if (i != k) {
            instrTable[i][
              InstrStruct(true, false, [newIndexes[k]], [[1, double.infinity.toInt()]])
            ] = v.col;
          }
        }
      }
    }

    if (firstElement.dyn != -1) {
      for (final i in validRowIndexes) {
        if (i != firstElement.dyn) {
          instrTable[i][
            InstrStruct(
              true,
              false,
              [newIndexes[firstElement.dyn]],
              [[-double.infinity.toInt(), -1]],
            )
          ] = firstElement.id;
        }
      }
    }

    if (lastElement.dyn != -1) {
      for (final i in validRowIndexes) {
        if (i != lastElement.dyn) {
          instrTable[i][
            InstrStruct(
              true,
              false,
              [newIndexes[lastElement.dyn]],
              [[1, double.infinity.toInt()]],
            )
          ] = lastElement.id;
        }
      }
    }

    final depPattern = table[0].map((cell) => cell.split(".")).toList();

    for (int rowId = 1; rowId < rowCount; rowId++) {
      if (urls[rowId].isEmpty && !(attributes[colCount]!.containsKey(rowId))) {
        continue;
      }

      final row = table[rowId];
      for (int colId = 0; colId < row.length; colId++) {
        if (columnTypes[colId] == ColumnType.dependencies.name && row[colId].isNotEmpty) {
          // TODO: OR and AND
          String instr = row[colId];
          if (instr.isEmpty) continue;
          final instrSplit = instr.split("_");
          if (
            instrSplit.length != depPattern[colId].length - 1 &&
            depPattern[colId].length > 1
          ) {
            errorRoot.newChildren!.add(NodeStruct(
                message: "$instr does not match dependencies pattern ${depPattern[colId]}",
                row: rowId,
                col: colId,
              ),
            );
            return;
          }

          if (depPattern[colId].length > 1) {
            instr =
              depPattern[colId][0] +
              instrSplit
                .asMap().entries.map((entry) {
                  final idx = entry.key;
                  final split = entry.value;
                  return split + depPattern[colId][idx + 1];
                })
                .join("");
          }

          var match = RegExp(PATTERN_DISTANCE).firstMatch(instr);
          List<List<int>> intervals = [];
          var isConstraint = match == null;

          if (isConstraint) {
            match = RegExp(PATTERN_AREAS).firstMatch(instr);
            if (match == null) {
              errorRoot.newChildren!.add(NodeStruct(
                  message: "$instr does not match expected format",
                  row: rowId,
                  col: colId,
                ),
              );
              return;
            }
            intervals = getIntervals(instr, rowId, colId);
            if (errorRoot.newChildren!.isNotEmpty) {
              return;
            }
          }

          final numbers = [];

          AttAndCol att = getAttAndCol(match.namedGroup('att')!, rowId, colId);
          if (errorRoot.newChildren!.isNotEmpty) {
            return;
          }
          mentions[rowId][colId].add(att);
          for (final r in attributes[att]!.keys) {
            if (urls[r].isNotEmpty) {
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
                message: "duplicate instruction \"$instr\"",
                row: rowId,
                col: colId,
              ),
            );
          } else {
            instrTable[rowId][instruction] = colId;
          }
        }
      }
    }

    toMentioners = {};
    for (var i = 1; i < rowCount; i++) {
      for (var j = 0; j < table[i].length; j++) {
        if (columnTypes[j] == ColumnType.dependencies.name) {
          for (final n in mentions[i][j]) {
            if (!toMentioners.containsKey(n)) {
              toMentioners[n] = {};
            }
            if (!toMentioners[n]!.containsKey(i)) {
              toMentioners[n]![i] = j;
            }
          }
        }
      }
    }

    dfsIterative(rowToAtt, instrTable, "instruction");

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

    urls = validRowIndexes.asMap().entries.map((i) { return urls[i.value]; }).toList();

    // TODO: solve sorting pb

    if (attributes.containsKey(notUsedCst)) {
      final atts = attributes[notUsedCst]!.keys.toList();
      children = atts.asMap().entries.map((entry) {
        var a = entry.value;
        if (toMentioners[a]!.keys.length == 1) {
          return NodeStruct(
            message: "$a",
            row: toMentioners[a]!.keys.first,
            col: toMentioners[a]![toMentioners[a]!.keys.first],
          );
        } else {
          return NodeStruct(
            message: "$a",
            newChildren: toMentioners[a]!.keys.map(
              (k) => NodeStruct(row: k, col: toMentioners[a]![k]),
            ).toList(),
          );
        }
      }).toList();
      warningRoot.newChildren!.add(
        NodeStruct(
          message: "unused attributes found",
          newChildren: children,
        ),
      );
    }
    return;
  }

  void getEverything() {
    log.info("Processing spreadsheet data...");
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
    mentions = List.generate(
      rowCount,
      (_) => List.generate(colCount, (_) => <AttAndCol>[]),
    );
    for (int i = 0; i < rowCount; i++) {
      for (int j in nameIndexes) {
        var cellElements = table[i][j].split(";");
        for (int k = 0; k < cellElements.length; k++) {
          cellElements[k] = cellElements[k].trim().toLowerCase();
          if (cellElements[k].isNotEmpty) {
            mentions[i][j].add(AttAndCol(cellElements[k], j));
          }
        }
      }
    }
    names = {};
    for (int i = 1; i < rowCount; i++) {
      for (int j in nameIndexes) {
        for (final att in mentions[i][j]) {
          if (int.tryParse(att.name) != null) {
            errorRoot.newChildren!.add(
              NodeStruct(message: "$att is not a valid name", row: i, col: j),
            );
            return;
          }

          final match = RegExp(r' -(\w+)$').firstMatch(att.name);
          if (att.name.contains("_") ||
              att.name.contains(":") ||
              att.name.contains("|") ||
              (match != null && !["fst", "lst"].contains(match.group(1)))) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "$att contains invalid characters (_ : | -)",
                row: i,
                col: j,
              ),
            );
          }

          final parenMatch = RegExp(r'(\(\d+\))$').firstMatch(att.name);
          if (parenMatch != null) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "$att contains invalid parentheses",
                row: i,
                col: j,
              ),
            );
          }

          if (["fst", "lst"].contains(att)) {
            errorRoot.newChildren!.add(
              NodeStruct(message: "$att is a reserved name", row: i, col: j),
            );
          }

          if (names.containsKey(att)) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "name $att used two times",
                newChildren: [
                  NodeStruct(row: i, col: j),
                  NodeStruct(row: names[att]!.row, col: j),
                ],
              ),
            );
          }
          names[att.name] = Cell(row: i, col: j);
        }
      }
    }
    getCategories();
    saveSpreadsheet();
    notifyListeners();
  }

  void populateCellNode(NodeStruct root, int rowId, int colId) {
    root.newChildren = [];
    if (columnTypes[colId] == ColumnType.names.name ||
        columnTypes[colId] == ColumnType.filePath.name ||
        columnTypes[colId] == ColumnType.url.name) {
      root.newChildren!.add(
        NodeStruct(
          message: table[rowId][colId],
          att: AttAndCol(rowId, rowCst),
        ),
      );
      return;
    }
    for (AttAndCol att in mentions[rowId][colId]) {
      root.newChildren!.add(
        NodeStruct(
          att: att,
        ),
      );
    }
  }

  void dfsDepthUpdate(NodeStruct node, int increase, bool newChildren) {
    final stack = [DynAndInt(node, increase)];
    while (stack.isNotEmpty) {
      DynAndInt curr = stack.removeLast();
      NodeStruct currNode = curr.dyn;
      final parentDepth = curr.id;
      for (final child in (newChildren ? currNode.newChildren! : currNode.children)) {
        child.depth = parentDepth + ((child.startOpen && parentDepth == 0) ? 0 : 1);
        if (child.depth < 2 + increase) {
          stack.add(DynAndInt(child, child.depth));
        }

      }
    }
  }

  // TODO : non recursive version
  void renderTree(root, container) {
    container.innerHTML = ""; // clear old content

    function createNode(node, container) {
      const li = document.createElement("li");
      li.style.display = node.hideIfEmpty && (!node.children || node.children.length === 0) ? "none" : "block";
      li.classList.add("expandable");

      // arrow (▶ / ▼)
      const arrow = document.createElement("span");

      arrow.classList.add("arrow");
      arrow.textContent = node.depth ? "▶" : "▼";

      // label text
      const label = document.createElement("span");
      if (node.id !== undefined) {
        if (node.col === undefined) {
          label.textContent += node.id + " ";
        } else if (result.nameIndexes.has(node.col)) {
          label.textContent += `row:${node.id} `;
        } else {
          label.textContent += getCellPosition(node.id, node.col) + " ";
        }
      } else if (node.col !== undefined) {
        label.textContent +=
          getColumnLabel(node.col) + " " + result.table[0][node.col] + " ";
      }
      if (node.message !== undefined) {
        label.textContent += node.message;
      }
      if (node.children) {
        label.textContent += " (" + node.children.length + ")";
      }
      label.style.marginLeft = "4px";
      label.classList.add("node-label");

      // nested children list
      const ul = document.createElement("ul");
      ul.classList.add("nested");
      if (!node.depth) {
        ul.style.display = "block";
      }
      if (node.depth < 2 && Array.isArray(node.children)) {
        node.children.forEach((child) => ul.appendChild(createNode(child, ul)));
      }

      // toggle expand/collapse
      function toggleNodeVisibility() {
        const increase = Number(!node.depth);
        node.depth = increase;
        arrow.textContent = increase ? "▶" : "▼";
        ul.style.display = increase ? "none" : "block";
        dfsDepthUpdate(node, increase, "children");
        populateTree(node, container, true);
      }

      // arrow click → toggle expand/collapse
      arrow.addEventListener("click", (event) => {
        event.stopPropagation();
        toggleNodeVisibility();
      });

      // label click → goToCell if node.row defined, else toggle
      label.addEventListener("click", (event) => {
        event.stopPropagation();
        if (node.row !== undefined && node.col !== undefined) {
          goToCell(node.row, node.col);
          // TODO: mentions
        } else {
          toggleNodeVisibility();
        }
      });

      // assemble
      li.appendChild(arrow);
      li.appendChild(label);
      li.appendChild(ul);

      return li;
    }
    container.appendChild(createNode(root, container));
  }

  void populateRowNode(NodeStruct root, int rowId) {
    int colNb = 0;
    for (int colId = 0; colId < colCount; colId++) {
      if (table[rowId][colId].isNotEmpty) {
        colNb = colId;
      }
      root.newChildren!.add(
        NodeStruct(
          row: rowId,
          col: colId,
        ),
      );
    }
    root.newChildren = root.newChildren!
          .sublist(0, colNb + 1);
  }

  void populateTree(NodeStruct root, container, {bool keepPrev = false}) {
    var stack = [root];
    while (stack.isNotEmpty) {
      var node = stack.removeLast();
      if (keepPrev) {
        node.newChildren = node.children;
      }
      if (node.newChildren == null) {
        node.newChildren = [];
        if (node.row != null) {
          if (node.col != null) {
            populateCellNode(node, node.row!, node.col!);
          } else {
            populateRowNode(node, node.row!);
          }
        } else if (node.col != null) {
          int colId = node.col!;
          for (final att in colToAtt[colId]!) {
            node.newChildren!.add(
              NodeStruct(
                att: att,
              ),
            );
          }
        } else if (node.att != null) {
          int rowId = node.att!.name;
          if (node.att!.col == rowCst) {
            populateRowNode(node, rowId);
          }
          for (int pointerRowId in attributes[node.att]!.keys) {
            node.newChildren!.add(
              NodeStruct(
                att: AttAndCol(pointerRowId, rowCst),
              ),
            );
          }
        }
      }
      dfsDepthUpdate(node, 1, true);

      // TODO: find a faster process for bigger input
      if (node.depth == 0) {
        List<List<int>> similarity = List.generate(node.children.length, (_) => List.generate(0, (_) => 0));
        for (int i = 0; i < node.children.length; i++) {
          var obj = node.children[i];
          for (int j = 0; j < node.newChildren!.length; j++) {
            var newObj = node.newChildren![j];
            int sim = 0;
            sim << 1;
            if (obj.message != null && obj.message == newObj.message) sim | 1;
            sim << 1;
            if (obj.row != null && obj.row == newObj.row) sim | 1;
            sim << 1;
            if (obj.col != null && obj.col == newObj.col) sim | 1;
            sim << 1;
            if (obj.startOpen == newObj.startOpen) sim | 1;
            sim << 1;
            if (obj.newChildren != null && newObj.newChildren != null) {
              if (jsonEncode(obj.newChildren) == jsonEncode(newObj.newChildren)) {
                sim | 1;
              }
            }
            sim << 1;
            if (obj.newChildren != null && newObj.newChildren != null) {
              if (obj.newChildren!.length == newObj.newChildren!.length) {
                sim | 1;
              }
            }
            similarity[i][j] = sim;
          }
        }
        // 1. Instantiate the solver
        final solver = HungarianAlgorithm(similarity);
        
        // 2. Compute result
        final result = solver.compute();

        print("Maximum Total Weight: ${result.maxWeight}");
        
        // 3. See who matches with whom
        for (int i = 0; i < result.assignments.length; i++) {
          int elementB_Index = result.assignments[i];
          print("Element A[$i] is paired with Element B[$elementB_Index]");
        }
      }
      node.children = node.newChildren!;
      if (node.depth < 2) {
        for (final child in node.children) {
          stack.add(child);
        }
      }
    }
    renderTree(root, container);
  }

}
