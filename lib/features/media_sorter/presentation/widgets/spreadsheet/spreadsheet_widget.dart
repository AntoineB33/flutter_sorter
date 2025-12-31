import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/column_type_extensions.dart';
import 'spreadsheet_components.dart';
import 'dart:math' as math;
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';

class SpreadsheetWidget extends StatefulWidget {
  const SpreadsheetWidget({super.key});

  @override
  State<SpreadsheetWidget> createState() => _SpreadsheetWidgetState();
}

class _SpreadsheetWidgetState extends State<SpreadsheetWidget> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

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

    // 1. Wrap everything in LayoutBuilder to get dimensions
    return LayoutBuilder(
      builder: (context, constraints) {
        // 2. Determine the available size
        final Size currentSize = constraints.biggest;

        // 3. Update controller if size has changed.
        // We check against the controller's current value to prevent infinite loops.
        // We use addPostFrameCallback because we cannot setState/notifyListeners during build.
        if (controller.visibleWindowSize != currentSize) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.updateVisibleWindowSize(currentSize);
          });
        }

        return KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (KeyEvent event) => _handleKeyboard(context, event, controller),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) => _handleScrollNotification(notification, controller),
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
          ),
        );
      },
    );
  }

  bool _handleScrollNotification(ScrollNotification notification, SpreadsheetController controller) {
    // We only care about vertical scrolling on the TableView
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }

    final metrics = notification.metrics;
    
    // We calculate the row count required so that maxScrollExtent > pixels.
    // Logic:
    // 1. Visible Bottom Edge = currentPixels + viewportDimension
    // 2. Content Height needed > Visible Bottom Edge (strictly greater to not 'reach' bottom)
    // 3. Content Height = HeaderHeight + (Rows * CellHeight)
    // 4. Rows > (VisibleBottomEdge - HeaderHeight) / CellHeight
    
    final double visibleBottomEdge = metrics.pixels + metrics.viewportDimension;
    final double rawRowsNeeded = (visibleBottomEdge - SpreadsheetConstants.headerHeight) / SpreadsheetConstants.defaultCellHeight;
    
    // floor() gives us the index of the row currently at the bottom edge. 
    // We add 1 to ensure the total count extends BEYOND that edge.
    // Example: If bottom edge is exactly at end of row 10, raw is 10.0. 
    // floor(10.0)+1 = 11. Rows 0-10 (11 rows) means height is slightly past row 10 (if using > logic). 
    // Actually, to strictly ensure extentAfter > 0, we need the count to cover the space + epsilon.
    final int requiredRows = rawRowsNeeded.floor() + 1;

    // Apply minimum constraint
    final int targetRows = math.max(controller.minRows, requiredRows);

    if (notification is ScrollUpdateNotification) {
      // SCENARIO 1: Scrolling Down.
      // We check if we *will* reach bottom (or are effectively there).
      // If our current rows are less than what is needed to keep extentAfter > 0, we update.
      if (targetRows > controller.tableViewRows) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.updateRowCount(targetRows);
        });
      }
    } else if (notification is ScrollEndNotification) {
      // SCENARIO 2: Scrolling Up (or stopping).
      // "After scrolling... calculate least amount... so spreadsheet doesn't reach bottom"
      // If we have more rows than strictly necessary, we trim them down to the target.
      if (controller.tableViewRows > targetRows) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.updateRowCount(targetRows);
        });
      }
    }

    return false;
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
      extent: FixedTableSpanExtent(index == 0 ? SpreadsheetConstants.headerWidth : SpreadsheetConstants.defaultCellWidth),
    );
  }

  TableSpan _buildRowSpan(int index) {
    return TableSpan(
      extent: FixedTableSpanExtent(index == 0 ? SpreadsheetConstants.headerHeight : SpreadsheetConstants.defaultCellHeight),
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