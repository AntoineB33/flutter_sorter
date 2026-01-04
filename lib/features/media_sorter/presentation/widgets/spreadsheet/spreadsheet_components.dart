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
  final bool isSelected;
  final bool isEditing;
  final VoidCallback onTap;
  final ValueChanged<String> onSave;

  const SpreadsheetDataCell({
    super.key,
    required this.row,
    required this.col,
    required this.content,
    required this.isSelected,
    required this.isEditing,
    required this.onTap,
    required this.onSave,
  });

  @override
  State<SpreadsheetDataCell> createState() => _SpreadsheetDataCellState();
}

class _SpreadsheetDataCellState extends State<SpreadsheetDataCell> {
  late TextEditingController _textController;
  final FocusNode _editFocusNode = FocusNode();

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
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
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
      onTap: widget.onTap,
      // Double tap to edit is standard spreadsheet behavior
      onDoubleTap: () {
         widget.onTap(); // Ensure selected
         // You might want to trigger edit callback here too if passed down
      },
      child: Container(
        alignment: Alignment.centerLeft, // Align left usually looks better for data
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: widget.isSelected ? Colors.blue.shade100 : Colors.white,
          border: Border(
            right: BorderSide(color: Colors.grey.shade200),
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Text(
          widget.content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}