import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:math' as math;
import '../data/spreadsheet_data_source.dart';
import '../widgets/draggable_floating_panel.dart';
import 'dart:async';

class SpreadsheetPage extends StatefulWidget {
  const SpreadsheetPage({super.key});

  @override
  State<SpreadsheetPage> createState() => _SpreadsheetPageState();
}

class _SpreadsheetPageState extends State<SpreadsheetPage> with WidgetsBindingObserver {
  SpreadsheetDataSource? _dataSource;
  final int _columnCount = 20;
  int _minRowCount = 0;
  final ScrollController _verticalController = ScrollController();
  bool _isAdding = false;
  final String _spreadsheetId = 'default_spreadsheet'; // Change this to support multiple spreadsheets

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _verticalController.addListener(_onScroll);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _verticalController.dispose();
    _dataSource?.stopEventSubscription();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _dataSource != null) {
      // Pull fresh data for the currently visible window on refocus
      _dataSource!.refreshRange(startRowIndex, endRowIndex);
    }
  }

  // _onScroll: replace the old updateListenerRange calls with refreshRange debounced
  Timer? _rangeDebounce;

  void _onScroll() {
    if (_dataSource == null) return;

    _rangeDebounce?.cancel();
    _rangeDebounce = Timer(const Duration(milliseconds: 250), () {
      _dataSource!.refreshRange(startRowIndex, endRowIndex);
    });
    
    final maxScroll = _verticalController.position.maxScrollExtent;
    final current = _verticalController.offset;

    // Add rows when nearing the bottom
    if (!_isAdding && current >= maxScroll - 50) {
      _isAdding = true;
      setState(() => _dataSource!.addRow());
      Future.delayed(const Duration(milliseconds: 100), () {
        _isAdding = false;
        if (_verticalController.hasClients) {
          final newMaxScroll = _verticalController.position.maxScrollExtent;
          final newCurrent = _verticalController.offset;
          if (newCurrent >= newMaxScroll - 10) {
            _onScroll();
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

    if (_dataSource != null) {
      final start = startRowIndex;
      final end = endRowIndex;
      // Debounce frequent scroll changes — only pull after scrolling stops briefly
      _rangeDebounce?.cancel();
      _rangeDebounce = Timer(const Duration(milliseconds: 250), () {
        _dataSource!.refreshRange(start, end);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Synced Spreadsheet')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final visibleRowCount = (constraints.maxHeight / 49).floor();
          _minRowCount = visibleRowCount;

          _dataSource ??= SpreadsheetDataSource(
            rowsCount: _minRowCount,
            colsCount: _columnCount,
            spreadsheetId: _spreadsheetId,
          );

          // Pull initial window and start event sub once
          _dataSource!.refreshRange(0, _minRowCount + 20);
          _dataSource!.startEventSubscription();

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
                  onQueryRowHeight: (details) => 49.0,
                  columns: [
                    GridColumn(
                      columnName: 'RowHeader',
                      width: 60,
                      label: Container(
                        alignment: Alignment.center,
                        color: Colors.grey.shade200,
                        child: const Text(
                          '#',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
    if (_dataSource == null) return;

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

  int get startRowIndex {
    final offset = _verticalController.offset;
    const rowHeight = 49.0;
    return (offset / rowHeight).floor();
  }

  int get endRowIndex {
    const rowHeight = 49.0;
    final visibleCount = (MediaQuery.of(context).size.height / rowHeight).ceil();
    return startRowIndex + visibleCount + 10; // add buffer
  }
}