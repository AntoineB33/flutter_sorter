import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/spreadsheet_controller.dart';

class SpreadsheetPage extends ConsumerWidget {
  const SpreadsheetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      spreadsheetControllerProvider.select((s) => s.isLoading),
    );

    // Grid Configuration
    const int totalRows = 20;
    const int totalCols = 10;
    const double cellWidth = 100.0;
    const double cellHeight = 50.0;
    const double rowHeaderWidth = 60.0; // New width for the row index column

    void onCornerButtonPressed() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Corner Button Pressed!')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Spreadsheet'),
        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnSpacing: 0,
            horizontalMargin: 0,
            headingRowHeight: cellHeight,
            // 1. GENERATE COLUMNS
            columns: [
              // --- THE CORNER BUTTON (Top-Left) ---
              DataColumn(
                label: SizedBox(
                  width: rowHeaderWidth,
                  height: cellHeight,
                  child: Material(
                    color: Colors.grey.shade200, // Header color
                    child: InkWell(
                      onTap: onCornerButtonPressed,
                      child: const Center(
                        child: Icon(Icons.apps, size: 20, color: Colors.black54),
                      ),
                    ),
                  ),
                ),
              ),
              // --- THE COLUMN HEADERS (A, B, C...) ---
              ...List.generate(totalCols, (index) {
                return DataColumn(
                  label: Container(
                    width: cellWidth,
                    alignment: Alignment.center,
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C...
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ],
            // 2. GENERATE ROWS
            rows: List.generate(totalRows, (rowIndex) {
              return DataRow(
                cells: [
                  // --- THE ROW HEADER (1, 2, 3...) ---
                  DataCell(
                    Container(
                      width: rowHeaderWidth,
                      height: cellHeight,
                      alignment: Alignment.center,
                      color: Colors.grey.shade100, // Visual distinction
                      child: Text(
                        '${rowIndex + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  // --- THE EDITABLE CONTENT CELLS ---
                  ...List.generate(totalCols, (colIndex) {
                    return DataCell(
                      SizedBox(
                        width: cellWidth,
                        height: cellHeight,
                        child: SmartCell(
                          rowIndex: rowIndex,
                          colIndex: colIndex,
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// A "Smart" ConsumerWidget that listens only to its specific cell data.
class SmartCell extends ConsumerWidget {
  final int rowIndex;
  final int colIndex;

  const SmartCell({
    super.key,
    required this.rowIndex,
    required this.colIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = '$rowIndex:$colIndex';

    final cellValue = ref.watch(
      spreadsheetControllerProvider.select(
        (state) => state.valueOrNull?[key]?.value ?? '',
      ),
    );

    return _EditableCell(
      initialValue: cellValue,
      onChanged: (val) {
        ref
            .read(spreadsheetControllerProvider.notifier)
            .onCellChanged(rowIndex, colIndex, val);
      },
    );
  }
}

// Low-level text handling widget
class _EditableCell extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;

  const _EditableCell({
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_EditableCell> createState() => _EditableCellState();
}

class _EditableCellState extends State<_EditableCell> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _EditableCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text) {
      if (!_focusNode.hasFocus) {
        _controller.text = widget.initialValue;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 14),
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.all(14),
      ),
    );
  }
}