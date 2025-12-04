import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import '../controllers/spreadsheet_controller.dart';
import '../controllers/spreadsheet_selection_controller.dart';

class HighPerfSpreadsheet extends ConsumerWidget {
  final String sheetId;
  const HighPerfSpreadsheet({super.key, required this.sheetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Increase count by 1 to accommodate headers
    const rowCount = 10000 + 1; 
    const colCount = 20 + 1;

    return Scaffold(
      body: TableView.builder(
        verticalDetails: ScrollableDetails.vertical(controller: ScrollController()),
        horizontalDetails: ScrollableDetails.horizontal(controller: ScrollController()),
        
        // 1. PIN THE HEADERS
        pinnedRowCount: 1,
        pinnedColumnCount: 1,
        
        rowCount: rowCount,
        columnCount: colCount,

        columnBuilder: (index) => TableSpan(
          // First column (Row Headers) is smaller, others are 100
          extent: FixedTableSpanExtent(index == 0 ? 50 : 100),
          backgroundDecoration: TableSpanDecoration(
            // Vertical Lines
            border: TableSpanBorder(trailing: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
        
        rowBuilder: (index) => TableSpan(
          extent: const FixedTableSpanExtent(50),
          backgroundDecoration: TableSpanDecoration(
            // 2. ADD HORIZONTAL LINES HERE
            border: TableSpanBorder(trailing: BorderSide(color: Colors.grey.shade300)),
          ),
        ),

        cellBuilder: (context, vicinity) {
          final r = vicinity.row;
          final c = vicinity.column;

          // --- CASE 1: The Top-Left "Joint" Button ---
          if (r == 0 && c == 0) {
            return Container(
              color: Colors.grey.shade200,
              child: InkWell(
                onTap: () {
                   ref
                      .read(spreadsheetSelectionProvider.notifier)
                      .selectAll(rowCount - 1, colCount - 1);
                },
                child: const Icon(Icons.change_history, size: 16, color: Colors.grey),
              ),
            );
          }

          // --- CASE 2: Column Headers (A, B, C...) ---
          if (r == 0) {
            return Container(
              alignment: Alignment.center,
              color: Colors.grey.shade200,
              child: Text(
                _getExcelColumnLabel(c - 1), // 0-based index for logic
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            );
          }

          // --- CASE 3: Row Headers (1, 2, 3...) ---
          if (c == 0) {
            return Container(
              alignment: Alignment.center,
              color: Colors.grey.shade200,
              child: Text(
                '$r', // Direct row index matches standard spreadsheet numbering (1-based)
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            );
          }

          // --- CASE 4: The Actual Data Cell ---
          // We assume the data source (Riverpod) is 0-indexed.
          // Since the view has 1 row/col of headers, we shift indices by -1.
          return SmartCell(
            sheetId: sheetId,
            rowIndex: r - 1,
            colIndex: c - 1,
          );
        },
      ),
    );
  }

  // Helper to convert 0 -> A, 1 -> B, 26 -> AA
  String _getExcelColumnLabel(int index) {
    String label = "";
    int i = index;
    while (i >= 0) {
      label = String.fromCharCode((i % 26) + 65) + label;
      i = (i / 26).floor() - 1;
    }
    return label;
  }
}

// ... Keep your existing SmartCell and _EditableCell classes exactly as they were ...
class SmartCell extends ConsumerWidget {
  final String sheetId;
  final int rowIndex;
  final int colIndex;

  const SmartCell({
    super.key,
    required this.sheetId,
    required this.rowIndex,
    required this.colIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = '$rowIndex:$colIndex';

    final cellValue = ref.watch(
      spreadsheetControllerProvider(sheetId).select(
        (state) => state.valueOrNull?[key]?.value ?? '',
      ),
    );

    final isSelected = ref.watch(
      spreadsheetSelectionProvider.select((selectedSet) => selectedSet.contains(key)),
    );

    return _EditableCell(
      initialValue: cellValue,
      isSelected: isSelected, 
      onChanged: (val) {
        ref
            .read(spreadsheetControllerProvider(sheetId).notifier)
            .onCellChanged(rowIndex, colIndex, val);
      },
      onTap: () {
        ref
            .read(spreadsheetSelectionProvider.notifier)
            .selectCell(rowIndex, colIndex);
      },
    );
  }
}

class _EditableCell extends StatefulWidget {
  final String initialValue;
  final bool isSelected;
  final VoidCallback onTap; 
  final Function(String) onChanged;

  const _EditableCell({
    required this.initialValue,
    required this.isSelected,
    required this.onTap,
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
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        widget.onTap();
      }
    });
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
    return Container(
      decoration: BoxDecoration(
        border: widget.isSelected
            ? Border.all(color: Colors.blue, width: 2.0)
            : null,
        color: widget.isSelected ? Colors.blue.withValues(alpha: 0.05) : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          onTap: widget.onTap, 
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.all(14),
          ),
        ),
      ),
    );
  }
}