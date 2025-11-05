import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

void main() {
  runApp(const SpreadsheetApp());
}

class SpreadsheetApp extends StatelessWidget {
  const SpreadsheetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Spreadsheet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SpreadsheetPage(),
    );
  }
}

class SpreadsheetPage extends StatefulWidget {
  const SpreadsheetPage({super.key});

  @override
  State<SpreadsheetPage> createState() => _SpreadsheetPageState();
}

class _SpreadsheetPageState extends State<SpreadsheetPage> {
  late SpreadsheetDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = SpreadsheetDataSource();
  }

  Future<void> _exportToExcel() async {
    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];

    // Skip row header (column 0)
    for (int r = 0; r < _dataSource.rows.length; r++) {
      final row = _dataSource.rows[r].getCells();
      for (int c = 1; c < row.length; c++) {
        sheet.getRangeByIndex(r + 1, c).setText(row[c].value.toString());
      }
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/spreadsheet.xlsx';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    await OpenFile.open(path);
  }

  @override
  Widget build(BuildContext context) {
    final columns = [
      // Row header column
      GridColumn(
        columnName: 'RowHeader',
        width: 60,
        label: Container(
          alignment: Alignment.center,
          color: Colors.grey.shade200,
          child: const Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      // A, B, C, D, E columns
      for (int i = 0; i < 5; i++)
        GridColumn(
          columnName: columnLetter(i),
          label: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey.shade200,
            child: Text(
              columnLetter(i),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Spreadsheet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _exportToExcel,
          )
        ],
      ),
      body: SfDataGrid(
        source: _dataSource,
        allowEditing: true,
        selectionMode: SelectionMode.single,
        navigationMode: GridNavigationMode.cell,
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        columnWidthMode: ColumnWidthMode.fill,
        columns: columns,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _dataSource.addRow();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Converts 0 → A, 1 → B, … 25 → Z, 26 → AA, etc.
  String columnLetter(int index) {
    String result = '';
    while (index >= 0) {
      result = String.fromCharCode(index % 26 + 65) + result;
      index = (index ~/ 26) - 1;
    }
    return result;
  }
}

class SpreadsheetDataSource extends DataGridSource {
  final List<DataGridRow> _rows = [];

  SpreadsheetDataSource() {
    for (int i = 0; i < 10; i++) {
      _rows.add(_createRow(i + 1));
    }
  }

  void addRow() {
    _rows.add(_createRow(_rows.length + 1));
    notifyListeners();
  }

  DataGridRow _createRow(int rowNumber) {
    return DataGridRow(cells: [
      DataGridCell(columnName: 'RowHeader', value: rowNumber),
      ...List.generate(5, (j) => DataGridCell(columnName: columnLetter(j), value: '')),
    ]);
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
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
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
      DataGridRow row, RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    if (column.columnName == 'RowHeader') return null; // No editing for row headers

    final oldValue = row
        .getCells()
        .firstWhere((c) => c.columnName == column.columnName)
        .value
        .toString();

    final TextEditingController controller = TextEditingController(text: oldValue);

    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          setCellValue(row, column.columnName, controller.text);
          submitCell();
        }
      },
      child: TextField(
        controller: controller,
        autofocus: true,
        onSubmitted: (newValue) {
          setCellValue(row, column.columnName, newValue);
          submitCell();
        },
      ),
    );
  }

  @override
  bool setCellValue(DataGridRow row, String columnName, dynamic value) {
    if (columnName == 'RowHeader') return false;

    final rowIndex = _rows.indexOf(row);
    if (rowIndex == -1) return false;

    final oldCells = _rows[rowIndex].getCells();
    final cellIndex = oldCells.indexWhere((c) => c.columnName == columnName);
    if (cellIndex == -1) return false;

    final updatedCells = List<DataGridCell>.from(oldCells);
    updatedCells[cellIndex] = DataGridCell(columnName: columnName, value: value);

    _rows[rowIndex] = DataGridRow(cells: updatedCells);
    notifyListeners();
    return true;
  }
}
