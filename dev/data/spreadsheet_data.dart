import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/node_struct.dart';

class SpreadsheetData {
  int _rows;
  int _cols;
  late List<List<String>> _cells;
  Map<int, String> _columnTypes = {}; // NEW: type mapping
  NodeStruct? errorRoot;
  NodeStruct? warningRoot;
  final NodeStruct mentionsRoot = NodeStruct(message: 'Current selection');
  final NodeStruct searchRoot = NodeStruct(message: 'Search results');
  final NodeStruct categoriesRoot = NodeStruct(message: 'Categories');
  final NodeStruct distPairsRoot = NodeStruct(message: 'Distance Pairs');

  SpreadsheetData({int initialRows = 20, int initialCols = 10})
      : _rows = initialRows,
        _cols = initialCols {
    _cells = List.generate(
      _rows,
      (_) => List.generate(_cols, (_) => ''),
    );
  }

  int get rowCount => _rows;
  int get colCount => _cols;

  Map<int, String> get columnTypes => _columnTypes;

  void setColumnType(int col, String type) {
    if (col >= 1 && col <= _cols) {
      _columnTypes[col] = type;
    }
  }

  String getColumnType(int col) => _columnTypes[col] ?? 'Default';

  void _ensureSize(int row, int col) {
    if (row > _rows) {
      final rowsToAdd = row - _rows;
      for (int i = 0; i < rowsToAdd; i++) {
        _cells.add(List.generate(_cols, (_) => ''));
      }
      _rows = row;
    }
    if (col > _cols) {
      final colsToAdd = col - _cols;
      for (final rowList in _cells) {
        rowList.addAll(List.generate(colsToAdd, (_) => ''));
      }
      _cols = col;
    }
  }

  String getCell(int row, int col) {
    if (row < 1 || col < 1 || row > _rows || col > _cols) return '';
    return _cells[row - 1][col - 1];
  }

  void setCell(int row, int col, String value) {
    _ensureSize(row, col);
    _cells[row - 1][col - 1] = value;
  }

  void addRow() {
    _rows += 1;
    _cells.add(List.generate(_cols, (_) => ''));
  }

  void addColumn() {
    _cols += 1;
    for (final row in _cells) {
      row.add('');
    }
  }

  void clearAll() {
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        _cells[r][c] = '';
      }
    }
  }

  /// Returns Excel-style labels: A, B, ..., Z, AA, AB, ...
  String columnLabel(int col) {
    int n = col;
    final buffer = StringBuffer();
    while (n > 0) {
      n--;
      final charCode = 'A'.codeUnitAt(0) + (n % 26);
      buffer.writeCharCode(charCode);
      n ~/= 26;
    }
    return buffer.toString().split('').reversed.join();
  }

  /// Converts the spreadsheet (including types) to a JSON string.
  String toJsonString() {
    return jsonEncode({
      'rows': _rows,
      'cols': _cols,
      'cells': _cells,
      // Convert int keys to strings for JSON compatibility
      'columnTypes': _columnTypes.map((k, v) => MapEntry(k.toString(), v)),
    });
  }

  /// Reconstructs a spreadsheet from JSON.
  static SpreadsheetData fromJsonString(String jsonString) {
    final map = jsonDecode(jsonString);
    final data = SpreadsheetData(
      initialRows: map['rows'],
      initialCols: map['cols'],
    );
    final cells = (map['cells'] as List)
        .map<List<String>>((row) => List<String>.from(row))
        .toList();
    data._cells = cells;

    // Restore column types safely
    if (map['columnTypes'] != null) {
      final colTypeMap = Map<String, dynamic>.from(map['columnTypes']);
      data._columnTypes = colTypeMap.map(
        (k, v) => MapEntry(int.tryParse(k) ?? 0, v.toString()),
      )..removeWhere((key, value) => key == 0); // remove invalid key if any
    }

    return data;
  }

  /// Saves spreadsheet to local storage.
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('spreadsheet_data', toJsonString());
  }

  /// Loads spreadsheet from local storage, or returns null if none saved.
  static Future<SpreadsheetData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('spreadsheet_data');
    if (jsonString == null) return null;
    return fromJsonString(jsonString);
  }

  void getCellElementsWithLinks() {
    mentionsRoot.newChildren = [];

    final int row = result.selectedRow;
    final int col = result.selectedCol;

    for (var el in result.mentions[row][col]) {
      String text = el.toString();
      int nb = -1;

      if (el is int) {
        text = result.mentions[el][nameIndex][0] ?? "";
        nb = el;
      }

      result.mentionsRoot.newChildren.add(
        NodeStruct(
          message: text,
          id: row,
          col: col,
          newChildren: [],
        ),
      );
    }
  }

  void getEverything(result, {bool debugEnabled = false, bool initialLoad = false}) {
    result.errorRoot = [];
    result.warningRoot = [];
    var lock = LockService.getScriptLock();
    let wasEdited;
    let selections = [];
    try {
      lock.waitLock(30000);
      const cache = CacheService.getScriptCache();
      let status = cache.get("status");
      const cachedStatus = JSON.parse(status || "{}");
      selections = cachedStatus.selections || [];
      currentSelection =
        selections.length > 0
          ? selections[selections.length - 1]
          : { row: 0, col: 0 };
      result.selectChanged =
        currentSelection.row !== result.selectedRow ||
        currentSelection.col !== result.selectedCol;
      result.selectedRow = currentSelection.row;
      result.selectedCol = currentSelection.col;
      wasEdited = cachedStatus === null ? cachedStatus.edited : true;
      if (wasEdited) {
        cache.put(
          "status",
          JSON.stringify({ selections: [currentSelection], edited: false }),
        );
      }
    } catch (e) {
      console.error("Failed to acquire lock or process cache:", e);
      throw e;
    } finally {
      lock.releaseLock();
    }
    result.wasEdited =
      initialLoad || result.newSelectedRoleList.length > 0 || wasEdited;
    if (result.wasEdited) {
      let property;
      if (initialLoad || result.newSelectedRoleList.length > 0) {
        property = PropertiesService.getScriptProperties();
      }
      if (initialLoad) {
        result.roles = JSON.parse(property.getProperty("roles") || "[]");
        result.rolesOptions = Object.values(Roles);
      }
      if (result.newSelectedRoleList.length > 0) {
        let selId = 0;
        const origRoles = result.roles.slice();
        for (const newSelectedRole of result.newSelectedRoleList) {
          while (
            selId < selections.lenght &&
            selections[selId].date < newSelectedRole.date
          ) {
            selId++;
          }
          const col = selections.length > 0 ? selections[selId - 1].col : 0;
          if (col >= result.roles.length) {
            result.roles = result.roles.concat(
              Array(col - result.roles.length + 1).fill(result.rolesOptions[0]),
            );
          } else {
            for (
              let i = result.roles.length - 1;
              i > result.table[0].length - 1;
              i--
            ) {
              if (result.roles[i] === result.rolesOptions[0]) {
                result.roles.pop();
              } else {
                break;
              }
            }
          }
          if (col < result.roles.length) {
            result.roles[col] = newSelectedRole.value;
          }
        }
        result.newSelectedRoleList = [];
        if (JSON.stringify(origRoles) !== JSON.stringify(result.roles)) {
          property.setProperty("roles", JSON.stringify(result.roles));
        }
      }
      const sheet = SpreadsheetApp.getActiveSheet();
      result.table = sheet.getDataRange().getValues();
      result.name = sheet.getName();
      if (result.name === "s") {
        errorRoot.push(
          `Error: Invalid role '${result.name}' - 's' is a reserved name`,
        );
        return;
      }
      result.table.forEach((row) =>
        row.forEach((cell, idx) => {
          if (typeof cell !== "string") {
            row[idx] = String(cell);
          }
          row[idx] = row[idx].trim().toLowerCase();
        }),
      );
      normalize(result);
      const errorRoot = result.errorRoot;
      if (errorRoot.length > 0) {
        return result;
      }
      const table = result.table;
      const roles = result.roles;
      alph = generateUniqueStrings(Math.max(roles.length, table.length));
      result.nameIndexes = new Set();
      const pathIndexes = new Set();
      roles.forEach((role, index) => {
        if (role === Roles.NAMES) {
          result.nameIndexes.add(index);
        } else if (role === Roles.PATH) {
          pathIndexes.add(index);
        }
      });
      const nameIndex = result.nameIndexes.values().next().value;
      const pathIndex = pathIndexes.values().next().value;
      result.mentions = Array.from({ length: table.length }, () =>
        Array.from({ length: table[0].length }, () => []),
      );
      for (let i = 0; i < table.length; i++) {
        for (let j of [nameIndex, pathIndex]) {
          let cell_elements = table[i][j].split(";");
          for (let k = 0; k < cell_elements.length; k++) {
            cell_elements[k] = cell_elements[k].trim();
            if (j === nameIndex) {
              cell_elements[k] = cell_elements[k].toLowerCase();
            }
          }
          result.mentions[i][j] = cell_elements.filter((s) => s);
        }
      }
      for (let i = 1; i < table.length; i++) {
        for (const name of result.mentions[i][nameIndex]) {
          if (!isNaN(parseInt(name))) {
            errorRoot.push(
              `Error in row ${i}, column ${alph[nameIndex]}: ${JSON.stringify(name)} is not a valid name`,
            );
            return result;
          }

          const match = name.match(/ -(\w+)$/);
          if (
            name.includes("_") ||
            name.includes(":") ||
            name.includes("|") ||
            (match && !["fst", "lst"].includes(match[1]))
          ) {
            errorRoot.push(
              `Error in row ${i}, column ${alph[nameIndex]}: ${JSON.stringify(name)} contains invalid characters (_ : | -)`,
            );
          }

          const parenMatch = name.match(/(\(\d+\))$/);
          if (parenMatch) {
            errorRoot.push(
              `Error in row ${i}, column ${alph[nameIndex]}: ${JSON.stringify(name)} contains invalid parentheses`,
            );
          }

          if (["fst", "lst"].includes(name)) {
            errorRoot.push(
              `Error in row ${i}, column ${alph[nameIndex]}: ${JSON.stringify(name)} is a reserved name`,
            );
          }

          if (name in result.names) {
            errorRoot.push(
              `Error in row ${i}, column ${alph[nameIndex]}: name ${JSON.stringify(name)} already exists in row ${result.names[name]}`,
            );
          }
          result.names[name] = i;
        }
      }
      result.table = table;
      result.nameIndex = nameIndex;
      result.pathIndex = pathIndex;
      getCategories(result);
    }
    if (debugEnabled) {
      debugToDoc(JSON.stringify(result));
    }
    result.alph = alph;
    return result;
  }
}
