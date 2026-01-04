import 'package:flutter/material.dart';

class SpreadsheetSelectAllCorner extends StatelessWidget {
  final VoidCallback onTap;
  const SpreadsheetSelectAllCorner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: const Icon(Icons.select_all, size: 16),
      ),
    );
  }
}

class SpreadsheetColumnHeader extends StatelessWidget {
  final String label;
  final int colIndex;
  final Function(TapDownDetails) onContextMenu;

  const SpreadsheetColumnHeader({
    super.key,
    required this.label,
    required this.colIndex,
    required this.onContextMenu,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: onContextMenu,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          border: Border(
            right: BorderSide(color: Colors.grey.shade400),
            bottom: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class SpreadsheetRowHeader extends StatelessWidget {
  final int rowIndex;
  const SpreadsheetRowHeader({super.key, required this.rowIndex});

  @override
  Widget build(BuildContext context) {
    final String label = (rowIndex == 0) ? "Headers" : "$rowIndex";

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        border: Border(
          right: BorderSide(color: Colors.grey.shade400),
          bottom: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: rowIndex == 0 ? FontWeight.bold : FontWeight.normal,
          fontSize: rowIndex == 0 ? 12 : 14,
        ),
      ),
    );
  }
}

class SpreadsheetDataCell extends StatefulWidget {
  final int row;
  final int col;
  final String content;
  final bool isPrimarySelectedCell;
  final bool isSelected;
  final bool isEditing;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final ValueChanged<String> onSave;

  const SpreadsheetDataCell({
    super.key,
    required this.row,
    required this.col,
    required this.content,
    required this.isPrimarySelectedCell,
    required this.isSelected,
    required this.isEditing,
    required this.onTap,
    required this.onDoubleTap,
    required this.onSave,
  });

  @override
  State<SpreadsheetDataCell> createState() => _SpreadsheetDataCellState();
}

class _SpreadsheetDataCellState extends State<SpreadsheetDataCell> {
  late TextEditingController _textController;
  final FocusNode _editFocusNode = FocusNode();
  
  // Variables for manual double-tap detection
  int _lastTapTime = 0;
  static const int _doubleTapTimeout = 300; // Standard Android/iOS timeout

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.content);
    
    // If created in edit mode, request focus immediately
    if (widget.isEditing) {
      _editFocusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(SpreadsheetDataCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If we just entered edit mode
    if (widget.isEditing && !oldWidget.isEditing) {
      _textController.text = widget.content;
      _editFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _editFocusNode.dispose();
    super.dispose();
  }
  
  void _handleTap() {
    final int now = DateTime.now().millisecondsSinceEpoch;
    
    if (now - _lastTapTime < _doubleTapTimeout) {
      widget.onDoubleTap();
    } else {
      widget.onTap();
    }

    _lastTapTime = now;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Edit Mode
    if (widget.isEditing) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blue, width: 2.0), // Highlight border
        ),
        child: TextField(
          controller: _textController,
          focusNode: _editFocusNode,
          autofocus: true,
          maxLines: null, // Allow multiline editing
          minLines: 1,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4), // Added vertical padding
            border: InputBorder.none,
            isDense: true,
          ),
          style: const TextStyle(fontSize: 14),
          onSubmitted: (value) => widget.onSave(value),
          // Optional: TapOutside logic could go here to save on blur
        ),
      );
    }

    // 2. View Mode
    return InkWell(
      onTap: _handleTap,
      child: Container(// Changed to topLeft so multiline text starts correctly
        alignment: Alignment.topLeft, 
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), // Add vertical padding
        decoration: BoxDecoration(
          color: widget.isPrimarySelectedCell ? Colors.blue.shade300 : (widget.isSelected ? Colors.blue.shade100 : Colors.white),
          border: Border(
            right: BorderSide(color: Colors.grey.shade200),
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Text(
          widget.content,
          // Removed maxLines: 1 and overflow ellipsis
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}