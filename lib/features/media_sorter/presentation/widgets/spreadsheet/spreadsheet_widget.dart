import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/spreadsheet_scroll_request.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history/history_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/workbook_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/managers/spreadsheet_keyboard_delegate.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/selection_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/get_default_sizes.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/column_type_extensions.dart';
import 'spreadsheet_components.dart';
import 'dart:math' as math;
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';

class SpreadsheetWidget extends StatefulWidget {
  final SelectionDataStore selectionDataStore; 
  final LoadedSheetsDataStore dataStore;
  final SpreadsheetKeyboardDelegate spreadsheetKeyboardDelegate;

  // 2. Require it in the constructor
  const SpreadsheetWidget({
    super.key, 
    required this.selectionDataStore,
    required this.dataStore,
    required this.spreadsheetKeyboardDelegate,
  });

  @override
  State<SpreadsheetWidget> createState() => _SpreadsheetWidgetState();
}

class _SpreadsheetWidgetState extends State<SpreadsheetWidget> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  StreamSubscription? _scrollSubscription;
  bool _initialLayoutDone = false;
  bool _isProgrammaticScroll = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This ensures we subscribe as soon as the widget is linked to the Provider
    _subscribeToScrollEvents();
  }

  void _subscribeToScrollEvents() {
    final controller = context.read<WorkbookController>();
    // Prevent multiple subscriptions if dependencies change
    if (_scrollSubscription != null) return;
    // Listen to the new stream name and type
    _scrollSubscription = controller.scrollStream.listen(_handleScrollRequest);
  }

  // 2. CREATE A DISPATCHER METHOD
  void _handleScrollRequest(SpreadsheetScrollRequest request) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = context.read<WorkbookController>();
      final selectionController = context.read<SelectionController>();
      // Case A: Scroll to specific Cell (Your existing logic)
      if (request.cell != null) {
        _revealCell(
          request.cell!,
          controller,
          gridController,
          selectionController
        );
        return;
      }

      // Case B: Scroll to specific Pixel Offset (New logic)
      if (request.offsetX != null && _verticalController.hasClients) {
        _safelyScroll(_verticalController, request.offsetX!, request.animate);
      }

      if (request.offsetY != null && _horizontalController.hasClients) {
        _safelyScroll(_horizontalController, request.offsetY!, request.animate);
      }
    });
  }

  // 3. HELPER FOR SAFE SCROLLING
  void _safelyScroll(ScrollController controller, double offset, bool animate) {
    final double clampedOffset = math.max(offset, 0);

    if (animate) {
      _isProgrammaticScroll = true;
      controller.animateTo(
        clampedOffset,
        duration: const Duration(
          milliseconds: SpreadsheetConstants.animationDurationMs,
        ),
        curve: Curves.easeOut,
      );
      Future.delayed(
        const Duration(milliseconds: SpreadsheetConstants.animationDurationMs),
        () {
          _isProgrammaticScroll = false;
        },
      );
    } else {
      controller.jumpTo(clampedOffset);
    }
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
  void _revealCell(
    math.Point<int> cell,
    WorkbookController controller,
    GridController gridController,
    SelectionController selectionController,
  ) {
    if (!_verticalController.hasClients || !_horizontalController.hasClients) {
      return;
    }
    bool saveSelection = false;
    if (cell.x > 0) {
      // Vertical Logic
      final double targetTop =
          gridController.getTargetTop(cell.x) - gridController.getTargetTop(1);
      final double targetBottom = gridController.getTargetTop(cell.x + 1);
      final double verticalViewport =
          _verticalController.position.viewportDimension -
          controller.sheet.rowHeaderWidth;

      bool scroll = true;
      if (targetTop < _verticalController.offset) {
        saveSelection = true;
        widget.selectionDataStore.scrollOffsetX = targetTop;
      } else if (targetBottom >
          _verticalController.offset + verticalViewport) {
        saveSelection = true;
        widget.selectionDataStore.scrollOffsetX = targetBottom - verticalViewport;
        gridController.updateRowColCount(visibleHeight: targetBottom);
      } else {
        scroll = false;
      }

      if (scroll) {
        _safelyScroll(
          _verticalController,
          widget.selectionDataStore.scrollOffsetX,
          true,
        );
      }
    }

    if (cell.y > 0) {
      // Horizontal Logic
      final double targetLeft =
          gridController.getTargetLeft(cell.y) -
          gridController.getTargetLeft(1);
      final double targetRight = gridController.getTargetLeft(cell.y + 1);
      final double horizontalViewport =
          _horizontalController.position.viewportDimension -
          controller.sheet.rowHeaderWidth;

      bool scroll = true;
      if (targetLeft < _horizontalController.offset) {
        saveSelection = true;
        widget.selectionDataStore.scrollOffsetY = targetLeft;
      } else if (targetRight >
          widget.selectionDataStore.scrollOffsetY + horizontalViewport) {
        saveSelection = true;
        widget.selectionDataStore.scrollOffsetY = targetRight - horizontalViewport;
        gridController.updateRowColCount(visibleWidth: targetRight);
      } else {
        scroll = false;
      }

      if (scroll) {
        _safelyScroll(
          _horizontalController,
          widget.selectionDataStore.scrollOffsetY,
          true,
        );
      }
    }
    if (saveSelection) {
      widget.selectionDataStore.saveSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WorkbookController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_initialLayoutDone) {
          _initialLayoutDone = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              controller.updateRowColCount(
                visibleHeight:
                    constraints.maxHeight - controller.sheet.colHeaderHeight,
                visibleWidth:
                    constraints.maxWidth - controller.sheet.rowHeaderWidth,
                save: false,
              );
            }
          });
        }

        return Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (node, event) {
            return widget.spreadsheetKeyboardDelegate.handleKeyboard(context, event);
          },
          // --------------------------------------------------------
          // SCROLLBAR CONFIGURATION
          // --------------------------------------------------------
          // 1. Force RTL Directionality to move Vertical Scrollbar to the LEFT
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scrollbar(
              controller: _verticalController,
              thumbVisibility: true,
              trackVisibility: true,
              // Important: Only react to Vertical updates
              notificationPredicate: (notification) =>
                  notification.depth == 0 &&
                  notification.metrics.axis == Axis.vertical,

              // 2. Reset Directionality to LTR for content and Horizontal Scrollbar
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Scrollbar(
                  controller: _horizontalController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  // Important: Only react to Horizontal updates
                  notificationPredicate: (notification) =>
                      notification.depth == 0 &&
                      notification.metrics.axis == Axis.horizontal,

                  child: ListenableBuilder(
                    listenable: widget.selectionDataStore,
                    builder: (context, child) {
                      return NotificationListener<ScrollNotification>(
                        onNotification: (notification) =>
                            _handleScrollNotification(notification, controller),
                        child: TableView.builder(
                          verticalDetails: ScrollableDetails.vertical(
                            controller: _verticalController,
                          ),
                          horizontalDetails: ScrollableDetails.horizontal(
                            controller: _horizontalController,
                          ),
                          pinnedRowCount: min(2, widget.selectionDataStore.tableViewRows + 1),
                          pinnedColumnCount: min(2, widget.selectionDataStore.tableViewCols + 1),
                          rowCount: widget.selectionDataStore.tableViewRows + 1,
                          columnCount: widget.selectionDataStore.tableViewCols + 1,
                          columnBuilder: (index) => _buildColumnSpan(index),
                          rowBuilder: (index) =>
                              _buildRowSpan(index, controller),
                          cellBuilder: (context, vicinity) => _buildCellDispatcher(
                            context,
                            vicinity,
                            controller,
                          ),
                        ),
                      );
                    }
                  ),
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
    WorkbookController controller,
  ) {
    if (notification is ScrollUpdateNotification) {
      if (_isProgrammaticScroll) {
        return false;
      }
      if (notification.metrics.axis == Axis.vertical) {
        controller.updateRowColCount(
          visibleHeight:
              notification.metrics.pixels +
              notification.metrics.viewportDimension -
              controller.sheet.colHeaderHeight,
        );
      } else if (notification.metrics.axis == Axis.horizontal) {
        controller.updateRowColCount(
          visibleWidth:
              notification.metrics.pixels +
              notification.metrics.viewportDimension -
              controller.sheet.rowHeaderWidth,
        );
      }
    }
    return false;
  }

  TableSpan _buildColumnSpan(int index) {
    return TableSpan(
      extent: FixedTableSpanExtent(
        index == 0
            ? PageConstants.defaultRowHeaderWidth
            : GetDefaultSizes.getDefaultCellWidth(),
      ),
    );
  }

  TableSpan _buildRowSpan(
    int index,
    WorkbookController controller,
  ) {
    if (index == 0) {
      return TableSpan(
        extent: FixedTableSpanExtent(controller.sheet.colHeaderHeight),
      );
    }

    final int dataRowIndex = index - 1;
    final double rowHeight = controller.getRowHeight(dataRowIndex);

    return TableSpan(extent: FixedTableSpanExtent(rowHeight));
  }

  Widget _buildCellDispatcher(
    BuildContext context,
    TableVicinity vicinity,
    WorkbookController controller,
    SheetDataController dataController,
    SelectionController selectionController,
    HistoryService historyService,
  ) {
    final int r = vicinity.row;
    final int c = vicinity.column;

    if (r == 0 && c == 0) {
      return SpreadsheetSelectAllCorner(onTap: () => controller.selectAll());
    }
    if (r == 0) {
      return SpreadsheetColumnHeader(
        label: GetNames.getColumnLabel(c - 1),
        colIndex: c - 1,
        backgroundColor: GetNames.getColumnType(
          controller.sheetContent,
          c - 1,
        ).color,
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

    final bool isEditingCell = controller.isCellEditing(
      dataRow,
      dataCol,
    );

    return SpreadsheetDataCell(
      row: dataRow,
      col: dataCol,
      content: controller.getCellContent(dataRow, dataCol),
      isValid: controller.isRowValid(dataRow),
      isPrimarySelectedCell: controller.isPrimarySelectedCell(
        dataRow,
        dataCol,
      ),
      isSelected: controller.isCellSelected(dataRow, dataCol),
      isEditing: isEditingCell,
      previousContent: controller.previousContent,
      onTap: () {
        if (controller.primarySelectedCell.x != dataRow ||
            controller.primarySelectedCell.y != dataCol) {
          controller.stopEditing();
        }
        controller.setPrimarySelection(dataRow, dataCol, false, true);
        _focusNode.requestFocus();
      },
      onDoubleTap: () {
        controller.startEditing();
      },
      onTapOutside: selectionController.stopEditing,
      onChanged: (newValue) {
        controller.onChanged(newValue);
      },
      onSave: (String newValue, String previousContent, {bool moveUp = false}) {
        if (moveUp) {
          selectionController.setPrimarySelection(
            max(0, dataRow - 1),
            dataCol,
            false,
            true,
          );
        } else {
          selectionController.setPrimarySelection(dataRow + 1, dataCol, false, true);
        }
        selectionController.stopEditing();
        historyService.commitHistory(
          [CellUpdate(
            rowId: dataRow,
            colId: dataCol,
            previousValue: previousContent,
            newValue: newValue,
          )]
        );
        _focusNode.requestFocus();
      },
      onEscape: (String previousContent) {
        controller.updateCell(
          controller.primarySelectedCell.x,
          controller.primarySelectedCell.y,
          previousContent,
        );
        controller.stopEditing(updateHistory: false);
        _focusNode.requestFocus();
      },
    );
  }

  Future<void> _showTypeMenu(
    BuildContext context,
    WorkbookController controller,
    SheetDataController dataController,
    Offset position,
    int col,
  ) async {
    final currentType = GetNames.getColumnType(controller.sheetContent, col);
    final List<PopupMenuEntry<dynamic>> items = ColumnType.values
        .map<PopupMenuEntry<dynamic>>((entry) {
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
        })
        .toList();
    items.add(const PopupMenuDivider());
    items.add(
      const PopupMenuItem<String>(
        value: 'default_sequence',
        child: Row(
          children: [
            Icon(Icons.restore, size: 16), // Use a relevant icon
            SizedBox(width: 8),
            Text('Default Sequence'),
          ],
        ),
      ),
    );

    final result = await showMenu<dynamic>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: items,
    );

    if (result != null) {
      if (result is ColumnType) {
        controller.setColumnType(col, result);
      } else if (result == 'default_sequence') {
        // Call the method on your controller to reset the sequence
        // Ensure this method exists in your SpreadsheetController
        dataController.applyDefaultColumnSequence();
      }
    }
  }

  void _showColumnContextMenu(
    BuildContext context,
    WorkbookController controller,
    Offset position,
    int col,
  ) async {
    final List<PopupMenuEntry<String>> items = [];
    if (col > 0) {
      items.add(
        const PopupMenuItem(value: 'change_type', child: Text('Change Type ▶')),
      );
    }
    if (items.isEmpty) {
      return; // No items to show
    }
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: items,
    );

    if (!context.mounted) return;

    if (result == 'change_type') {
      await _showTypeMenu(context, controller, context.read<SheetDataController>(), position, col);
    } else if (result != null) {
      debugPrint("Action $result on column $col");
    }
  }
}
