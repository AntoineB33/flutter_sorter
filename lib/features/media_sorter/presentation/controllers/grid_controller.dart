import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/data/models/update_data.dart';
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

  int get currentSheetId => workbookUsecase.currentSheetId;

  GridController(
    this.sheetDataUsecase,
    this.gridUsecase,
    this.workbookUsecase,
    this.selectionUsecase,
  );

  double colHeaderHeight() {
    try {
      return gridUsecase.getLayout(currentSheetId).colHeaderHeight;
    } catch (e) {
      return PageConstants.defaultColHeaderHeight;
    }
  }

  double getRowHeightCurrentSheet(int rowId) {
    return gridUsecase.getRowHeight(currentSheetId, rowId);
  }

  double getRowHeight(int sheetId, int rowId) {
    return gridUsecase.getRowHeight(sheetId, rowId);
  }

  int rowCount(int sheetId) {
    return sheetDataUsecase.rowCount(sheetId);
  }

  int colCount(int sheetId) {
    return sheetDataUsecase.colCount(sheetId);
  }

  int minRows(int sheetId, int rowCount, double height) {
    return gridUsecase.minRows(sheetId, rowCount, height);
  }

  int minCols(int sheetId, int colCount, double width) {
    return gridUsecase.minCols(sheetId, colCount, width);
  }

  void adjustRowHeightAfterUpdate(
    int sheetId,
    IMap<String, UpdateUnit> updateData,
  ) {
    gridUsecase.adjustRowHeightAfterUpdate(sheetId, updateData);
  }

  void scrollToCell() {
    final layout = gridUsecase.getLayout(currentSheetId);
    int rowId = selectionUsecase.primarySelectedCellX;
    int colId = selectionUsecase.primarySelectedCellY;
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

      if (targetTop < layout.scrollOffsetX) {
        layout.scrollOffsetX = targetTop;
      } else if (targetBottom > verticalViewport) {
        layout.scrollOffsetX += targetBottom - verticalViewport;
        row0TopToScreenBottomHeight = targetBottom;
        updateRowCount(currentSheetId);
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

      if (targetLeft < layout.scrollOffsetY) {
        layout.scrollOffsetY = targetLeft;
      } else if (targetRight > colALeftToScreenRightWidth) {
        layout.scrollOffsetY += targetRight - colALeftToScreenRightWidth;
        colALeftToScreenRightWidth = targetRight;
        updateColCount(currentSheetId);
      } else {
        scrollX = false;
      }
    }
    if (scrollX || scrollY) {
      scrollTo(
        ScrollRequest(
          xOffset: scrollX ? layout.scrollOffsetY : null,
          yOffset: scrollY ? layout.scrollOffsetX : null,
        ),
      );
    }
  }

  void scrollToLastSelection() {
    final layout = gridUsecase.getLayout(currentSheetId);
    scrollTo(
      ScrollRequest(
        xOffset: layout.scrollOffsetY,
        yOffset: layout.scrollOffsetX,
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
    double colHeaderHeight = gridUsecase
        .getLayout(currentSheetId)
        .colHeaderHeight;
    double rowHeaderWidth = gridUsecase
        .getLayout(currentSheetId)
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
    final layout = gridUsecase.getLayout(currentSheetId);
    if (heightPixels != null) {
      layout.scrollOffsetX = heightPixels;
    }
    if (widthPixels != null) {
      layout.scrollOffsetY = widthPixels;
    }
    double? row0TopToScreenBottomHeight =
        (heightViewport != null || heightPixels != null)
        ? heightPixels ??
              layout.scrollOffsetX +
                  (heightViewport ?? this.row0TopToScreenBottomHeight)
        : null;
    double? colALeftToScreenRightWidth =
        (widthViewport != null || widthPixels != null)
        ? widthPixels ??
              layout.scrollOffsetY +
                  (widthViewport ?? this.colALeftToScreenRightWidth)
        : null;
    if (row0TopToScreenBottomHeight != null) {
      this.row0TopToScreenBottomHeight = row0TopToScreenBottomHeight;
      updateRowCount(currentSheetId);
    }
    if (colALeftToScreenRightWidth != null) {
      this.colALeftToScreenRightWidth = colALeftToScreenRightWidth;
      updateColCount(currentSheetId);
    }
  }

  void updateRowCount(int sheetId) {
    int targetRows = tableViewRows;
    targetRows = minRows(
      sheetId,
      rowCount(sheetId),
      row0TopToScreenBottomHeight,
    );
    if (targetRows != tableViewRows) {
      tableViewRows = targetRows;
      notifyListeners();
    }
  }

  void updateColCount(int sheetId) {
    int targetCols = tableViewCols;
    targetCols = minCols(
      sheetId,
      colCount(sheetId),
      colALeftToScreenRightWidth,
    );
    if (targetCols != tableViewCols) {
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
