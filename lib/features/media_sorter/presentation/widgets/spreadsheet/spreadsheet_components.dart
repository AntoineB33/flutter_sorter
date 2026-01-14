import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';

// ... (SpreadsheetSelectAllCorner, SpreadsheetColumnHeader, SpreadsheetRowHeader remain unchanged) ...

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

    if (widget.isEditing && !oldWidget.isEditing) {
      if (widget.initialEditText != null) {
        _textController.text = widget.initialEditText!;
      } else {
        _textController.text = widget.content;
      }

      _editFocusNode.requestFocus();

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

  void _insertNewline() {
    final text = _textController.text;
    final selection = _textController.selection;
    final int start = selection.start >= 0 ? selection.start : text.length;
    final int end = selection.end >= 0 ? selection.end : text.length;
    final newText = text.replaceRange(start, end, '\n');

    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + 1),
    );
    widget.onChanged?.call(newText);
  }

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------------------------
    // EDIT MODE
    // -------------------------------------------------------------------------
    if (widget.isEditing) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          // Border takes 2px
          border: Border.all(color: Colors.blue, width: 2.0),
        ),
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.enter, control: true): () => _insertNewline(),
            const SingleActivator(LogicalKeyboardKey.enter, shift: true): () =>
                widget.onSave(_textController.text, moveUp: true),
            const SingleActivator(LogicalKeyboardKey.enter): () =>
                widget.onSave(_textController.text, moveUp: false),
            const SingleActivator(LogicalKeyboardKey.escape): () =>
                widget.onEscape(widget.previousContent),
          },
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: TextField(
              controller: _textController,
              focusNode: _editFocusNode,
              autofocus: true,
              maxLines: null,
              minLines: 1,
              onChanged: widget.onChanged,
              
              // FIX 1: Align text to the top to match View Mode's Alignment.topLeft
              textAlignVertical: TextAlignVertical.top,

              // FIX 2: Force StrutStyle. This ensures the line height and vertical 
              // metrics exactly match a standard Text widget, preventing the "bigger" look.
              strutStyle: StrutStyle.fromTextStyle(PageConstants.cellStyle),

              style: PageConstants.cellStyle,
              decoration: const InputDecoration(
                // FIX 3: Precise Padding Math
                // View Mode Padding (4px) - Edit Border (2px) = 2px required.
                // We use 3px horizontal to ensure the cursor doesn't overlap the border visually.
                contentPadding: EdgeInsets.fromLTRB(3, 2, 2, 2),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (value) => widget.onSave(value, moveUp: false),
            ),
          ),
        ),
      );
    }

    // -------------------------------------------------------------------------
    // VIEW MODE
    // -------------------------------------------------------------------------
    return InkWell(
      onTap: _handleTap,
      child: Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.symmetric(
          horizontal: PageConstants.horizontalPadding, 
          vertical: PageConstants.verticalPadding
        ),
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
          style: PageConstants.cellStyle,
        ),
      ),
    );
  }
}
