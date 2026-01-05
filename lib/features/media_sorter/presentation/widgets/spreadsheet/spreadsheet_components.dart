import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final Color backgroundColor;
  final Function(TapDownDetails) onContextMenu;

  const SpreadsheetColumnHeader({
    super.key,
    required this.label,
    required this.colIndex,
    required this.backgroundColor,
    required this.onContextMenu,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: onContextMenu,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
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
  final String previousContent;
  final String? initialEditText;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final ValueChanged<String>? onChanged;
  final void Function(String value, {bool moveUp}) onSave;
  final void Function(String previousContent) onEscape;

  const SpreadsheetDataCell({
    super.key,
    required this.row,
    required this.col,
    required this.content,
    required this.isPrimarySelectedCell,
    required this.isSelected,
    required this.isEditing,
    required this.previousContent,
    required this.initialEditText,
    required this.onTap,
    required this.onDoubleTap,
    required this.onChanged,
    required this.onSave,
    required this.onEscape,
  });

  @override
  State<SpreadsheetDataCell> createState() => _SpreadsheetDataCellState();
}

class _SpreadsheetDataCellState extends State<SpreadsheetDataCell> {
  late TextEditingController _textController;
  final FocusNode _editFocusNode = FocusNode();
   
  // Variables for manual double-tap detection
  int _lastTapTime = 0;
  static const int _doubleTapTimeout = 300; 

  @override
  void initState() {
    super.initState();
    final String startText = (widget.isEditing && widget.initialEditText != null)
        ? widget.initialEditText!
        : widget.content;

    _textController = TextEditingController(text: startText);
    
    if (widget.isEditing) {
      _editFocusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(SpreadsheetDataCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle transition into Edit Mode
    if (widget.isEditing && !oldWidget.isEditing) {
      if (widget.initialEditText != null) {
        _textController.text = widget.initialEditText!;
      } else {
        _textController.text = widget.content;
      }

      _editFocusNode.requestFocus();
      
      // Ensure cursor is at the end of the text
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
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

  /// Manually inserts a newline at the current cursor position
  void _insertNewline() {
    final text = _textController.text;
    final selection = _textController.selection;
    
    // Fallback if selection is invalid (rare)
    final int start = selection.start >= 0 ? selection.start : text.length;
    final int end = selection.end >= 0 ? selection.end : text.length;

    // Replace selected text (or insert at cursor) with \n
    final newText = text.replaceRange(start, end, '\n');
    
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + 1), // Move cursor after \n
    );
    // Trigger onChanged manually since direct controller manipulation doesn't always fire it
    widget.onChanged?.call(newText);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blue, width: 2.0),
        ),
        // -------------------------------------------------------------
        // SHORTCUTS IMPLEMENTATION
        // -------------------------------------------------------------
        child: CallbackShortcuts(
          bindings: {
            // 1. Ctrl + Enter = Insert New Line
            // (Note: This overrides the default behavior, so we use our helper)
            const SingleActivator(LogicalKeyboardKey.enter, control: true): () {
              _insertNewline();
            },
            // 2. Shift + Enter = Save & Move Up
            const SingleActivator(LogicalKeyboardKey.enter, shift: true): () {
              widget.onSave(_textController.text, moveUp: true);
            },
            // 3. Enter (no modifiers) = Save & Move Down
            // We define this last so modifiers take precedence, though SingleActivator handles matching well.
            const SingleActivator(LogicalKeyboardKey.enter): () {
              widget.onSave(_textController.text, moveUp: false);
            },

            // 4. Escape = Cancel Edit
            const SingleActivator(LogicalKeyboardKey.escape): () {
              widget.onEscape(widget.previousContent);
            },
          },
          child: TextField(
            controller: _textController,
            focusNode: _editFocusNode,
            autofocus: true,
            maxLines: null, // Allows multiline
            minLines: 1,
            onChanged: widget.onChanged, 
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              border: InputBorder.none,
              isDense: true,
            ),
            style: const TextStyle(fontSize: 14),
            // onSubmitted handles software keyboards (mobile "Done" button)
            onSubmitted: (value) => widget.onSave(value, moveUp: false),
          ),
        ),
      );
    }

    // View Mode
    return InkWell(
      onTap: _handleTap,
      child: Container(
        alignment: Alignment.topLeft, 
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: widget.isPrimarySelectedCell 
              ? Colors.blue.shade300 
              : (widget.isSelected ? Colors.blue.shade100 : Colors.white),
          border: Border(
            right: BorderSide(color: Colors.grey.shade200),
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Text(
          widget.content,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}