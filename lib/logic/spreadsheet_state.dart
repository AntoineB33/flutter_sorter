import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:convert';
import '../data/models/cell.dart';
import '../data/models/node_struct.dart';
import '../data/models/column_type.dart';

class InstrStruct {
  bool isConstraint;
  bool any;
  List<int> numbers;
  List<List<int>> intervals;
  List<int> path;
  bool added;

  InstrStruct(
    this.isConstraint,
    this.any,
    this.numbers,
    this.intervals, [
    this.path = const [],
    this.added = false,
  ]);

  // equals(other) {
  //   if (!(other instanceof InstrStruct)) {
  //     return false;
  //   }
  //   return (
  //     this.isConstraint === other.isConstraint &&
  //     this.any === other.any &&
  //     JSON.stringify([...this.numbers].sort()) ===
  //       JSON.stringify([...other.numbers].sort()) &&
  //     JSON.stringify([...this.intervals].sort()) ===
  //       JSON.stringify([...other.intervals].sort())
  //   );
  // }

  // // For use in Set operations and comparisons
  // toString() {
  //   return JSON.stringify({
  //     isConstraint: this.isConstraint,
  //     any: this.any,
  //     numbers: [...this.numbers].sort(),
  //     intervals: [...this.intervals].sort(),
  //   });
  // }
}

class SpreadsheetState extends ChangeNotifier {
  static const PATTERN_DISTANCE =
    r'^(?<prefix>as far as possible from )(?<any>any)?((?<number>\d+)|(((?<column>.+)\.)?(?<name>.+)))$/';
  static const PATTERN_AREAS =
    r'^(?<prefix>.*\|)(?<any>any)?((?<number>\d+)|(((?<column>.+)\.)?(?<name>.+)))(?<suffix>\|.*)$/';
  static const rows = "rows";
  static const notUsed = "notUsed";
  String spreadsheetName = "";
  Map<int, String> columnTypes = {};
  final NodeStruct errorRoot = NodeStruct(message: 'Error Log');
  final NodeStruct warningRoot = NodeStruct(message: 'Warning Log');
  final NodeStruct mentionsRoot = NodeStruct(message: 'Current selection');
  final NodeStruct searchRoot = NodeStruct(message: 'Search results');
  final NodeStruct categoriesRoot = NodeStruct(message: 'Categories');
  final NodeStruct distPairsRoot = NodeStruct(message: 'Distance Pairs');
  late List<List<String>> table;

  /// 2D table of attribute identifiers (row index or name)
  /// mentioned in each cell.
  List<List<dynamic>> mentions = [];
  Map<String, Cell> names = {};
  var att_to_col;
  var rolesOptions;
  var newSelectedRoleList;
  List<int> nameIndexes = [];
  List<int> pathIndexes = [];
  var selectedRow;
  var selectedCol;
  var wasEdited;
  /// Maps attribute identifiers (row index or name)
  /// to a map of mentioners (row index) to the column index,
  /// in this direction so it is easy to diffuse characteristics to pointers.
  Map<dynamic, Map<int, int>> attributes = {};
  var instrTable;
  Cell? _selectionStart;
  Cell? _selectionEnd;

  Cell? get selectionStart => _selectionStart;
  Cell? get selectionEnd => _selectionEnd;

  bool get hasSelectionRange =>
      _selectionStart != null && _selectionEnd != null;

  SpreadsheetState({int rows = 30, int cols = 10}) {
    table = List.generate(rows, (r) => List.generate(cols, (c) => ''));
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
  int get colCount => table[0].length;

  String getColumnType(int col) =>
      columnTypes[col] ?? ColumnType.defaultType.name;

  // Select a cell
  void selectCell(int row, int col) {
    _selectionStart = Cell(row: row, col: col, value: table[row][col]);
    _selectionEnd = _selectionStart;
    notifyListeners();
  }

  void selectRange(int startRow, int startCol, int endRow, int endCol) {
    _selectionStart = Cell(
      row: startRow,
      col: startCol,
      value: table[startRow][startCol],
    );
    _selectionEnd = Cell(
      row: endRow,
      col: endCol,
      value: table[endRow][endCol],
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

    final data = {"table": table, "types": columnTypes};

    await prefs.setString("spreadsheet_$spreadsheetName", jsonEncode(data));
  }

  // ---- Load spreadsheet by name ----
  Future<void> loadSpreadsheet(String name) async {
    spreadsheetName = name.trim().toLowerCase();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      "last_opened_sheet",
      spreadsheetName,
    ); // <--- Add this

    final raw = prefs.getString("spreadsheet_$spreadsheetName");

    if (raw == null) {
      // No existing spreadsheet → create empty table
      table = List.generate(
        rowCount,
        (r) => List.generate(colCount, (c) => ''),
      );
      columnTypes = {};
      notifyListeners();
      return;
    }

    final decoded = jsonDecode(raw);

    // Restore table
    final storedGrid = (decoded["table"] as List)
        .map((row) => (row as List).map((v) => v.toString()).toList())
        .toList();

    for (int r = 0; r < storedGrid.length; r++) {
      for (int c = 0; c < storedGrid[r].length; c++) {
        table[r][c] = storedGrid[r][c];
      }
    }

    // Restore column types
    columnTypes = Map<int, String>.from(decoded["types"] ?? {});

    notifyListeners();
  }

  // ---- Call save on each update ----
  @override
  void updateCell(int row, int col, String newValue) {
    if (newValue.isNotEmpty || (row < rowCount && col < colCount)) {
      if (row >= rowCount) {
        final needed = row + 1 - rowCount;
        table.addAll(List.generate(needed, (_) => List.filled(colCount, '')));
      }
      if (col >= colCount) {
        final needed = col + 1 - colCount;
        for (var r = 0; r < rowCount; r++) {
          table[r].addAll(List.filled(needed, ''));
        }
      }
      table[row][col] = newValue;
    }
    if (newValue.isEmpty &&
        row == rowCount - 1 &&
        newValue != table[row][col]) {
      while (!table[row].any((cell) => cell.isNotEmpty) && row > 0) {
        table.removeLast();
        row--;
      }
    }
    getEverything();
    saveSpreadsheet(); // <-- Auto-save
    notifyListeners();
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
        .trimRight()
        .split('\n')
        .map((r) => r.split('\t'))
        .toList();

    for (int r = 0; r < rows.length; r++) {
      for (int c = 0; c < rows[r].length; c++) {
        final targetRow = startRow + r;
        final targetCol = startCol + c;

        // Prevent overflow
        if (targetRow >= rowCount || targetCol >= colCount) continue;

        updateCell(targetRow, targetCol, rows[r][c]);
      }
    }

    notifyListeners();
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

  @override
  void setColumnType(int col, String type) {
    columnTypes[col] = type;
    if (type == ColumnType.defaultType.name) {
      columnTypes.remove(col);
    }
    saveSpreadsheet(); // <-- Auto-save
    notifyListeners();
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
        rowValues.add(table[r][c]);
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

  List<Cell> findPath(int start, int end) {
    int row = start;
    List<Cell> path = [];
    while (true) {
      if (attributes[row]![end] != -1) {
        path.add(Cell(row: end, col: attributes[row]![end]!));
        return path.reversed.toList();
      }
      for (final child in attributes[row]!.keys) {
        if (attributes[child]!.containsKey(end)) {
          path.add(Cell(row: child, col: attributes[row]![child]!));
          row = child;
          break;
        }
      }
    }
  }

  void dfsIterative() {
    final visited = <int>{};
    final completed = <int>{};
    List<int> path = [];

    final List<NodeStruct> redundantRef = [];
    for (final start in attributes.keys) {
      if (visited.contains(start)) continue;
      final stack = [start];

      while (stack.length > 0) {
        final node = stack[stack.length - 1]; // peek
        if (path[path.length - 1] == node) {
          // Merge descendants from each child into current node
          Map nodeChildren = attributes[node] ?? {};

          // final directChildren = {...nodeChildren};
          for (final child in nodeChildren.keys) {
            Map<int, int>? childMap = attributes[child];
            if (childMap != null) {
              for (final grandChild in childMap.keys) {
                if (nodeChildren.containsKey(grandChild)) {
                  // if (directChildren.containsKey(grandChild)) continue;
                  var existingPath = findPath(node, grandChild);
                  var newPath = [...findPath(child, grandChild), Cell(row: node, col: attributes[child]![node]!)];
                  var longerPath = newPath;
                  var shorterPath = existingPath;
                  if (newPath.length < existingPath.length) {
                    longerPath = existingPath;
                    shorterPath = newPath;
                  }
                  List<NodeStruct> twoPaths = [];
                  var pathNodes = shorterPath
                    .map((k) => NodeStruct(id: k.row, col: k.col))
                    .toList();
                  twoPaths.add(
                    NodeStruct(
                      message: "shorter path",
                      newChildren: pathNodes,
                      startOpen: true,
                    ),
                  );

                  pathNodes = longerPath
                    .map((k) => NodeStruct(id: k.row, col: k.col))
                    .toList();
                  twoPaths.add(
                    NodeStruct(
                      message: "longer path",
                      newChildren: pathNodes,
                      startOpen: true,
                    ),
                  );

                  redundantRef.add(
                    NodeStruct(
                      message: "Multiple paths from ${grandChild} to ${node}",
                      newChildren: twoPaths,
                    ),
                  );
                } else {
                  nodeChildren[grandChild] = -1;
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

        final neighborsMap = attributes[node] ?? new Map();
        final neighbors = neighborsMap.keys.toList();

        for (int i = neighbors.length - 1; i >= 0; i--) {
          final child = neighbors[i];
          if (!visited.contains(child)) {
            stack.add(child);
          } else if (!completed.contains(child)) {
            final cycle = path.sublist(path.indexOf(child));
            final cyclePathNodes = cycle.map((k) => NodeStruct(id: k)).toList();
            errorRoot.newChildren.add(
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
      warningRoot.newChildren.add(
        NodeStruct(
          message: "redundant references found",
          newChildren: redundantRef,
        ),
      );
    }
  }

  String getRowName(row) {
    return mentions[row][nameIndexes.first][0] + " (${row})";
  }

  Map getIntervals(intervalStr, row, col) {
    // First, parse the positions of intervals
    const intervals = [[], []];
    const negPos = intervalStr.split("|");
    let positive = 0;

    for (const negPosPart of [negPos[0], negPos[2]]) {
      const parts = negPosPart.split("_");
      for (const part of parts) {
        if (!part) {
          intervals[positive].push([null, null]);
        } else if (part.includes(":")) {
          const [startStr, endStr] = part.split(":");

          let start = parseInt(startStr);
          if (isNaN(start)) {
            start = Infinity;
          }

          let end = parseInt(endStr);
          if (isNaN(end)) {
            end = Infinity;
          }

          if (!positive) {
            start = -start;
            end = -end;
          }
          intervals[positive].push([start, end]);
        } else {
          const num = parseInt(part);
          intervals[positive].push([num, num]);
        }
      }
      positive = 1;
    }

    // Now calculate underscore intervals
    const resultList = [];
    positive = 0;

    for (const negPosPart of intervals) {
      for (let i = 0; i < negPosPart.length - 1; i++) {
        let endOfCurrent = negPosPart[i][1];
        let startOfNext = negPosPart[i + 1][0];

        if (endOfCurrent === null) {
          if (!positive) {
            endOfCurrent = -Infinity;
          } else if (
            resultList.length > 0 &&
            resultList[resultList.length - 1][1] === -1
          ) {
            endOfCurrent = resultList[resultList.length - 1][0] - 1;
            resultList.pop();
          } else {
            endOfCurrent = 0;
          }
        }

        if (startOfNext === null) {
          if (!positive) {
            startOfNext = 0;
          } else {
            startOfNext = Infinity;
          }
        }

        if (startOfNext - endOfCurrent <= 1) {
          result.errorRoot.push(
            new NodeStruct({
              message: `Invalid interval: overlapping or adjacent intervals found.`,
              id: row,
              col: col,
            }),
          );
          return;
        }

        resultList.push([endOfCurrent + 1, startOfNext - 1]);
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
    if (children.length > 0) {
      warningRoot.newChildren.add(
        NodeStruct(message: "invalid URLs found", newChildren: children),
      );
    }

    if (errorRoot.newChildren.length > 0) {
      return;
    }

    Map col_to_att = {};
    Map att_to_dist = {};
    int firstElement = -1;
    int lastElement = -1;
    final Map fstCat = {};
    final Map lstCat = {};
    final colNb = colCount;
    final col_name_to_index = new Map();
    for (int j = 0; j < colNb; j++) {
      if ([
        ColumnType.attributes.name,
        ColumnType.sprawl.name,
      ].contains(columnTypes[j])) {
        col_to_att[j] = [];
      }
      if (col_name_to_index.containsKey(table[0][j])) {
        errorRoot.newChildren.add(
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
              errorRoot.newChildren.add(
                NodeStruct(message: "empty attribute name", id: i, col: j),
              );
              return;
            }

            bool isFst = instr.endsWith("-fst");
            bool isLst = false;

            if (isFst) {
              instr = instr.substring(0, instr.length - 4).trim();
            } else if (instr == "fst") {
              firstElement = i;
              continue;
            } else if ((isLst = instr.endsWith("-lst"))) {
              instr = instr.substring(0, instr.length - 4).trim();
            } else if (instr == "lst") {
              lastElement = i;
              continue;
            } else if (instr.contains("-fst")) {
              errorRoot.newChildren.add(
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
                errorRoot.newChildren.add(
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
            }
            mentions[i][j].push(att);
            col_to_att[col].push(att);

            if (!attributes.containsKey(att)) {
              attributes[att] = <int, int>{};
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
              fstCat[i] = att;
            } else if (isLst) {
              lstCat[i] = att;
            }
          }
        }
      }
    }
    if (children.length > 0) {
      warningRoot.newChildren.add(
        NodeStruct(
          message: "redundant attributes found",
          newChildren: children,
        ),
      );
    }

    dfsIterative();

    if (errorRoot.newChildren.length > 0) {
      return;
    }

    final urls = List.generate(
      rowCount,
      (i) => List.generate(
        pathIndexes.length,
        (j) => table[i][pathIndexes[j]],
      ),
    );

    var url_from = List.generate(rowCount, (i) => -1);
    for (int i = 1; i < rowCount; i++) {
      final row = table[i];
      if (urls[i].isNotEmpty && attributes.containsKey(i)) {
        for (final k in attributes[i]!.keys) {
          if (urls[k].isNotEmpty) {
            errorRoot.newChildren.add(
              NodeStruct(
                message:
                    "URL conflict",
                    startOpen: true,
                newChildren: [
                  NodeStruct(
                    message: "path 1",
                    startOpen: true,
                    newChildren: findPath(url_from[k], k)
                        .map((x) => NodeStruct(
                          id: x.row,
                          col: x.col,
                        ))
                        .toList(),
                  ),
                  NodeStruct(
                    message: "path 2",
                    startOpen: true,
                    newChildren: findPath(i, k)
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
            url_from[k] = i;
          }
        }
      }
    }

    final validRowIndexes = [];
    final isValid = List.filled(rowCount, false);
    final newIndexes = List.generate(rowCount, (i) => i);
    final toOldIndexes = [];
    final catRows = [];
    int newIndex = 0;
    for (int i = 1; i < rowCount; i++) {
      if (urls[i].isNotEmpty) {
        isValid[i] = true;
        validRowIndexes.add(i);
        newIndexes[i] = newIndex;
        newIndex++;
        toOldIndexes.add(i);
      } else {
        catRows.add(i);
      }
    }

    if (validRowIndexes.length == 0) {
      errorRoot.newChildren.add(
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
            if (!isValid[k]) {
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
      for (int j = 0; j < colNb; j++) {
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

    instrTable = List.generate(rowCount, (_) => []);

    for (final MapEntry(key: k, value: v) in fstCat.entries) {
      if (isValid[k]) {
        var t = v;
        while (fstCat.containsKey(t)) {
          t = fstCat[t]!;
        }
        for (final i in attributes[t]!.keys) {
          if (i != k) {
            instrTable[i].add(
              InstrStruct(
                true,
                false,
                [newIndexes[k]],
                [
                  [-double.infinity.toInt(), -1],
                ],
              ),
            );
          }
        }
      }
    }

    final filtered_attributes = {};
    for (final cat in attributes.keys) {
      Map filtered = {};
      for (final MapEntry(key: k, value: v) in attributes[cat]!.entries) {
        if (isValid[k]) {
          filtered[k] = v;
        }
      }
      filtered_attributes[cat] = filtered;
      if (filtered.isEmpty) {
        filtered_attributes.remove(cat);
      }
    }

    for (final MapEntry(key: k, value: v) in lstCat.entries) {
      if (isValid[k]) {
        var t = v;
        while (lstCat.containsKey(t)) {
          t = lstCat[t]!;
        }
        for (final i in attributes[t]!.keys) {
          if (i != k) {
            instrTable[i].add(
              InstrStruct(true, false, [newIndexes[k]], [[1, double.infinity.toInt()]]),
            );
          }
        }
      }
    }

    if (firstElement != -1) {
      for (final i in validRowIndexes) {
        if (i != firstElement) {
          instrTable[i].add(
            InstrStruct(
              true,
              false,
              [newIndexes[firstElement]],
              [[-double.infinity.toInt(), -1]],
            ),
          );
        }
      }
    }

    if (lastElement != -1) {
      for (final i in validRowIndexes) {
        if (i != lastElement) {
          instrTable[i].add(
            InstrStruct(
              true,
              false,
              [newIndexes[lastElement]],
              [[1, double.infinity.toInt()]],
            ),
          );
        }
      }
    }

    final depPattern = table[0].map((cell) => cell.split(".")).toList();

    for (int i = 1; i < rowCount; i++) {
      if (urls[i].isEmpty && !(attributes[colNb]!.containsKey(i))) {
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
                errorRoot.newChildren.add(NodeStruct(
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

              var match = RegExp(PATTERN_DISTANCE).hasMatch(instr);
              var intervals = [];
              var isConstraint = !match;

              if (isConstraint) {
                match = RegExp(PATTERN_AREAS).hasMatch(instr);
                if (!match) {
                  errorRoot.newChildren.add(NodeStruct(
                      message: "$instr does not match expected format",
                      id: i,
                      col: j,
                    ),
                  );
                  return;
                }
                intervals = getIntervals(result, instr, i, j);
                if (result.errorRoot.length > 0) {
                  return;
                }
              }

              final numbers = [];
              let name;
              let col;

              if (match.groups && match.groups.number) {
                final number = parseInt(match.groups.number);
                if (number === 0 || number > rowCount) {
                  errorRoot.push(
                    new NodeStruct({ message: "invalid number.", id: i, col: j }),
                  );
                  return;
                }
                if (table[number][pathIndex]) {
                  numbers.push(number);
                }
                name = number;
              } else {
                name = match.groups && match.groups.name;
                if (!name) {
                  errorRoot.push(
                    new NodeStruct({
                      message: "${JSON.stringify(instr)} does not match expected format",
                      id: i,
                      col: j,
                    }),
                  );
                  return;
                }
                if (name in names) {
                  numbers.push(names[name]!.row);
                } else {
                  if (match.groups.column) {
                    col = col_name_to_index[match.groups.column];
                    if (!(name in attributes[col])) {
                      errorRoot.push(
                        new NodeStruct({
                          message: "attribute ${match.groups.column}.${name} does not exist",
                          id: i,
                          col: j,
                        }),
                      );
                      return;
                    }
                  } else if (name in att_to_col) {
                    if (att_to_col[name].length > 1) {
                      final newChildren = [];
                      for (final col of att_to_col[name]) {
                        final mentio = Object.keys(attributes[col][name]).forEach(
                          (r) =>
                            new NodeStruct({
                              id: r,
                              col: col,
                            }),
                        );
                        newChildren.push(
                          new NodeStruct({
                            col: j,
                            newChildren: mentio,
                          }),
                        );
                      }
                      errorRoot.push(
                        new NodeStruct({
                          message: "attribute ${JSON.stringify(name)} is ambiguous",
                          id: i,
                          col: j,
                          newChildren,
                        }),
                      );
                    }
                  }
                  for (final r of Object.keys(attributes[col][name])) {
                    numbers.push(r);
                  }
                }
              }

              if (attributes.has(name)) {
                for (final r of attributes.get(name).keys()) {
                  numbers.push(parseInt(r));
                }
              } else if (match.groups && match.groups.name) {
                if (!(name in names)) {
                  errorRoot.push(
                    new NodeStruct({
                      message: "attribute ${JSON.stringify(name)} does not exist",
                      id: i,
                      col: j,
                    }),
                  );
                  return;
                }
                if (table[names[name]][pathIndex]) {
                  numbers.push(names[name]);
                }
                if (attributes.has(names[name])) {
                  for (final r of attributes.get(names[name]).keys()) {
                    numbers.push(parseInt(r));
                  }
                }
              }

              result.mentions[i][j] = numbers;
              final mappedNumbers = numbers.map((x) => newIndexes[x]);
              instrTable[i].push(
                new InstrStruct(
                  isConstraint,
                  match.groups && match.groups.any,
                  mappedNumbers,
                  intervals,
                ),
              );
            }
          }
        }
      }
    }

    final toMentioners = {};
    result.toMentioners = toMentioners;

    for (let i = 1; i < rowCount; i++) {
      for (let j = 0; j < table[i].length; j++) {
        if (columnTypes[j] === Roles.DEPENDENCIES) {
          result.mentions[i][j].forEach((n) => {
            if (!(n in toMentioners)) {
              toMentioners[n] = {};
              final num = parseInt(n);
              if (isNaN(num) && !(n in names) && !(n in att_to_col)) {
                att_to_col[n] = [notUsed];
                attributes.set("${notUsed}.${n}", {});
              }
            }
            if (!(i in toMentioners[n])) {
              toMentioners[n][i] = j;
            }
          });
        }
      }
    }

    final instrTableExt = instrTable.map((x) => [...x]);

    children = [];
    for (final i of validRowIndexes) {
      for (final att of Object.entries(row_to_att[i][rows])) {
        for (final x2 of instrTable[att]) {
          final x = JSON.parse(JSON.stringify(x2)); // deep copy
          x.added = true;
          if (
            !instrTable[i].some(
              (instr) => JSON.stringify(instr) === JSON.stringify(x),
            )
          ) {
            x.path = [...attributes[rows][att][i][1], ...x.path];
            instrTableExt[i].push(x);
          } else {
            final existingIndex = instrTable[i].findIndex(
              (instr) => JSON.stringify(instr) === JSON.stringify(x),
            );
            if (instrTable[i][existingIndex].path.length === 1) {
              final path = [...attributes[rows][att][i][1], ...x.path];
              final subchildren = path.map(
                (p) => new NodeStruct({ id: p, col: p }),
              );
              children.push(
                new NodeStruct({
                  message: JSON.stringify(x),
                  id: i,
                  col: j,
                  newChildren: subchildren,
                }),
              );
            }
          }
        }
      }
    }
    if (children.length > 0) {
      warningRoot.push(
        new NodeStruct({
          message: "redundant instructions found",
          newChildren: children,
        }),
      );
    }

    final instrTableInt = [];
    for (final i of validRowIndexes) {
      // Remove duplicates by converting to Set (approximate)
      final unique = [];
      final seen = new Set();
      for (final item of instrTableExt[i]) {
        final key = JSON.stringify(item);
        if (!seen.has(key)) {
          seen.add(key);
          unique.push(item);
        }
      }
      instrTableInt.push(unique);
    }

    // Detect cycles in instrTable
    function hasCycle(instrTable, visited, stack, node, after = true) {
      stack.push([toOldIndexes[node]]);
      visited.add(node);

      for (final neighbor of instrTable[node]) {
        if (
          neighbor.any ||
          !neighbor.isConstraint ||
          (after
            ? neighbor.intervals[0][0] !== -double.infinity.toInt() ||
              neighbor.intervals[0][1] !== -1
            : neighbor.intervals[neighbor.intervals.length - 1][0] !== 1 ||
              neighbor.intervals[neighbor.intervals.length - 1][1] !== double.infinity.toInt())
        ) {
          continue;
        }

        for (final target of neighbor.numbers) {
          stack[stack.length - 1].splice(1, double.infinity.toInt(), ...neighbor.path);
          if (!visited.has(target)) {
            if (hasCycle(instrTable, visited, stack, target, after)) {
              return true;
            }
          } else {
            final idx = stack.findIndex((k) => k[0] === toOldIndexes[target]);
            if (idx !== -1) {
              stack.splice(0, idx);
              stack.push([toOldIndexes[target]]);
              return true;
            }
          }
        }
      }
      stack.pop();
      return false;
    }

    for (let p = 0; p <= 1; p++) {
      final visited = new Set();
      final stack = [];
      for (let i = 0; i < instrTableInt.length; i++) {
        if (hasCycle(instrTableInt, visited, stack, i, p === 1)) {
          children = stack.map((path) => {
            if (path.length === 1) {
              return new NodeStruct({ id: path[0] });
            } else {
              return new NodeStruct({
                id: path[0],
                newChildren: path.slice(1).map((p) => new NodeStruct({ id: p })),
              });
            }
          });
          errorRoot.push(
            new NodeStruct({
              message: "Cycle detected in ${p === 1 ? "after" : "before"} constraints",
              newChildren: children,
            }),
          );
          return;
        }
      }
    }

    urls = validRowIndexes.map((i) => urls[i].url);

    saved.data = {
      elements: alph.slice(0, validRowIndexes.length),
      instructions: instrTableInt,
      urls: urls,
      toOldIndexes: toOldIndexes,
      catRows: catRows,
      attributesTable: row_to_att,
      columnTypes: columnTypes,
      depPattern: depPattern,
      pathIndex: pathIndex,
      attributes: attributes,
      newIndexes: newIndexes,
    };

    // Note: fstRow is not defined in the original code, assuming it should be firstElement
    if (firstElement != -1) {
      saved.musics = musics;
      saved.musicCol = music_col;
    }

    // TODO: solve sorting pb

    if (notUsed in attributes) {
      final atts = Object.keys(attributes[notUsed]);
      children = atts.map((a) => {
        if (Object.keys(toMentioners[a]).length == 1) {
          return new NodeStruct({
            message: a,
            rows: Object.keys(toMentioners[a])[0],
            col: toMentioners[a][Object.keys(toMentioners[a])[0]],
          });
        } else {
          return new NodeStruct({
            message: a,
            newChildren: Object.keys(toMentioners[a]).map(
              (k) => new NodeStruct({ id: k, col: toMentioners[a][k] }),
            ),
          });
        }
      });
      warningRoot.push(
        new NodeStruct({
          message: "unused attributes found",
          newChildren: children,
        }),
      );
    }
    return;
  }

  void getEverything() {
    errorRoot.newChildren.clear();
    warningRoot.newChildren.clear();
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
            errorRoot.newChildren.add(
              NodeStruct(message: "$name is not a valid name", id: i, col: j),
            );
            return;
          }

          final match = RegExp(r' -(\w+)$').firstMatch(name);
          if (name.contains("_") ||
              name.contains(":") ||
              name.contains("|") ||
              (match != null && !["fst", "lst"].contains(match.group(1)))) {
            errorRoot.newChildren.add(
              NodeStruct(
                message: "$name contains invalid characters (_ : | -)",
                id: i,
                col: j,
              ),
            );
          }

          final parenMatch = RegExp(r'(\(\d+\))$').firstMatch(name);
          if (parenMatch != null) {
            errorRoot.newChildren.add(
              NodeStruct(
                message: "$name contains invalid parentheses",
                id: i,
                col: j,
              ),
            );
          }

          if (["fst", "lst"].contains(name)) {
            errorRoot.newChildren.add(
              NodeStruct(message: "$name is a reserved name", id: i, col: j),
            );
          }

          if (names.containsKey(name)) {
            errorRoot.newChildren.add(
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
  }
}
