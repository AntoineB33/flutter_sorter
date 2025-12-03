import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/spreadsheet_controller.dart';

class SpreadsheetPage extends ConsumerWidget {
  const SpreadsheetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // PERFORMANCE OPTIMIZATION: 
    // We strictly use `select` here. We only want to rebuild the main Scaffold 
    // if the loading state changes. We do NOT want to rebuild the Scaffold
    // when a cell value changes.
    final isLoading = ref.watch(
      spreadsheetControllerProvider.select((s) => s.isLoading),
    );

    // Grid Configuration
    const int totalRows = 20;
    const int totalCols = 10;
    const double cellWidth = 100.0;
    const double cellHeight = 50.0;

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
            // Generate Columns (A, B, C...)
            columns: List.generate(totalCols, (index) {
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
            // Generate Rows
            rows: List.generate(totalRows, (rowIndex) {
              return DataRow(
                cells: List.generate(totalCols, (colIndex) {
                  return DataCell(
                    SizedBox(
                      width: cellWidth,
                      height: cellHeight,
                      // PERFORMANCE: We pass the indices to a const widget.
                      // The widget itself handles the connection to Riverpod.
                      child: SmartCell(
                        rowIndex: rowIndex,
                        colIndex: colIndex,
                      ),
                    ),
                  );
                }),
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

    // PERFORMANCE MAGIC:
    // We use .select() to listen ONLY to the specific key in the map.
    // This widget will ONLY rebuild if THIS specific cell's value changes.
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
    // Sync logic:
    // If the value coming from the provider is different from what is in the text box...
    if (widget.initialValue != _controller.text) {
      // AND we don't have focus (meaning we aren't the one typing currently)...
      if (!_focusNode.hasFocus) {
         // Then update the text.
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
        contentPadding: EdgeInsets.all(14), // Vertically center text
      ),
    );
  }
}