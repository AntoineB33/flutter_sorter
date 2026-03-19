import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trying_flutter/features/media_sorter/application/coordinators/spreadsheet_coordinator.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/workbook_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/get_default_sizes.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/column_type_extensions.dart';
import 'spreadsheet_components.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';

class SpreadsheetWidget extends StatefulWidget {
  final GridController gridController;
  final SelectionController selectionController;
  final WorkbookController workbookController;
  final SheetDataController sheetDataController;
  final TreeController treeController;
  final SpreadsheetCoordinator spreadsheetCoordinator;

  // 2. Require it in the constructor
  const SpreadsheetWidget(
    this.gridController,
    this.selectionController,
    this.workbookController,
    this.sheetDataController,
    this.treeController,
    this.spreadsheetCoordinator, {
    super.key,
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
  bool _isProgrammaticScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollSubscription = widget.gridController.onScrollEvent.listen((
      request,
    ) async {
      if (!_verticalController.hasClients ||
          !_horizontalController.hasClients) {
        return;
      }
      _isProgrammaticScroll = true;
      List<Future<void>> animations = [];

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (request.yOffset != null && _verticalController.hasClients) {
          animations.add(
            _verticalController.animateTo(
              request.yOffset!,
              duration: request.duration,
              curve: request.curve,
            ),
          );
        }

        if (request.xOffset != null && _horizontalController.hasClients) {
          animations.add(
            _horizontalController.animateTo(
              request.xOffset!,
              duration: request.duration,
              curve: request.curve,
            ),
          );
        }
      });

      // Run both animations at the exact same time and wait for them to finish
      if (animations.isNotEmpty) {
        await Future.wait(animations);
      }

      // 3. Resets safely ONLY after the animation completes
      if (mounted) {
        _isProgrammaticScroll = false;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _scrollSubscription?.cancel();
    _verticalController.dispose();
    _horizontalController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SpreadsheetCoordinator coordinator = context
        .read<SpreadsheetCoordinator>();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_initialLayoutDone) {
          _initialLayoutDone = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              widget.gridController.initialLayoutConstraints(
                maxHeight: constraints.maxHeight,
                maxWidth: constraints.maxWidth,
              );
            }
          });
        }

        return Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (node, event) {
            return coordinator.handle(context, event);
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
                    listenable: widget.spreadsheetCoordinator,
                    builder: (context, child) {
                      return NotificationListener<ScrollNotification>(
                        onNotification: (notification) =>
                            _handleScrollNotification(
                              notification,
                              widget.workbookController,
                              widget.gridController,
                            ),
                        child: TableView.builder(
                          verticalDetails: ScrollableDetails.vertical(
                            controller: _verticalController,
                          ),
                          horizontalDetails: ScrollableDetails.horizontal(
                            controller: _horizontalController,
                          ),
                          pinnedRowCount: min(
                            2,
                            widget.gridController.tableViewRows + 1,
                          ),
                          pinnedColumnCount: min(
                            2,
                            widget.gridController.tableViewCols + 1,
                          ),
                          rowCount: widget.gridController.tableViewRows + 1,
                          columnCount: widget.gridController.tableViewCols + 1,
                          columnBuilder: (index) => _buildColumnSpan(index),
                          rowBuilder: (index) => _buildRowSpan(
                            index,
                            widget.gridController,
                            widget.gridController.colHeaderHeight(),
                          ),
                          cellBuilder: (context, vicinity) =>
                              _buildCellDispatcher(
                                context,
                                vicinity,
                                widget.spreadsheetCoordinator,
                                widget.workbookController,
                                widget.sheetDataController,
                                widget.selectionController,
                                widget.sheetDataController,
                                widget.treeController,
                                widget.gridController,
                              ),
                        ),
                      );
                    },
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
    GridController gridController,
  ) {
    if (notification is ScrollUpdateNotification) {
      if (_isProgrammaticScroll) {
        return false;
      }
      if (notification.metrics.axis == Axis.vertical) {
        gridController.updateRowColCountCurrentSheet(
          heightPixels: notification.metrics.pixels,
          heightViewport: notification.metrics.viewportDimension,
        );
      } else if (notification.metrics.axis == Axis.horizontal) {
        gridController.updateRowColCountCurrentSheet(
          widthPixels: notification.metrics.pixels,
          widthViewport: notification.metrics.viewportDimension,
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
    GridController gridController,
    double colHeaderHeight,
  ) {
    if (index == 0) {
      return TableSpan(extent: FixedTableSpanExtent(colHeaderHeight));
    }

    final int dataRowIndex = index - 1;
    final double rowHeight = gridController.getRowHeightCurrentSheet(
      dataRowIndex,
    );

    return TableSpan(extent: FixedTableSpanExtent(rowHeight));
  }

  Widget _buildCellDispatcher(
    BuildContext context,
    TableVicinity vicinity,
    SpreadsheetCoordinator coordinator,
    WorkbookController workbookController,
    SheetDataController dataController,
    SelectionController selectionController,
    SheetDataController sheetDataController,
    TreeController treeController,
    GridController gridController,
  ) {
    final int r = vicinity.row;
    final int c = vicinity.column;

    if (r == 0 && c == 0) {
      return SpreadsheetSelectAllCorner(
        onTap: () => selectionController.selectAll(),
      );
    }
    if (r == 0) {
      return SpreadsheetColumnHeader(
        label: GetNames.getColumnLabel(c - 1),
        colIndex: c - 1,
        backgroundColor: GetNames.getColumnType(
          widget.sheetDataController.sheetContent,
          c - 1,
        ).color,
        onContextMenu: (details) => _showColumnContextMenu(
          context,
          coordinator,
          workbookController,
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

    final bool isEditingCell = selectionController.isCellEditing(
      dataRow,
      dataCol,
    );

    return SpreadsheetDataCell(
      row: dataRow,
      col: dataCol,
      content: sheetDataController.getCellContentCurrentSheet(dataRow, dataCol),
      isValid: gridController.isRowValid(dataRow),
      isPrimarySelectedCell: selectionController.isPrimarySelectedCell(
        dataRow,
        dataCol,
      ),
      isSelected: selectionController.isCellSelected(dataRow, dataCol),
      isEditing: isEditingCell,
      onTap: () {
        coordinator.setPrimarySelection(dataRow, dataCol, false);
        _focusNode.requestFocus();
      },
      onDoubleTap: () {
        coordinator.startEditing();
      },
      onTapOutside: () => selectionController.stopEditing(false),
      onChanged: (newValue) {
        coordinator.setCellContent(newValue);
      },
      onSave: (String newValue, {bool moveUp = false}) {
        coordinator.onSave(newValue, moveUp);
        _focusNode.requestFocus();
      },
      onEscape: () {
        selectionController.stopEditing(false);
        _focusNode.requestFocus();
      },
    );
  }

  Future<void> _showTypeMenu(
    BuildContext context,
    SpreadsheetCoordinator coordinator,
    WorkbookController workbookController,
    SheetDataController sheetDataController,
    Offset position,
    int col,
  ) async {
    final currentType = GetNames.getColumnType(
      sheetDataController.sheetContent,
      col,
    );
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
        coordinator.setColumnType(col, result);
      } else if (result == 'default_sequence') {
        // Call the method on your controller to reset the sequence
        // Ensure this method exists in your SpreadsheetController
        coordinator.applyDefaultColumnSequence();
      }
    }
  }

  void _showColumnContextMenu(
    BuildContext context,
    SpreadsheetCoordinator coordinator,
    WorkbookController workbookController,
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
      await _showTypeMenu(
        context,
        coordinator,
        workbookController,
        context.read<SheetDataController>(),
        position,
        col,
      );
    }
  }
}
