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
    const rowCount = 10000;
    const colCount = 20;

    // --- FIX: Add a Scaffold to provide the white background canvas ---
    return Scaffold( 
      body: TableView.builder(
        verticalDetails: ScrollableDetails.vertical(controller: ScrollController()),
        horizontalDetails: ScrollableDetails.horizontal(controller: ScrollController()),
        rowCount: rowCount,
        columnCount: colCount,
        
        columnBuilder: (index) => TableSpan(
          extent: const FixedTableSpanExtent(100),
          backgroundDecoration: TableSpanDecoration(
            // Optional: You can also color specific columns here
            border: TableSpanBorder(trailing: BorderSide(color: Colors.grey)),
          ),
        ),
        rowBuilder: (index) => TableSpan(
          extent: const FixedTableSpanExtent(50),
        ),
        
        cellBuilder: (context, vicinity) {
          return SmartCell(
            sheetId: sheetId,
            rowIndex: vicinity.row,
            colIndex: vicinity.column,
          );
        },
      ),
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
      spreadsheetControllerProvider(sheetId).select(
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
            .read(spreadsheetControllerProvider(sheetId).notifier)
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
        color: widget.isSelected ? Colors.blue.withValues(alpha: .05) : null,
      ),
      // --- FIX STARTS HERE ---
      // The TextField needs a Material ancestor to paint on. 
      // We use MaterialType.transparency so it doesn't hide the Container's decoration.
      child: Material(
        type: MaterialType.transparency,
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
      ),
      // --- FIX ENDS HERE ---
    );
  }
}