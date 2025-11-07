import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_telemetry.dart';


class SpreadsheetDataSource extends DataGridSource {
  final List<DataGridRow> _rows = [];
  final int colsCount;
  final String spreadsheetId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void>? _pendingNotify;

  final _pendingUpdates = <String, Map<String, dynamic>>{};
  Timer? _debounceTimer;

  void queueCellUpdate(int row, String col, String value) {
    final id = '${row}_$col';
    _pendingUpdates[id] = {
      'row': row,
      'column': col,
      'value': value,
      'timestamp': FieldValue.serverTimestamp(),
    };
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), _flushPending);
  }

  Future<void> _flushPending() async {
    if (_pendingUpdates.isEmpty) return;
    final batch = _firestore.batch();
    final cellsRef = _firestore.collection('spreadsheets').doc(spreadsheetId).collection('cells');

    for (var entry in _pendingUpdates.entries) {
      final id = entry.key;
      final data = entry.value;
      batch.set(cellsRef.doc(id), data);
      FirestoreTelemetry().logWrite(data); // ✅ log write
    }

    await batch.commit();
    _pendingUpdates.clear();
  }



  SpreadsheetDataSource({
    int rowsCount = 10,
    this.colsCount = 5,
    required this.spreadsheetId,
  }) {
    for (int i = 0; i < rowsCount; i++) {
      _rows.add(_createRow(i + 1));
    }
  }

  void _updateCellFromFirebase(int rowIndex, String columnName, String value) {
    // Ensure we have enough rows
    while (_rows.length <= rowIndex) {
      _rows.add(_createRow(_rows.length + 1));
    }

    final oldCells = _rows[rowIndex].getCells();
    final cellIndex = oldCells.indexWhere((c) => c.columnName == columnName);
    
    if (cellIndex != -1) {
      final updatedCells = List<DataGridCell>.from(oldCells);
      updatedCells[cellIndex] = DataGridCell(
        columnName: columnName,
        value: value,
      );
      _rows[rowIndex] = DataGridRow(cells: updatedCells);
      notifyListeners();
    }
  }

  void addRow() {
    _rows.add(_createRow(_rows.length + 1));
    notifyListeners();
  }

  void removeLastRow() {
    if (_rows.isNotEmpty) {
      _rows.removeLast();
      notifyListeners();
    }
  }

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

    final TextEditingController controller = TextEditingController(
      text: oldValue,
    );

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
    updatedCells[cellIndex] = DataGridCell(
      columnName: columnName,
      value: value,
    );

    _rows[rowIndex] = DataGridRow(cells: updatedCells);
    
    _pendingNotify ??= Future.microtask(() {
      notifyListeners();
      _pendingNotify = null;
    });
    
    // Sync to Firebase
    queueCellUpdate(rowIndex, columnName, value.toString());

    return true;
  }

  int getLastNonEmptyRowIndex() {
    for (int i = _rows.length - 1; i >= 0; i--) {
      final hasContent = _rows[i].getCells().any(
        (c) =>
            c.columnName != 'RowHeader' &&
            (c.value?.toString().trim().isNotEmpty ?? false),
      );
      if (hasContent) return i;
    }
    return 0;
  }

  void trimRows(int keepCount) {
    if (_rows.length > keepCount) {
      _rows.removeRange(keepCount, _rows.length);
      notifyListeners();
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _rangeSubscription;

  void updateListenerRange(int startRow, int endRow) {
    _rangeSubscription?.cancel();
    _rangeSubscription = _firestore
        .collection('spreadsheets')
        .doc(spreadsheetId)
        .collection('cells')
        .where('row', isGreaterThanOrEqualTo: startRow)
        .where('row', isLessThanOrEqualTo: endRow)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        final data = change.doc.data();
        if (data != null) {
          FirestoreTelemetry().logRead(data); // ✅ log read
          _updateCellFromFirebase(
            data['row'] as int,
            data['column'] as String,
            data['value'] as String,
          );
        }
      }
    });

  }
}