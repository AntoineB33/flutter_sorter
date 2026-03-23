import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/grid_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/selection_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/workbook_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/presentation/models/scroll_request.dart';

class GridController extends ChangeNotifier {
  // --- states ---
  final _scrollEventController = StreamController<ScrollRequest>.broadcast();
  Stream<ScrollRequest> get onScrollEvent => _scrollEventController.stream;

  // Size of the window: useful to determine how many rows and columns to show.
  // Informed by the UI at startup and each time the user resizes it.
  double row0TopToScreenBottomHeight = 0.0;
  double colALeftToScreenRightWidth = 0.0;

  // Number of cells in the tableView widget.
  int tableViewRows = 0;
  int tableViewCols = 0;

  final SheetDataUsecase sheetDataUsecase;
  final GridUsecase gridUsecase;
  final WorkbookUsecase workbookUsecase;
  final SelectionUsecase selectionUsecase;

  String? get currentSheetId => workbookUsecase.currentSheetId;

  GridController(
    this.sheetDataUsecase,
    this.gridUsecase,
    this.workbookUsecase,
    this.selectionUsecase,
  );

  double colHeaderHeight() {
    try {
      return sheetDataUsecase.getSheet(currentSheetId).colHeaderHeight;
    } catch (e) {
      return PageConstants.defaultColHeaderHeight;
    }
  }

  double getRowHeightCurrentSheet(int rowId) {
    return gridUsecase.getRowHeight(currentSheetId, rowId);
  }

  double getRowHeight(String sheetId, int rowId) {
    return gridUsecase.getRowHeight(sheetId, rowId);
  }

  int rowCount(String sheetId) {
    return sheetDataUsecase.rowCount(sheetId);
  }

  int colCount(String sheetId) {
    return sheetDataUsecase.colCount(sheetId);
  }

  int minRows(String sheetId, int rowCount, double height) {
    return gridUsecase.minRows(sheetId, rowCount, height);
  }

  int minCols(String sheetId, int colCount, double width) {
    return gridUsecase.minCols(sheetId, colCount, width);
  }

  void adjustRowHeightAfterUpdate(String sheetId, List<UpdateUnit> updateData) {
    gridUsecase.adjustRowHeightAfterUpdate(sheetId, updateData);
  }

  void scrollToCell() {
    final selection = selectionUsecase
        .getSelectionData(currentSheetId);
    final primarySelectedCell = selection
        .primarySelectedCell;
    int rowId = primarySelectedCell.x;
    int colId = primarySelectedCell.y;
    SelectionData lastSelection = selectionUsecase.getSelectionData(
      currentSheetId,
    );
    bool scrollX = true;
    bool scrollY = true;
    if (rowId > 0) {
      // Vertical Logic
      final double targetTop =
          gridUsecase.getTargetTop(currentSheetId, rowId) -
          gridUsecase.getTargetTop(currentSheetId, 1);
      final double targetBottom = gridUsecase.getTargetTop(
        currentSheetId,
        rowId + 1,
      );
      final double verticalViewport = row0TopToScreenBottomHeight;

      if (targetTop < selection.scrollOffsetX) {
        lastSelection.scrollOffsetX = targetTop;
      } else if (targetBottom > verticalViewport) {
        lastSelection.scrollOffsetX += targetBottom - verticalViewport;
        updateRowColCount(
          currentSheetId,
          true,
          false
        );
      } else {
        scrollY = false;
      }
    }

    if (colId > 0) {
      // Horizontal Logic
      final double targetLeft =
          gridUsecase.getTargetLeft(currentSheetId, colId) -
          gridUsecase.getTargetLeft(currentSheetId, 1);
      final double targetRight = gridUsecase.getTargetLeft(
        currentSheetId,
        colId + 1,
      );

      if (targetLeft < selection.scrollOffsetY) {
        lastSelection.scrollOffsetY = targetLeft;
      } else if (targetRight > colALeftToScreenRightWidth) {
        lastSelection.scrollOffsetY += targetRight - colALeftToScreenRightWidth;
        updateRowColCount(
          currentSheetId,
          false,
          true,
        );
      } else {
        scrollX = false;
      }
    }
    if (scrollX || scrollY) {
      scrollTo(
        ScrollRequest(
          xOffset: scrollX ? lastSelection.scrollOffsetY : null,
          yOffset: scrollY ? lastSelection.scrollOffsetX : null,
        ),
      );
    }
  }

  void scrollToLastSelection() {
    SelectionData lastSelection = selectionUsecase.getSelectionData(
      currentSheetId,
    );
    scrollTo(
      ScrollRequest(
        xOffset: lastSelection.scrollOffsetY,
        yOffset: lastSelection.scrollOffsetX,
      ),
    );
  }

  void scrollTo(ScrollRequest request) {
    _scrollEventController.add(request);
  }

  void initialLayoutConstraints({
    required double maxHeight,
    required double maxWidth,
  }) {
    double colHeaderHeight = sheetDataUsecase
        .getSheet(currentSheetId)
        .colHeaderHeight;
    double rowHeaderWidth = sheetDataUsecase
        .getSheet(currentSheetId)
        .rowHeaderWidth;
    updateRowColCountCurrentSheet(
      heightViewport: maxHeight - colHeaderHeight,
      widthViewport: maxWidth - rowHeaderWidth,
    );
  }

  void updateRowColCountCurrentSheet({
    double? heightPixels,
    double? heightViewport,
    double? widthPixels,
    double? widthViewport,
  }) {
    final selection = selectionUsecase.getSelectionData(currentSheetId);
    if (heightPixels != null) {
      selection.scrollOffsetX = heightPixels;
    }
    if (widthPixels != null) {
      selection.scrollOffsetY = widthPixels;
    }
    double? row0TopToScreenBottomHeight = (heightViewport != null || heightPixels != null)
        ? heightPixels ?? selection.scrollOffsetX + (heightViewport ?? this.row0TopToScreenBottomHeight)
        : null;
    double? colALeftToScreenRightWidth = (widthViewport != null || widthPixels != null)
        ? widthPixels ?? selection.scrollOffsetY + (widthViewport ?? this.colALeftToScreenRightWidth)
        : null;
    updateRowColCount(
      currentSheetId,
      row0TopToScreenBottomHeight != null,
      colALeftToScreenRightWidth != null,
    );
  }

  void updateRowColCount(
    String sheetId,
    bool updateRowCount,
    bool updateColCount
    ) {
    int targetRows = tableViewRows;
    int targetCols = tableViewCols;
    if (updateRowCount) {
      targetRows = minRows(
        sheetId,
        rowCount(sheetId),
        row0TopToScreenBottomHeight,
      );
    }
    if (updateColCount) {
      targetCols = minCols(
        sheetId,
        colCount(sheetId),
        colALeftToScreenRightWidth,
      );
    }
    if (targetRows != tableViewRows || targetCols != tableViewCols) {
      tableViewRows = targetRows;
      tableViewCols = targetCols;
      notifyListeners();
    }
  }

  bool isRowValid(int rowId) {
    return gridUsecase.isRowValid(rowId);
  }

  @override
  void dispose() {
    _scrollEventController.close();
    super.dispose();
  }
}
