import 'package:flutter/material.dart';

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
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
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
  late final SpreadsheetData _data;
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _data = SpreadsheetData(initialRows: 20, initialCols: 10);
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Spreadsheet'),
        actions: [
          IconButton(
            tooltip: 'Clear all cells',
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _data.clearAll();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToolbar(context),
          const Divider(height: 1),
          Expanded(
            child: Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: Scrollbar(
                  controller: _verticalController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _verticalController,
                    scrollDirection: Axis.vertical,
                    child: _SpreadsheetView(
                      data: _data,
                      onCellTap: _editCell,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Row'),
            onPressed: () {
              setState(() {
                _data.addRow();
              });
            },
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Column'),
            onPressed: () {
              setState(() {
                _data.addColumn();
              });
            },
          ),
          const Spacer(),
          Text(
            'Rows: ${_data.rowCount}  |  Columns: ${_data.colCount}',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }

  Future<void> _editCell(int row, int col) async {
    final currentValue = _data.getCell(row, col);
    final controller = TextEditingController(text: currentValue);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${_data.columnLabel(col)}$row'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Cell value',
            ),
            onSubmitted: (value) {
              Navigator.of(context).pop(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _data.setCell(row, col, result);
      });
    }
  }
}

class _SpreadsheetView extends StatelessWidget {
  final SpreadsheetData data;
  final void Function(int row, int col) onCellTap;

  const _SpreadsheetView({
    required this.data,
    required this.onCellTap,
  });

  static const double cellWidth = 100;
  static const double cellHeight = 40;
  static const double headerHeight = 44;
  static const double headerWidth = 60;

  @override
  Widget build(BuildContext context) {
    final rows = data.rowCount;
    final cols = data.colCount;

    final tableRows = <TableRow>[];

    // Header row
    tableRows.add(
      TableRow(
        children: [
          _buildTopLeftHeader(context),
          for (int c = 1; c <= cols; c++) _buildColumnHeader(context, c),
        ],
      ),
    );

    // Data rows
    for (int r = 1; r <= rows; r++) {
      tableRows.add(
        TableRow(
          children: [
            _buildRowHeader(context, r),
            for (int c = 1; c <= cols; c++)
              _buildCell(
                context,
                row: r,
                col: c,
                value: data.getCell(r, c),
              ),
          ],
        ),
      );
    }

    return Table(
      defaultColumnWidth: const FixedColumnWidth(cellWidth),
      border: TableBorder.all(
        color: Theme.of(context).dividerColor,
        width: 0.5,
      ),
      children: tableRows,
    );
  }

  Widget _buildTopLeftHeader(BuildContext context) {
    return SizedBox(
      width: headerWidth,
      height: headerHeight,
      child: Container(
        alignment: Alignment.center,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: const Text(
          '#',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildColumnHeader(BuildContext context, int col) {
    return SizedBox(
      width: cellWidth,
      height: headerHeight,
      child: Container(
        alignment: Alignment.center,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Text(
          data.columnLabel(col),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildRowHeader(BuildContext context, int row) {
    return SizedBox(
      width: headerWidth,
      height: cellHeight,
      child: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Text(
          '$row',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCell(
    BuildContext context, {
    required int row,
    required int col,
    required String value,
  }) {
    return SizedBox(
      width: cellWidth,
      height: cellHeight,
      child: InkWell(
        onTap: () => onCellTap(row, col),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class SpreadsheetData {
  int _rows;
  int _cols;
  late List<List<String>> _cells;

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
      n--; // 1-based to 0-based
      final charCode = 'A'.codeUnitAt(0) + (n % 26);
      buffer.writeCharCode(charCode);
      n ~/= 26;
    }
    return buffer.toString().split('').reversed.join();
  }
}
