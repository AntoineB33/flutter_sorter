import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_telemetry.dart';
import '../services/sheet_store.dart';
import '../services/sheet_events.dart';

class SpreadsheetDataSource extends DataGridSource {
  final List<DataGridRow> _rows = [];
  final int colsCount;
  final String spreadsheetId;

  final _store = SheetStore();
  final _events = SheetEvents();

  Future<void>? _pendingNotify;
  final _pendingUpdates = <String, Map<String, dynamic>>{};
  Timer? _debounceTimer;

  // --- NEW: pull window tracking
  int _windowStart = 0;
  int _windowEnd = 0;

  // --- NEW: event sub
  StreamSubscription<CellEvent>? _eventSub;

  SpreadsheetDataSource({
    int rowsCount = 10,
    this.colsCount = 5,
    required this.spreadsheetId,
  }) {
    for (int i = 0; i < rowsCount; i++) {
      _rows.add(_createRow(i + 1));
    }
  }

  // ---------- WRITE PATH ----------
  void queueCellUpdate(int row, String col, String value) {
    final id = '${row}_$col';
    _pendingUpdates[id] = {
      'row': row,
      'column': col,
      'value': value,
      'timestamp': FieldValue.serverTimestamp(),
    };
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), _flushPending);
  }

  Future<void> _flushPending() async {
    if (_pendingUpdates.isEmpty) return;
    // Commit to Firestore (source of truth)
    final batch = FirebaseFirestore.instance.batch();
    final cellsRef = FirebaseFirestore.instance
        .collection('spreadsheets')
        .doc(spreadsheetId)
        .collection('cells');

    final toPublish = <Map<String, dynamic>>[];

    for (var entry in _pendingUpdates.entries) {
      final data = entry.value;
      batch.set(cellsRef.doc(entry.key), data, SetOptions(merge: true));
      FirestoreTelemetry().logWrite(data);
      toPublish.add(data);
    }

    await batch.commit();
    _pendingUpdates.clear();

    // Publish small “ping” events so online clients update instantly
    for (final d in toPublish) {
      await _events.publish(
        spreadsheetId: spreadsheetId,
        row: d['row'] as int,
        column: d['column'] as String,
        value: (d['value'] ?? '').toString(),
      );
    }
  }

  // ---------- READ / APPLY ----------
  DataGridRow _createRow(int rowNumber) {
    return DataGridRow(
      cells: [
        DataGridCell(columnName: 'RowHeader', value: rowNumber),
        ...List.generate(
          colsCount,
          (j) => DataGridCell(columnName: columnLetter(j), value: ''),
        ),
      ],
    );
  }

  static String columnLetter(int index) {
    String result = '';
    while (index >= 0) {
      result = String.fromCharCode(index % 26 + 65) + result;
      index = (index ~/ 26) - 1;
    }
    return result;
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow dataGridRow) {
    return DataGridRowAdapter(
      cells: dataGridRow.getCells().map((cell) {
        final isHeader = cell.columnName == 'RowHeader';
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          color: isHeader ? Colors.grey.shade100 : null,
          child: Text(cell.value.toString()),
        );
      }).toList(),
    );
  }

  @override
  Widget? buildEditWidget(
    DataGridRow dataGridRow,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
    CellSubmit submitCell,
  ) {
    if (column.columnName == 'RowHeader') return null;

    final oldValue = dataGridRow
        .getCells()
        .firstWhere((c) => c.columnName == column.columnName)
        .value
        .toString();

    final TextEditingController controller = TextEditingController(text: oldValue);

    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          setCellValue(dataGridRow, column.columnName, controller.text);
          submitCell();
        }
      },
      child: TextField(
        controller: controller,
        autofocus: true,
        onSubmitted: (newValue) {
          setCellValue(dataGridRow, column.columnName, newValue);
          submitCell();
        },
      ),
    );
  }

  bool setCellValue(DataGridRow dataGridRow, String columnName, dynamic value) {
    if (columnName == 'RowHeader') return false;

    final rowIndex = _rows.indexOf(dataGridRow);
    if (rowIndex == -1) return false;

    final oldCells = _rows[rowIndex].getCells();
    final cellIndex = oldCells.indexWhere((c) => c.columnName == columnName);
    if (cellIndex == -1) return false;

    final updatedCells = List<DataGridCell>.from(oldCells);
    updatedCells[cellIndex] = DataGridCell(columnName: columnName, value: value);

    _rows[rowIndex] = DataGridRow(cells: updatedCells);

    _pendingNotify ??= Future.microtask(() {
      notifyListeners();
      _pendingNotify = null;
    });

    // Persist + broadcast
    queueCellUpdate(rowIndex, columnName, value.toString());
    return true;
  }

  // ---------- PUBLIC API ----------
  void addRow() {
    _rows.add(_createRow(_rows.length + 1));
    notifyListeners();
  }

  void trimRows(int keepCount) {
    if (_rows.length > keepCount) {
      _rows.removeRange(keepCount, _rows.length);
      notifyListeners();
    }
  }

  int getLastNonEmptyRowIndex() {
    for (int i = _rows.length - 1; i >= 0; i--) {
      final hasContent = _rows[i].getCells().any(
        (c) => c.columnName != 'RowHeader' && (c.value?.toString().trim().isNotEmpty ?? false),
      );
      if (hasContent) return i;
    }
    return 0;
  }

  // ---------- NEW: cold start / resume / range pull ----------
  Future<void> refreshRange(int startRow, int endRow) async {
    _windowStart = startRow;
    _windowEnd = endRow;

    // Ensure enough rows exist locally
    while (_rows.length < endRow + 1) {
      _rows.add(_createRow(_rows.length + 1));
    }

    final map = await _store.getRange(
      spreadsheetId: spreadsheetId,
      startRow: startRow,
      endRow: endRow,
    );

    for (final entry in map.entries) {
      final parts = entry.key.split('_');
      final row = int.tryParse(parts[0]) ?? 0;
      final col = parts[1];
      _applyLocal(row, col, entry.value);
      FirestoreTelemetry().logRead({'row': row, 'column': col, 'value': entry.value});
    }

    notifyListeners();
  }

  // Apply an incoming change (from events or pulls)
  void _applyLocal(int rowIndex, String columnName, String value) {
    while (_rows.length <= rowIndex) {
      _rows.add(_createRow(_rows.length + 1));
    }
    final oldCells = _rows[rowIndex].getCells();
    final cellIndex = oldCells.indexWhere((c) => c.columnName == columnName);
    if (cellIndex == -1) return;

    final updatedCells = List<DataGridCell>.from(oldCells);
    updatedCells[cellIndex] = DataGridCell(columnName: columnName, value: value);
    _rows[rowIndex] = DataGridRow(cells: updatedCells);
  }

  // ---------- NEW: subscribe/unsubscribe to lightweight events ----------
  void startEventSubscription() {
    _eventSub?.cancel();
    _eventSub = _events.subscribe(spreadsheetId: spreadsheetId).listen((evt) {
      // Only apply if inside the current window; otherwise ignore (next pull will catch it)
      if (evt.row >= _windowStart && evt.row <= _windowEnd) {
        _applyLocal(evt.row, evt.column, evt.value);
        notifyListeners();
      }
    });
  }

  void stopEventSubscription() {
    _eventSub?.cancel();
    _eventSub = null;
  }
}
