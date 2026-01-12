import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/column_type_extensions.dart';
import 'spreadsheet_components.dart';
import 'dart:math' as math;
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';

class SpreadsheetWidget extends StatefulWidget {
  const SpreadsheetWidget({super.key});

  @override
  State<SpreadsheetWidget> createState() => _SpreadsheetWidgetState();
}

class _SpreadsheetWidgetState extends State<SpreadsheetWidget> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  StreamSubscription? _scrollSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _subscribeToScrollEvents();
    });
  }

  void _subscribeToScrollEvents() {
    final controller = context.read<SpreadsheetController>();
    _scrollSubscription?.cancel();
    _scrollSubscription = controller.scrollToCellStream.listen(_revealCell);
  }

  @override
  void dispose() {
    _scrollSubscription?.cancel();
    _verticalController.dispose();
    _horizontalController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Calculates offsets and scrolls to ensure the target cell is visible.
  void _revealCell(math.Point<int> cell) {
    if (!_verticalController.hasClients || !_horizontalController.hasClients) {
      return;
    }

    final controller = context.read<SpreadsheetController>();

    // Vertical Logic
    final double targetTop = controller.getTargetTop(cell.x);
    final double targetBottom = controller.getTargetTop(cell.x + 1);
    final double currentVerticalOffset = _verticalController.offset;
    final double verticalViewport =
        _verticalController.position.viewportDimension -
        controller.sheet.rowHeaderWidth;

    double? newVerticalOffset;

    if (targetTop < currentVerticalOffset) {
      newVerticalOffset = targetTop;
    } else if (targetBottom > currentVerticalOffset + verticalViewport) {
      newVerticalOffset = targetBottom - verticalViewport;
    }

    if (newVerticalOffset != null) {
      final double maxScroll = _verticalController.position.maxScrollExtent;
      final double clampedOffset = math.min(
        math.max(newVerticalOffset, 0),
        maxScroll,
      );

      _verticalController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }

    // Horizontal Logic
    final double targetLeft = controller.getTargetLeft(cell.y);
    final double targetRight = controller.getTargetLeft(cell.y + 1);
    final double currentHorizontalOffset = _horizontalController.offset;
    final double horizontalViewport =
        _horizontalController.position.viewportDimension -
        controller.sheet.rowHeaderWidth;

    double? newHorizontalOffset;

    if (targetLeft < currentHorizontalOffset) {
      newHorizontalOffset = targetLeft;
    } else if (targetRight > currentHorizontalOffset + horizontalViewport) {
      newHorizontalOffset = targetRight - horizontalViewport;
    }

    if (newHorizontalOffset != null) {
      final double maxScroll = _horizontalController.position.maxScrollExtent;
      final double clampedOffset = math.min(
        math.max(newHorizontalOffset, 0),
        maxScroll,
      );

      _horizontalController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SpreadsheetController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final Size currentSize = constraints.biggest;

        if (controller.visibleWindowSize != currentSize) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.updateVisibleWindowSize(currentSize);
          });
        }

        return Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (node, event) {
            return _handleKeyboard(context, event, controller);
          },
          // --------------------------------------------------------
          // SCROLLBAR CONFIGURATION
          // --------------------------------------------------------
          // 1. Vertical Scrollbar
          child: Scrollbar(
            controller: _verticalController,
            thumbVisibility: true,
            trackVisibility: true, // Makes it look like a desktop app
            // Important: Only react to Vertical updates
            notificationPredicate: (notification) =>
                notification.depth == 0 &&
                notification.metrics.axis == Axis.vertical,
            
            // 2. Horizontal Scrollbar
            child: Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              trackVisibility: true,
              // Important: Only react to Horizontal updates
              notificationPredicate: (notification) =>
                  notification.depth == 0 &&
                  notification.metrics.axis == Axis.horizontal,
                  
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) =>
                    _handleScrollNotification(notification, controller),
                child: TableView.builder(
                  verticalDetails: ScrollableDetails.vertical(
                    controller: _verticalController,
                  ),
                  horizontalDetails: ScrollableDetails.horizontal(
                    controller: _horizontalController,
                  ),
                  pinnedRowCount: 1,
                  pinnedColumnCount: 1,
                  rowCount: controller.tableViewRows + 1,
                  columnCount: controller.tableViewCols + 1,
                  columnBuilder: (index) => _buildColumnSpan(index),
                  rowBuilder: (index) => _buildRowSpan(index),
                  cellBuilder: (context, vicinity) =>
                      _buildCellDispatcher(context, vicinity, controller),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _handleScrollNotification(
    ScrollNotification notification,
    SpreadsheetController controller,
  ) {
    // We only care about vertical scrolling on the TableView for Infinite Loading
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }

    final metrics = notification.metrics;

    final double visibleBottomEdge = metrics.pixels + metrics.viewportDimension;
    final double rawRowsNeeded =
        (visibleBottomEdge - PageConstants.defaultColHeaderHeight) /
        PageConstants.defaultFontHeight;

    final int requiredRows = rawRowsNeeded.floor() + 1;

    final int targetRows = math.max(controller.minRows, requiredRows);

    if (notification is ScrollUpdateNotification) {
      if (targetRows > controller.tableViewRows) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.updateRowCount(targetRows);
        });
      }
    } else if (notification is ScrollEndNotification) {
      if (controller.tableViewRows > targetRows) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.updateRowCount(targetRows);
        });
      }
    }

    // Return false so the notification bubbles up to the Vertical Scrollbar
    return false;
  }

  // ... (Rest of the class: _handleKeyboard, _buildColumnSpan, _buildRowSpan, etc. remains unchanged)
  
  KeyEventResult _handleKeyboard(
    BuildContext context,
    KeyEvent event,
    SpreadsheetController ctrl,
  ) {
    if (ctrl.editingMode) {
      return KeyEventResult.ignored;
    }

    if (event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }

    final keyLabel = event.logicalKey.keyLabel.toLowerCase();
    final logicalKey = event.logicalKey;
    final isControl =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    final isAlt = HardwareKeyboard.instance.isAltPressed;

    if (logicalKey == LogicalKeyboardKey.enter ||
        logicalKey == LogicalKeyboardKey.numpadEnter) {
      ctrl.startEditing(); 
      return KeyEventResult.handled;
    }

    if (logicalKey == LogicalKeyboardKey.arrowUp) {
      ctrl.selectCell(
        max(ctrl.primarySelectedCell.x - 1, 0),
        ctrl.primarySelectedCell.y,
        false,
        true,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
      ctrl.selectCell(
        ctrl.primarySelectedCell.x + 1,
        ctrl.primarySelectedCell.y,
        false,
        true,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowLeft) {
      ctrl.selectCell(
        ctrl.primarySelectedCell.x,
        max(0, ctrl.primarySelectedCell.y - 1),
        false,
        true,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowRight) {
      ctrl.selectCell(
        ctrl.primarySelectedCell.x,
        ctrl.primarySelectedCell.y + 1,
        false,
        true,
      );
      return KeyEventResult.handled;
    }

    if (isControl && keyLabel == 'c') {
      ctrl.copySelectionToClipboard();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selection copied'),
          duration: Duration(milliseconds: 500),
        ),
      );
      return KeyEventResult.handled;
    } else if (isControl && keyLabel == 'v') {
      ctrl.pasteSelection();
      return KeyEventResult.handled;
    } else if (keyLabel == 'delete') {
      ctrl.delete();
      return KeyEventResult.handled;
    } else if (isControl && keyLabel == 'z') {
      ctrl.undo();
      return KeyEventResult.handled;
    } else if (isControl && keyLabel == 'y') {
      ctrl.redo();
      return KeyEventResult.handled;
    }

    final bool isPrintable =
        event.character != null &&
        event.character!.isNotEmpty &&
        !isControl &&
        !isAlt &&
        logicalKey.keyId > 32;

    if (isPrintable) {
      ctrl.startEditing(initialInput: event.character);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  TableSpan _buildColumnSpan(int index) {
    return TableSpan(
      extent: FixedTableSpanExtent(
        index == 0
            ? PageConstants.defaultRowHeaderWidth
            : PageConstants.defaultCellWidth,
      ),
    );
  }

  TableSpan _buildRowSpan(int index) {
    final controller = context.read<SpreadsheetController>();

    if (index == 0) {
      return const TableSpan(
        extent: FixedTableSpanExtent(PageConstants.defaultColHeaderHeight),
      );
    }

    final int dataRowIndex = index - 1;
    final double rowHeight = controller.getRowHeight(dataRowIndex);

    return TableSpan(extent: FixedTableSpanExtent(rowHeight));
  }

  Widget _buildCellDispatcher(
    BuildContext context,
    TableVicinity vicinity,
    SpreadsheetController controller,
  ) {
    final int r = vicinity.row;
    final int c = vicinity.column;

    if (r == 0 && c == 0) {
      return SpreadsheetSelectAllCorner(onTap: () => controller.selectAll());
    }
    if (r == 0) {
      return SpreadsheetColumnHeader(
        label: controller.getColumnLabel(c - 1),
        colIndex: c - 1,
        backgroundColor: controller.getColumnType(c - 1).color,
        onContextMenu: (details) => _showColumnContextMenu(
          context,
          controller,
          details.globalPosition,
          c - 1,
        ),
      );
    }
    if (c == 0) {
      return SpreadsheetRowHeader(rowIndex: r - 1);
    }

    final int dataRow = r - 1;
    final int dataCol = c - 1;

    final bool isEditingCell = controller.isCellEditing(dataRow, dataCol);

    return SpreadsheetDataCell(
      row: dataRow,
      col: dataCol,
      content: controller.getContent(dataRow, dataCol),
      isPrimarySelectedCell: controller.isPrimarySelectedCell(dataRow, dataCol),
      isSelected: controller.isCellSelected(dataRow, dataCol),
      isEditing: isEditingCell,
      previousContent: controller.previousContent,
      initialEditText: isEditingCell ? controller.currentInitialInput : null,
      onTap: () {
        if (controller.primarySelectedCell.x != dataRow ||
            controller.primarySelectedCell.y != dataCol) {
          controller.stopEditing(true);
        }
        controller.selectCell(dataRow, dataCol, false, true);
        _focusNode.requestFocus();
      },
      onDoubleTap: () {
        controller.startEditing();
      },
      onChanged: (newValue) {
        controller.onChanged(newValue);
      },
      onSave: (newValue, {bool moveUp = false}) {
        if (moveUp) {
          controller.selectCell(max(0, dataRow - 1), dataCol, false, true);
        } else {
          controller.selectCell(dataRow + 1, dataCol, false, true);
        }
        controller.stopEditing(true);
        _focusNode.requestFocus();
      },
      onEscape: (String previousContent) {
        controller.updateCell(
          controller.primarySelectedCell.x,
          controller.primarySelectedCell.y,
          previousContent,
        );
        controller.stopEditing(false);
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
    final result = await showMenu<ColumnType>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: ColumnType.values.map((entry) {
        return CheckedPopupMenuItem<ColumnType>(
          value: entry,
          checked: entry == currentType,
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
    BuildContext context,
    SpreadsheetController controller,
    Offset position,
    int col,
  ) async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
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
