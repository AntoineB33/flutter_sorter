import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:math' as math;

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
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
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
  SpreadsheetDataSource? _dataSource;
  final int _columnCount = 20;
  int _minRowCount = 0;
  final ScrollController _verticalController = ScrollController();
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _verticalController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_dataSource == null) return;

    final maxScroll = _verticalController.position.maxScrollExtent;
    final current = _verticalController.offset;

    // Add rows when nearing the bottom - check for exact bottom position too
    if (!_isAdding && current >= maxScroll - 50) {
      _isAdding = true;
      setState(() => _dataSource!.addRow());
      // Reduced delay and ensure we can add again quickly
      Future.delayed(const Duration(milliseconds: 100), () {
        _isAdding = false;
        // Check again immediately in case we're still at the bottom
        if (_verticalController.hasClients) {
          final newMaxScroll = _verticalController.position.maxScrollExtent;
          final newCurrent = _verticalController.offset;
          if (newCurrent >= newMaxScroll - 10) {
            _onScroll(); // Recursive check
          }
        }
      });
    }

    // Trim rows when scrolled up
    if (current < maxScroll - 200) {
      final lastUsedRow = _dataSource!.getLastNonEmptyRowIndex() + 1;
      final desiredRowCount = math.max(_minRowCount, lastUsedRow);

      if (_dataSource!.rows.length > desiredRowCount) {
        setState(() => _dataSource!.trimRows(desiredRowCount));
      }
    }
  }
  
  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Spreadsheet'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _exportToExcel),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final visibleRowCount = (constraints.maxHeight / 49).floor();
          _minRowCount = visibleRowCount;

          // Initialize data source if not yet done
          if (_dataSource == null) {
            _dataSource = SpreadsheetDataSource(
              rowsCount: _minRowCount,
              colsCount: _columnCount,
            );
          }

          return Stack(
            children: [
              ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(scrollbars: true),
                child: SfDataGrid(
                  source: _dataSource!,
                  allowEditing: true,
                  selectionMode: SelectionMode.single,
                  navigationMode: GridNavigationMode.cell,
                  gridLinesVisibility: GridLinesVisibility.both,
                  headerGridLinesVisibility: GridLinesVisibility.both,
                  columnWidthMode: ColumnWidthMode.none,
                  verticalScrollController: _verticalController,
                  columns: [
                    GridColumn(
                      columnName: 'RowHeader',
                      width: 60,
                      label: Container(
                        alignment: Alignment.center,
                        color: Colors.grey.shade200,
                        child: const Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    for (int i = 0; i < _columnCount; i++)
                      GridColumn(
                        columnName: columnLetter(i),
                        width: 120,
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
                  ],
                ),
              ),
              if (_dataSource != null)
                DraggableFloatingPanel(
                  onAddRow: () => setState(() => _dataSource!.addRow()),
                  onExport: _exportToExcel,
                ),
            ],
          );
        },
      ),
    );
  }
  
  Future<void> _exportToExcel() async {
    if (_dataSource == null) return; // Safety check

    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];

    for (int r = 0; r < _dataSource!.rows.length; r++) {
      final row = _dataSource!.rows[r].getCells();
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
  final int colsCount;

  SpreadsheetDataSource({int rowsCount = 10, this.colsCount = 5}) {
    for (int i = 0; i < rowsCount; i++) {
      _rows.add(_createRow(i + 1));
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
    DataGridRow row,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
    CellSubmit submitCell,
  ) {
    if (column.columnName == 'RowHeader') return null;

    final oldValue = row
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
    updatedCells[cellIndex] = DataGridCell(
      columnName: columnName,
      value: value,
    );

    _rows[rowIndex] = DataGridRow(cells: updatedCells);
    notifyListeners();
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
}

class DraggableFloatingPanel extends StatefulWidget {
  final VoidCallback onAddRow;
  final VoidCallback onExport;

  const DraggableFloatingPanel({
    super.key,
    required this.onAddRow,
    required this.onExport,
  });

  @override
  State<DraggableFloatingPanel> createState() => _DraggableFloatingPanelState();
}

class _DraggableFloatingPanelState extends State<DraggableFloatingPanel> {
  Offset position = const Offset(20, 80);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: buildPanel(),
        childWhenDragging: const SizedBox.shrink(),
        onDragEnd: (details) {
          setState(() {
            position = details.offset;
          });
        },
        child: buildPanel(),
      ),
    );
  }

  Widget buildPanel() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: widget.onAddRow,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Row'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: widget.onExport,
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
