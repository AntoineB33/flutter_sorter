import 'package:flutter/material.dart';
import '../data/spreadsheet_data.dart';

class SpreadsheetView extends StatefulWidget {
  final SpreadsheetData data;
  final VoidCallback onChanged;
  final void Function(String value)? onCellSelected;

  const SpreadsheetView({
    super.key,
    required this.data,
    required this.onChanged,
    this.onCellSelected,
  });

  @override
  State<SpreadsheetView> createState() => _SpreadsheetViewState();
}

class _SpreadsheetViewState extends State<SpreadsheetView> {
  static const double cellWidth = 100;
  static const double cellHeight = 40;
  static const double headerHeight = 44;
  static const double headerWidth = 60;

  static const Map<String, Color> columnTypes = {
    'Default': Colors.transparent,
    'Number': Colors.lightBlueAccent,
    'Text': Colors.amberAccent,
    'Date': Colors.lightGreenAccent,
    'Currency': Colors.pinkAccent,
    'Boolean': Colors.deepPurpleAccent,
  };

  int? _editingRow;
  int? _editingCol;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing(int row, int col) {
    setState(() {
      _editingRow = row;
      _editingCol = col;
      _controller.text = widget.data.getCell(row, col);
      _focusNode.requestFocus();
    });
  }

  void _commitEditing() {
    if (_editingRow != null && _editingCol != null) {
      widget.data.setCell(_editingRow!, _editingCol!, _controller.text);
      widget.onChanged();
    }
    setState(() {
      _editingRow = null;
      _editingCol = null;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingRow = null;
      _editingCol = null;
    });
  }

  Future<void> _showTypeMenu(
    BuildContext context,
    Offset position,
    int col,
  ) async {
    final currentType = widget.data.getColumnType(col);

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: columnTypes.entries.map((entry) {
        return CheckedPopupMenuItem<String>(
          value: entry.key,
          checked: entry.key == currentType,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: entry.value == Colors.transparent
                      ? Colors.grey.shade300
                      : entry.value,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Colors.black26),
                ),
              ),
              const SizedBox(width: 8),
              Text(entry.key),
            ],
          ),
        );
      }).toList(),
    );

    if (result != null) {
      setState(() {
        widget.data.setColumnType(col, result);
      });
      await widget.data.save();
    }
  }

  void _showColumnContextMenu(BuildContext context, Offset position, int col) async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        const PopupMenuItem(
          value: 'test1',
          child: Text('Test Action 1'),
        ),
        const PopupMenuItem(
          value: 'test2',
          child: Text('Test Action 2'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'change_type',
          child: Text('Change Type ▶'),
        ),
      ],
    );

    if (result != null) {
      switch (result) {
        case 'test1':
          debugPrint('Test Action 1 clicked on column ${widget.data.columnLabel(col)}');
          break;
        case 'test2':
          debugPrint('Test Action 2 clicked on column ${widget.data.columnLabel(col)}');
          break;
        case 'change_type':
          await _showTypeMenu(context, position, col);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = widget.data.rowCount;
    final cols = widget.data.colCount;

    final tableRows = <TableRow>[];

    // Header row
    tableRows.add(
      TableRow(
        children: [
          _buildTopLeftHeader(context),
          for (int c = 1; c <= cols; c++) _buildColumnHeader(context, c),
        ],
      ),
    );

    // Data rows
    for (int r = 1; r <= rows; r++) {
      tableRows.add(
        TableRow(
          children: [
            _buildRowHeader(context, r),
            for (int c = 1; c <= cols; c++)
              _buildCell(
                context,
                row: r,
                col: c,
                value: widget.data.getCell(r, c),
              ),
          ],
        ),
      );
    }

    return Table(
      defaultColumnWidth: const FixedColumnWidth(cellWidth),
      border: TableBorder.all(
        color: Theme.of(context).dividerColor,
        width: 0.5,
      ),
      children: tableRows,
    );
  }

  Widget _buildTopLeftHeader(BuildContext context) {
    return Container(
      width: headerWidth,
      height: headerHeight,
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: const Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildColumnHeader(BuildContext context, int col) {
    final type = widget.data.getColumnType(col);
    final color = columnTypes[type] ?? Colors.transparent;

    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showColumnContextMenu(context, details.globalPosition, col);
      },
      child: Container(
        width: cellWidth,
        height: headerHeight,
        alignment: Alignment.center,
        color: color == Colors.transparent
            ? Theme.of(context).colorScheme.surfaceVariant
            : color.withOpacity(0.5),
        child: Text(
          widget.data.columnLabel(col),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildRowHeader(BuildContext context, int row) {
    return Container(
      width: headerWidth,
      height: cellHeight,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Text('$row', style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCell(
    BuildContext context, {
    required int row,
    required int col,
    required String value,
  }) {
    final isEditing = _editingRow == row && _editingCol == col;

    if (isEditing) {
      return Container(
        width: cellWidth,
        height: cellHeight,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          onSubmitted: (_) => _commitEditing(),
          onEditingComplete: _commitEditing,
          onTapOutside: (_) => _commitEditing(),
          onTap: () {}, // prevent unintentional re-trigger
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          _startEditing(row, col);
          widget.onCellSelected?.call(widget.data.getCell(row, col));
        },
        child: Container(
          width: cellWidth,
          height: cellHeight,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
  }
}
