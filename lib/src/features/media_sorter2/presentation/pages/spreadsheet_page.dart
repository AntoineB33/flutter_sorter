import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/spreadsheet_controller.dart';

class SpreadsheetPage extends ConsumerWidget {
  const SpreadsheetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spreadsheetState = ref.watch(spreadsheetControllerProvider);
    final controller = ref.read(spreadsheetControllerProvider.notifier);

    // Grid Configuration
    const int totalRows = 20;
    const int totalCols = 10;
    const double cellWidth = 100.0;
    const double cellHeight = 50.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Spreadsheet'),
        actions: [
           if(spreadsheetState.isLoading)
             const Padding(
               padding: EdgeInsets.all(16.0),
               child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
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
            // Generate Rows (1, 2, 3...)
            rows: List.generate(totalRows, (rowIndex) {
              return DataRow(
                cells: List.generate(totalCols, (colIndex) {
                  final key = '$rowIndex:$colIndex';
                  final cellData = spreadsheetState.cells[key];
                  
                  return DataCell(
                    SizedBox(
                      width: cellWidth,
                      height: cellHeight,
                      child: _EditableCell(
                        initialValue: cellData?.value ?? '',
                        onChanged: (val) {
                          controller.onCellChanged(rowIndex, colIndex, val);
                        },
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

// A simple widget to handle text input focus and submission
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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _EditableCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if the cursor is not focused (prevents jumping while typing)
    if (widget.initialValue != _controller.text && !FocusScope.of(context).hasFocus) {
       _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 14),
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
      ),
    );
  }
}