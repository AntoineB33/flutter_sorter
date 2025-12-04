import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import '../controllers/spreadsheet_controller.dart';
import '../controllers/spreadsheet_selection_controller.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class HighPerfSpreadsheet extends ConsumerWidget {
  final String sheetId;
  const HighPerfSpreadsheet({super.key, required this.sheetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine dynamic size based on data or infinite scrolling logic
    const rowCount = 10000; 
    const colCount = 20;

    return TableView.builder(
      // Both vertical and horizontal scrolling with virtualization
      verticalDetails: ScrollableDetails.vertical(controller: ScrollController()),
      horizontalDetails: ScrollableDetails.horizontal(controller: ScrollController()),
      rowCount: rowCount,
      columnCount: colCount,
      
      columnBuilder: (index) => TableSpan(
        extent: const FixedTableSpanExtent(100), // Width
        backgroundDecoration: TableSpanDecoration(
          border: TableSpanBorder(trailing: BorderSide(color: Colors.grey)),
        ),
      ),
      rowBuilder: (index) => TableSpan(
        extent: const FixedTableSpanExtent(50), // Height
      ),
      
      // Only builds cells that are visible!
      cellBuilder: (context, vicinity) {
        return SmartCell(
          sheetId: sheetId, // Pass sheet ID down
          rowIndex: vicinity.row,
          colIndex: vicinity.column,
        );
      },
    );
  }
}

/// A "Smart" ConsumerWidget that listens only to its specific cell data AND selection state.
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

    // 1. Listen to Data
    final cellValue = ref.watch(
      spreadsheetControllerProvider.select(
        (state) => state.valueOrNull?[key]?.value ?? '',
      ),
    );

    // 2. Listen to Selection (Optimized)
    // Only rebuilds if THIS specific cell's selection status changes
    final isSelected = ref.watch(
      spreadsheetSelectionProvider.select((selectedSet) => selectedSet.contains(key)),
    );

    return _EditableCell(
      initialValue: cellValue,
      isSelected: isSelected, // Pass down visual state
      onChanged: (val) {
        ref
            .read(spreadsheetControllerProvider.notifier)
            .onCellChanged(rowIndex, colIndex, val);
      },
      onTap: () {
        // Trigger selection when tapped
        ref
            .read(spreadsheetSelectionProvider.notifier)
            .selectCell(rowIndex, colIndex);
      },
    );
  }
}
class _EditableCell extends StatefulWidget {
  final String initialValue;
  final bool isSelected; // New Property
  final VoidCallback onTap; // New Property
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
    
    // Optional: Synchronize Focus with Selection
    // If the keyboard focuses this input, we ensure it's selected in the store
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
    // We wrap the TextField in a Container to handle the "Selected" border visual
    return Container(
      decoration: BoxDecoration(
        // If selected, show a Blue border, otherwise transparent (or none)
        border: widget.isSelected
            ? Border.all(color: Colors.blue, width: 2.0)
            : null,
        // Optional: Slight background tint when selected
        color: widget.isSelected ? Colors.blue.withOpacity(0.05) : null,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        // Crucial: We use onTap inside TextField to ensure the click is caught
        onTap: widget.onTap, 
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.all(14),
        ),
      ),
    );
  }
}