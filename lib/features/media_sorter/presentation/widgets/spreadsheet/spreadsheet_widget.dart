import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/column_type_extensions.dart';
import 'spreadsheet_components.dart';

class SpreadsheetWidget extends StatefulWidget {
  const SpreadsheetWidget({super.key});

  @override
  State<SpreadsheetWidget> createState() => _SpreadsheetWidgetState();
}

class _SpreadsheetWidgetState extends State<SpreadsheetWidget> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  static const double _defaultCellWidth = 100;
  static const double _defaultCellHeight = 40;
  static const double _headerHeight = 44;
  static const double _headerWidth = 60;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SpreadsheetController>();

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) => _handleKeyboard(context, event, controller),
      child: TableView.builder(
        verticalDetails: ScrollableDetails.vertical(controller: _verticalController),
        horizontalDetails: ScrollableDetails.horizontal(controller: _horizontalController),
        pinnedRowCount: 1,
        pinnedColumnCount: 1,
        rowCount: controller.tableViewRows + 1,
        columnCount: controller.tableViewCols + 1,
        columnBuilder: (index) => _buildColumnSpan(index),
        rowBuilder: (index) => _buildRowSpan(index),
        cellBuilder: (context, vicinity) => _buildCellDispatcher(context, vicinity, controller),
      ),
    );
  }

  void _handleKeyboard(BuildContext context, KeyEvent event, SpreadsheetController ctrl) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey.keyLabel.toLowerCase();
    final isControl = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;

    if (isControl && key == 'c') {
      ctrl.copySelectionToClipboard();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selection copied'), duration: Duration(milliseconds: 500)),
      );
    } else if (isControl && key == 'v') {
      ctrl.pasteSelection();
    }
  }

  TableSpan _buildColumnSpan(int index) {
    return TableSpan(
      extent: FixedTableSpanExtent(index == 0 ? _headerWidth : _defaultCellWidth),
    );
  }

  TableSpan _buildRowSpan(int index) {
    return TableSpan(
      extent: FixedTableSpanExtent(index == 0 ? _headerHeight : _defaultCellHeight),
    );
  }

  Widget _buildCellDispatcher(
      BuildContext context, TableVicinity vicinity, SpreadsheetController controller) {
    final int r = vicinity.row;
    final int c = vicinity.column;

    if (r == 0 && c == 0) {
      return SpreadsheetSelectAllCorner(onTap: () => controller.selectAll());
    }
    if (r == 0) {
      return SpreadsheetColumnHeader(
        label: controller.getColumnLabel(c - 1),
        colIndex: c - 1,
        onContextMenu: (details) =>
            _showColumnContextMenu(context, controller, details.globalPosition, c - 1),
      );
    }
    if (c == 0) {
      return SpreadsheetRowHeader(rowIndex: r - 1);
    }

    return SpreadsheetDataCell(
      row: r - 1,
      col: c - 1,
      content: controller.getContent(r - 1, c - 1),
      isSelected: controller.isCellSelected(r - 1, c - 1),
      onTap: () {
        controller.selectCell(r - 1, c - 1);
        _focusNode.requestFocus();
      },
    );
  }

  Future<void> _showTypeMenu(
    BuildContext context,
    SpreadsheetController controller,
    Offset position,
    int col,
  ) async {
    final currentType = controller.getColumnType(col);
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: ColumnType.values.map((entry) {
        return CheckedPopupMenuItem<String>(
          value: entry.name,
          checked: entry.name == currentType,
          child: Row(
            children: [
              Icon(Icons.circle, color: ColumnTypeX(entry).color, size: 12),
              const SizedBox(width: 8),
              Text(entry.name),
            ],
          ),
        );
      }).toList(),
    );

    if (result != null) {
      controller.setColumnType(col, result);
    }
  }

  void _showColumnContextMenu(
      BuildContext context, SpreadsheetController controller, Offset position, int col) async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: [
        const PopupMenuItem(value: 'sort_asc', child: Text('Sort A-Z')),
        const PopupMenuItem(value: 'sort_desc', child: Text('Sort Z-A')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'change_type', child: Text('Change Type ▶')),
      ],
    );

    if (!context.mounted) return;

    if (result == 'change_type') {
      await _showTypeMenu(context, controller, position, col);
    } else if (result != null) {
      debugPrint("Action $result on column $col");
    }
  }
}