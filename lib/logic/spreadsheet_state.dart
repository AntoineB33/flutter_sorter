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

class HungarianAlgorithm {
  final List<List<int>> costMatrix;
  late int dim;
  late List<int> labelX;
  late List<int> labelY;
  late List<int> matchY; // matchY[j] = i means j is matched with i
  late List<int> matchX; // matchX[i] = j means i is matched with j
  late List<int> slack;
  late List<bool> visX;
  late List<bool> visY;

  HungarianAlgorithm(this.costMatrix);

  /// Solves the assignment problem and returns the Result object
  AssignmentResult compute() {
    int n = costMatrix.length;
    int m = costMatrix[0].length;
    
    // The algorithm requires a square matrix. 
    // If A and B have different sizes, we pad with 0s.
    dim = max(n, m);
    
    // Initialize mapping arrays
    labelX = List.filled(dim, 0);
    labelY = List.filled(dim, 0);
    matchY = List.filled(dim, -1);
    matchX = List.filled(dim, -1);
    slack = List.filled(dim, 0);
    visX = List.filled(dim, false);
    visY = List.filled(dim, false);

    // Initialize labels for X with max weight in each row
    for (int i = 0; i < n; i++) {
      int maxVal = -1 >>> 1; // Very small number
      for (int j = 0; j < m; j++) {
         if (costMatrix[i][j] > maxVal) maxVal = costMatrix[i][j];
      }
      // Handle case where row might be empty or all negative
      labelX[i] = maxVal == (-1 >>> 1) ? 0 : maxVal;
    }

    // Main algorithm loop
    for (int i = 0; i < dim; i++) {
      // Reset slack
      slack.fillRange(0, dim, 999999999); // Infinity
      
      while (true) {
        visX.fillRange(0, dim, false);
        visY.fillRange(0, dim, false);
        
        if (dfs(i, n, m)) break; // Found a path

        // If no path, update labels (re-weighting)
        int d = 999999999;
        for (int j = 0; j < dim; j++) {
          if (!visY[j]) d = min(d, slack[j]);
        }

        if (d == 999999999) break; // Should not happen if solvable

        for (int k = 0; k < dim; k++) {
          if (visX[k]) labelX[k] -= d;
          if (visY[k]) labelY[k] += d;
          else slack[k] -= d;
        }
      }
    }

    // Compile results
    int totalWeight = 0;
    List<int> assignment = [];
    
    for (int i = 0; i < n; i++) {
      int matchedJ = matchX[i];
      // Only count valid matches within original bounds
      if (matchedJ != -1 && matchedJ < m) {
        totalWeight += costMatrix[i][matchedJ];
        assignment.add(matchedJ);
      } else {
        // Should not happen if n <= m, but handles edge cases
        assignment.add(-1); 
      }
    }

    return AssignmentResult(totalWeight, assignment);
  }

  bool dfs(int x, int n, int m) {
    visX[x] = true;
    for (int y = 0; y < dim; y++) {
      if (visY[y]) continue;
      
      int weight = (x < n && y < m) ? costMatrix[x][y] : 0;
      int gap = labelX[x] + labelY[y] - weight;

      if (gap == 0) {
        visY[y] = true;
        if (matchY[y] == -1 || dfs(matchY[y], n, m)) {
          matchY[y] = x;
          matchX[x] = y;
          return true;
        }
      } else {
        slack[y] = min(slack[y], gap);
      }
    }
    return false;
  }
}

class AssignmentResult {
  final int maxWeight;
  /// assign[i] = j means row i is assigned to column j
  final List<int> assignments; 

  AssignmentResult(this.maxWeight, this.assignments);
}

class DynAndInt {
  dynamic dyn;
  int id;

  DynAndInt(this.dyn, this.id);
}

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
    r'^(?<prefix>as far as possible from )(?<any>any)?((?<number>\d+)|(((?<column>.+)\.)?(?<name>.+)))$/';
  static const PATTERN_AREAS =
    r'^(?<prefix>.*\|)(?<any>any)?((?<number>\d+)|(((?<column>.+)\.)?(?<name>.+)))(?<suffix>\|.*)$/';
  static const rows = "rows";
  static const notUsed = "notUsed";
  String spreadsheetName = "";
  final NodeStruct errorRoot = NodeStruct(message: 'Error Log', newChildren: []);
  final NodeStruct warningRoot = NodeStruct(message: 'Warning Log', newChildren: []);
  final NodeStruct mentionsRoot = NodeStruct(message: 'Current selection', newChildren: []);
  final NodeStruct searchRoot = NodeStruct(message: 'Search results', newChildren: []);
  final NodeStruct categoriesRoot = NodeStruct(message: 'Categories', newChildren: []);
  final NodeStruct distPairsRoot = NodeStruct(message: 'Distance Pairs', newChildren: []);
  late List<List<String>> table = [];
  List<String> columnTypes = [];

  /// 2D table of attribute identifiers (row index or name)
  /// mentioned in each cell.
  List<List<dynamic>> mentions = [];
  Map<String, Cell> names = {};
  Map<String, List<dynamic>> att_to_col = {};
  var rolesOptions;
  var newSelectedRoleList;
  List<int> nameIndexes = [];
  List<int> pathIndexes = [];
  var selectedRow;
  var selectedCol;
  var wasEdited;
  /// Maps attribute identifiers (row index or name)
  /// to a map of pointers (row index) to the column index,
  /// in this direction so it is easy to diffuse characteristics to pointers.
  Map<dynamic, Map<int, int>> attributes = {};
  Map<int, Map<dynamic, int>> rowToAtt = {};
  /// Maps attribute identifiers (row index or name)
  /// to a map of mentioners (row index) to the column index
  Map<dynamic, Map<int, int>> toMentioners = {};
  List<Map<dynamic, int>> instrTable = [];
  Cell? _selectionStart;
  Cell? _selectionEnd;

  Cell? get selectionStart => _selectionStart;
  Cell? get selectionEnd => _selectionEnd;

  bool get hasSelectionRange =>
      _selectionStart != null && _selectionEnd != null;

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
    _selectionStart = Cell(row: row, col: col);
    _selectionEnd = _selectionStart;
    notifyListeners();
  }

  void selectRange(int startRow, int startCol, int endRow, int endCol) {
    _selectionStart = Cell(
      row: startRow,
      col: startCol
    );
    _selectionEnd = Cell(
      row: endRow,
      col: endCol
    );
    notifyListeners();
  }

  bool isCellSelected(int row, int col) {
    if (!hasSelectionRange) return false;

    final r1 = _selectionStart!.row;
    final c1 = _selectionStart!.col;
    final r2 = _selectionEnd!.row;
    final c2 = _selectionEnd!.col;

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
    if (_selectionStart == null) return;

    final startRow = _selectionStart!.row;
    final startCol = _selectionStart!.col;

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
                    .map((k) => NodeStruct(id: k.row, col: k.col))
                    .toList();
                  redundantRef.add(
                    NodeStruct(
                      message: "$warningMsgPrefix \"$grandChild\" already pointed",
                      id: node,
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
            final cyclePathNodes = cycle.map((k) => NodeStruct(id: k)).toList();
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
    if (redundantRef.length > 0) {
      warningRoot.newChildren!.add(
        NodeStruct(
          message: "redundant references found",
          newChildren: redundantRef,
        ),
      );
    }
  }

  String getRowName(row) {
    return mentions[row][nameIndexes.first][0] + " (row $row)";
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
              id: row,
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

  void getCategories() {
    // final saved = {
    //   input: { name: name, table: table, columnTypes: columnTypes },
    //   output: { errorRoot: errorRoot },
    // };

    List<NodeStruct> children = [];
    for (int i = 1; i < rowCount; i++) {
      for (int j in pathIndexes) {
        for (final url in mentions[i][j]) {
          if (!RegExp(r'^(https?:\/\/|file:\/\/)').hasMatch(url)) {
            children.add(NodeStruct(message: url, id: i, col: j));
          }
        }
      }
    }
    if (children.isNotEmpty) {
      warningRoot.newChildren!.add(
        NodeStruct(message: "invalid URLs found", newChildren: children),
      );
    }

    if (errorRoot.newChildren!.isNotEmpty) {
      return;
    }

    Map col_to_att = {};
    Map att_to_dist = {};
    DynAndInt firstElement = DynAndInt(-1, -1);
    DynAndInt lastElement = DynAndInt(-1, -1);
    final Map fstCat = {};
    final Map lstCat = {};
    final col_name_to_index = new Map();
    for (int j = 0; j < colCount; j++) {
      if ([
        ColumnType.attributes.name,
        ColumnType.sprawl.name,
      ].contains(columnTypes[j])) {
        col_to_att[j] = [];
      }
      if (col_name_to_index.containsKey(table[0][j])) {
        errorRoot.newChildren!.add(
          NodeStruct(
            message:
                "duplicate column name ${table[0][j]} in ${getColumnLabel(j)} and ${getColumnLabel(col_name_to_index[table[0][j]])}",
          ),
        );
      }
      col_name_to_index[table[0][j]] = j;
    }
    col_to_att[rows] = [];
    col_to_att[notUsed] = [];
    children = [];
    attributes = {};
    att_to_col = {};
    names = {};
    var colNames = List.generate(colCount, (j) => "");
    List<NodeStruct> emptyNamesChildren = [];
    for (int j = 0; j < colCount; j++) {
      if ([ColumnType.attributes.name, ColumnType.sprawl.name]
          .contains(columnTypes[j])) {
        if (table[0][j].isEmpty) {
          emptyNamesChildren.add(
            NodeStruct(
              id: 0,
              col: j,
            ),
          );
        } else if (colNames.contains(table[0][j])) {
          errorRoot.newChildren!.add(
            NodeStruct(
              message:
                  "duplicate column name \"${table[0][j]}\"",
              startOpen: true,
              newChildren: [
                NodeStruct(
                  id: 0,
                  col: j,
                ),
                NodeStruct(
                  id: 0,
                  col: colNames.indexOf(table[0][j]),
                ),
              ],
            ),
          );
          return;
        }
      }
    }
    if (emptyNamesChildren.isNotEmpty) {
      errorRoot.newChildren!.add(
        NodeStruct(
          message: "empty attribute column names",
          newChildren: emptyNamesChildren
        ),
      );
      return;
    }
    rowToAtt = { for (var i = 0; i < rowCount; i++) i: {} };
    for (int i = 1; i < rowCount; i++) {
      final row = table[i];
      for (int j = 0; j < row.length; j++) {
        final isSprawl = columnTypes[j] == ColumnType.sprawl.name;
        if (columnTypes[j] == ColumnType.attributes.name || isSprawl) {
          if (row[j].isEmpty) {
            continue;
          }
          final cellList = row[j].split("; ");
          for (String instr in cellList) {
            if (instr.isEmpty) {
              errorRoot.newChildren!.add(
                NodeStruct(message: "empty attribute name", id: i, col: j),
              );
              return;
            }

            bool isFst = instr.endsWith("-fst");
            bool isLst = false;

            if (isFst) {
              instr = instr.substring(0, instr.length - 4).trim();
            } else if (instr == "fst") {
              firstElement = DynAndInt(i, j);
              continue;
            } else if ((isLst = instr.endsWith("-lst"))) {
              instr = instr.substring(0, instr.length - 4).trim();
            } else if (instr == "lst") {
              lastElement = DynAndInt(i, j);
              continue;
            } else if (instr.contains("-fst")) {
              errorRoot.newChildren!.add(
                NodeStruct(
                  message: "'-fst' is not at the end of ${instr}",
                  id: i,
                  col: j,
                ),
              );
              return;
            }

            dynamic att = -1;
            dynamic col = j;
            final numK = int.tryParse(instr);
            if (numK != null) {
              if (numK < 1 || numK > rowCount - 1) {
                errorRoot.newChildren!.add(
                  NodeStruct(
                    message: "${instr} points to an invalid row ${numK}",
                    id: i,
                    col: j,
                  ),
                );
                return;
              }
              att = numK;
            } else if (names.containsKey(instr)) {
              att = names[instr]!.row;
            } else {
              att = "${table[0][j]}.$instr";
              col = rows;
              if (!att_to_col.containsKey(instr)) {
                att_to_col[instr] = [];
              }
              if (att_to_col[instr]!.contains(col) == false) {
                att_to_col[instr]!.add(col);
              }
            }
            mentions[i][j].push(att);
            rowToAtt[i]![att] = j;
            col_to_att[col].push(att);

            if (!attributes.containsKey(att)) {
              attributes[att] = {};
              if (isSprawl) {
                att_to_dist[att] = [];
              }
            }

            if (attributes[att]!.containsKey(i)) {
              attributes[att]![i] = j;
              if (isSprawl) {
                att_to_dist[att].add(i);
              }
            } else {
              children.add(NodeStruct(id: i, col: j));
            }

            if (isFst) {
              fstCat[i] = DynAndInt(att, j);
            } else if (isLst) {
              lstCat[i] = DynAndInt(att, j);
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
                          id: x.row,
                          col: x.col,
                        ))
                        .toList(),
                  ),
                  NodeStruct(
                    message: "path 2",
                    startOpen: true,
                    newChildren: findPath(attributes, i, k)
                        .map((x) => NodeStruct(
                          id: x.row,
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

    final Map<dynamic, NodeStruct> categories_children = new Map();
    final Map<dynamic, NodeStruct> sprawl_children = new Map();
    for (final MapEntry(key: col, value: attrs) in col_to_att.entries) {
      if (col == notUsed) continue;
      List<NodeStruct> cat_col_children = [];
      List<NodeStruct> sp_col_children = [];
      for (final attr in attrs) {
        cat_col_children.add(NodeStruct(id: attr));

        var rowsList = att_to_dist[attr];
        if (rowsList.length < 2) return;
        rowsList = rowsList.sort();
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
        sp_col_children.add(
          NodeStruct(
            id: attr,
            newChildren: distPairs.asMap().entries.map((entry) {
              final idx = entry.key;
              final d = entry.value;
              return NodeStruct(
                message:
                    "(${d}) ${getRowName(rowsList[idx])} - ${getRowName(rowsList[idx + 1])}",
                newChildren: [
                  NodeStruct(id: rowsList[idx]),
                  NodeStruct(id: rowsList[idx + 1]),
                ],
                dist: d,
              );
            }).toList()..sort((a, b) => a.id! - b.id!),
            minDist: minDist,
          ),
        );
      }
      categories_children[col] = new NodeStruct(
        col: col,
        newChildren: cat_col_children..sort((a, b) => a.id! - b.id!),
      );
      sprawl_children[col] = new NodeStruct(
        col: col,
        newChildren: sp_col_children..sort((a, b) => a.minDist! - b.minDist!),
      );
    }
    final List<NodeStruct> catego_children_list = [];
    final List<NodeStruct> sprawl_children_list = [];
    for (final (
          List<NodeStruct> children_list,
          Map<dynamic, NodeStruct> children,
        )
        in [
          (catego_children_list, categories_children),
          (sprawl_children_list, sprawl_children),
        ]) {
      for (int j = 0; j < colCount; j++) {
        final isSprawl = columnTypes[j] == ColumnType.sprawl.name;
        if (columnTypes[j] == ColumnType.attributes.name || isSprawl) {
          children_list.add(children[j]!);
        }
      }
      if (children.containsKey(rows)) {
        children_list.add(children[rows]!);
      }
    }
    categoriesRoot.newChildren = catego_children_list;
    distPairsRoot.newChildren = sprawl_children_list;

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

    final filtered_attributes = {};
    for (final cat in attributes.keys) {
      Map filtered = {};
      for (final MapEntry(key: k, value: v) in attributes[cat]!.entries) {
        if (urls[k].isNotEmpty) {
          filtered[k] = v;
        }
      }
      filtered_attributes[cat] = filtered;
      if (filtered.isEmpty) {
        filtered_attributes.remove(cat);
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

    for (int i = 1; i < rowCount; i++) {
      if (urls[i].isEmpty && !(attributes[colCount]!.containsKey(i))) {
        continue;
      }

      final row = table[i];
      for (int j = 0; j < row.length; j++) {
        if (columnTypes[j] == ColumnType.dependencies.name && row[j].isNotEmpty) {
          final cellList = row[j].split("; ");
          for (String instr in cellList) {
            if (instr.isNotEmpty) {
              final instrSplit = instr.split(".");
              if (
                instrSplit.length != depPattern[j].length - 1 &&
                depPattern[j].length > 1
              ) {
                errorRoot.newChildren!.add(NodeStruct(
                    message: "$instr does not match dependencies pattern ${depPattern[j]}",
                    id: i,
                    col: j,
                  ),
                );
                return;
              }

              if (depPattern[j].length > 1) {
                instr =
                  depPattern[j][0] +
                  instrSplit
                    .asMap().entries.map((entry) {
                      final idx = entry.key;
                      final split = entry.value;
                      return split + depPattern[j][idx + 1];
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
                      id: i,
                      col: j,
                    ),
                  );
                  return;
                }
                intervals = getIntervals(instr, i, j);
                if (errorRoot.newChildren!.isNotEmpty) {
                  return;
                }
              }

              final numbers = [];
              var name;
              var col;

              if (match.namedGroup('number') != null) {
                final number = int.parse(match.namedGroup('number')!);
                if (number == 0 || number > rowCount) {
                  errorRoot.newChildren!.add(
                    NodeStruct(message: "invalid number.", id: i, col: j),
                  );
                  return;
                }
                if (urls[number].isNotEmpty) {
                  numbers.add(number);
                }
                name = number;
              } else {
                name = match.namedGroup('name');
                if (!name) {
                  errorRoot.newChildren!.add(
                    NodeStruct(
                      message: "$instr does not match expected format",
                      id: i,
                      col: j,
                    ),
                  );
                  return;
                }
                if (names.containsKey(name)) {
                  numbers.add(names[name]!.row);
                } else {
                  if (match.namedGroup('column') != null) {
                    col = col_name_to_index[match.namedGroup('column')!];
                    if (!attributes[col]!.containsKey(name)) {
                      errorRoot.newChildren!.add(NodeStruct(
                          message: "attribute ${match.namedGroup('column')}.$name does not exist",
                          id: i,
                          col: j,
                        ),
                      );
                      return;
                    }
                  } else if (att_to_col.containsKey(name) && att_to_col[name]!.length > 1) {
                    List<NodeStruct> newChildren = [];
                    for (final col in att_to_col[name]!) {
                      final matchingAtts = attributes[name]!.keys.map((r) {
                        return NodeStruct(id: r, col: col);
                      }).toList();
                      newChildren.add(
                        NodeStruct(
                          col: j,
                          newChildren: matchingAtts,
                        ),
                      );
                    }
                    errorRoot.newChildren!.add(
                      NodeStruct(
                        message: "attribute \"$name\" is ambiguous",
                        id: i,
                        col: j,
                        newChildren: newChildren,
                      ),
                    );
                  }
                  for (final r in attributes[name]!.keys) {
                    numbers.add(r);
                  }
                }
              }

              if (attributes.containsKey(name)) {
                for (final r in attributes[name]!.keys) {
                  numbers.add(r);
                }
              } else if (match.namedGroup('name') != null) {
                if (!(names.containsKey(name))) {
                  errorRoot.newChildren!.add(
                    NodeStruct(
                      message: "attribute \"$name\" does not exist",
                      id: i,
                      col: j,
                    ),
                  );
                  return;
                }
                if (urls[names[name]!.row].isNotEmpty) {
                  numbers.add(names[name]);
                }
                if (attributes.containsKey(names[name])) {
                  for (final r in attributes[names[name]]!.keys) {
                    numbers.add(r);
                  }
                }
              }

              mentions[i][j] = numbers;
              final mappedNumbers = numbers.map((x) => newIndexes[x]).toList();
              var instruction = InstrStruct(
                isConstraint,
                match.namedGroup('any') != null,
                mappedNumbers,
                intervals,
              );
              if (instrTable[i].containsKey(instruction)) {
                errorRoot.newChildren!.add(
                  NodeStruct(
                    message: "duplicate instruction \"$instr\"",
                    id: i,
                    col: j,
                  ),
                );
              } else {
                instrTable[i][instruction] = j;
              }
            }
          }
        }
      }
    }

    toMentioners = {};
    for (var i = 1; i < rowCount; i++) {
      for (var j = 0; j < table[i].length; j++) {
        if (columnTypes[j] == ColumnType.dependencies.name) {
          mentions[i][j].forEach((n) {
            if (!toMentioners.containsKey(n)) {
              toMentioners[n] = {};
              final num = int.tryParse(n);
              if (num != null && !(names.containsKey(n)) && !(att_to_col.containsKey(n))) {
                att_to_col[n] = [notUsed];
                attributes["$notUsed.$n"] = {};
              }
            }
            if (!toMentioners[n]!.containsKey(i)) {
              toMentioners[n]![i] = j;
            }
          });
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

    if (attributes.containsKey(notUsed)) {
      final atts = attributes[notUsed]!.keys.toList();
      children = atts.asMap().entries.map((entry) {
        var a = entry.value;
        if (toMentioners[a]!.keys.length == 1) {
          return NodeStruct(
            message: "$a",
            id: toMentioners[a]!.keys.first,
            col: toMentioners[a]![toMentioners[a]!.keys.first],
          );
        } else {
          return NodeStruct(
            message: "$a",
            newChildren: toMentioners[a]!.keys.map(
              (k) => NodeStruct(id: k, col: toMentioners[a]![k]),
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
      } else if (role == ColumnType.path.name) {
        pathIndexes.add(index);
      }
    }
    mentions = List.generate(
      rowCount,
      (_) => List.generate(colCount, (_) => <String>[]),
    );
    for (int i = 0; i < rowCount; i++) {
      for (int j in {...nameIndexes, ...pathIndexes}) {
        var cellElements = table[i][j].split(";");
        for (int k = 0; k < cellElements.length; k++) {
          cellElements[k] = cellElements[k].trim();
          if (nameIndexes.contains(j)) {
            cellElements[k] = cellElements[k].toLowerCase();
          }
        }
        mentions[i][j] = cellElements.where((s) => s.isNotEmpty).toList();
      }
    }
    names = {};
    for (int i = 1; i < rowCount; i++) {
      for (int j in nameIndexes) {
        for (final name in mentions[i][j]) {
          if (int.tryParse(name) != null) {
            errorRoot.newChildren!.add(
              NodeStruct(message: "$name is not a valid name", id: i, col: j),
            );
            return;
          }

          final match = RegExp(r' -(\w+)$').firstMatch(name);
          if (name.contains("_") ||
              name.contains(":") ||
              name.contains("|") ||
              (match != null && !["fst", "lst"].contains(match.group(1)))) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "$name contains invalid characters (_ : | -)",
                id: i,
                col: j,
              ),
            );
          }

          final parenMatch = RegExp(r'(\(\d+\))$').firstMatch(name);
          if (parenMatch != null) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "$name contains invalid parentheses",
                id: i,
                col: j,
              ),
            );
          }

          if (["fst", "lst"].contains(name)) {
            errorRoot.newChildren!.add(
              NodeStruct(message: "$name is a reserved name", id: i, col: j),
            );
          }

          if (names.containsKey(name)) {
            errorRoot.newChildren!.add(
              NodeStruct(
                message: "name $name used two times",
                newChildren: [
                  NodeStruct(id: i, col: j),
                  NodeStruct(id: names[name]!.row, col: j),
                ],
              ),
            );
          }
          names[name] = Cell(row: i, col: j);
        }
      }
    }
    getCategories();
    saveSpreadsheet();
    notifyListeners();
  }

  void getCellElementsWithLinks() {
    mentionsRoot.newChildren = [];
    var row = selectedRow;
    var col = selectedCol;
    mentions[row][col].forEach((el) {
      var text = el;
      var nb = -1;
      if (el is int) {
        text = mentions[el][nameIndexes.first][0] ?? ""; // TODO: better handle row names
        nb = el;
      }

      mentionsRoot.newChildren!.add(
        NodeStruct(
          message: text,
          id: row,
          col: col,
          newChildren: [],
        ),
      );
    });
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

  void populateTree(NodeStruct root, container, {bool keep_prev = false}) {
    var stack = [root];
    while (stack.isNotEmpty) {
      var node = stack.removeLast();
      if (keep_prev) {
        node.newChildren = node.children;
      }
      if (node.newChildren == null) {
        if (node.id != null) {
          // if (typeof node.id === "number") {
          var obj = attributes[node.id];
          for (final entry in obj!.entries) {
            node.newChildren!.add(NodeStruct(
                id: entry.key,
                col: entry.value,
                newChildren: [],
              ),
            );
          }
        }
      }
      dfsDepthUpdate(node, 1, true);
      if (node.depth == 0) {
        var similarity = {};
        for (int j = 0; j < node.children.length; j++) {
          var obj = node.children[j];
          similarity[j] = [];
          if (obj.depth != 0) continue;
          for (int i = 0; i < node.newChildren!.length; i++) {
            var newObj = node.newChildren![i];
            if (newObj.depth != 0) continue;
            if (isEqualExcept(obj, newObj, ["newChildren", "depth"])) {
              newObj.depth = 0;
              newObj.children = obj.children;
              similarity[j] = [];
              break;
            }
            let sim = 0;
            if (obj.message !== undefined) {
              if (obj.message === newObj.message) sim++;
            }
            if (obj.att !== undefined) {
              if (obj.att === newObj.att) sim++;
            }
            if (obj.row !== undefined) {
              if (obj.row === newObj.row) sim++;
            }
            if (obj.col !== undefined) {
              if (obj.col === newObj.col) sim++;
            }
            if (
              JSON.stringify(obj.newChildren!) ===
              JSON.stringify(newObj.newChildren!)
            )
              sim++;
            if (obj.startOpen === newObj.startOpen) sim++;
            if (obj.hideIfEmpty === newObj.hideIfEmpty) sim++;
            if (sim > 0) similarity[j].push({i: i, sim: sim});
          }
          similarity[j].sort((a, b) => b.sim - a.sim);
        }
        let maxSim;
        while (maxSim !== -1) {
          maxSim = -1;
          for (let j = 0; j < node.children.length; j++) {
            var obj = node.children[j];
            for (var h = 0; h < similarity[j].length; h++) {
              var newObj = node.newChildren![similarity[j][h].i];
              if (!newObj.depth) continue;
              maxSim = Math.max(maxSim, similarity[j][h].sim);
            }
          }
          for (int j = 0; j < node.children.length; j++) {
            var obj = node.children[j];
            for (var h = 0; h < similarity[j].length; h++) {
              var newObj = node.newChildren![similarity[j][h].i];
              if (!newObj.depth) continue;
              if (similarity[j][h].sim === maxSim) {
                newObj.depth = 0;
                newObj.children = obj.children;
                break;
              }
            }
          }
        }
      }
      node.children = node.newChildren!;
      if (node.depth < 2) {
        for (final child in node.children) {
          stack.add(child);
        }
      }
    }
    // renderTree(root, container);
  }
}
