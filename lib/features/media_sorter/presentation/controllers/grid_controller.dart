import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/grid_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/selection_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/workbook_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/models/scroll_request.dart';

class GridController extends ChangeNotifier {
  // --- states ---
  final _scrollEventController = StreamController<ScrollRequest>.broadcast();
  Stream<ScrollRequest> get onScrollEvent => _scrollEventController.stream;

  // Size of the window: useful to determine how many rows and columns to show.
  // Informed by the UI at startup and each time the user resizes it.
  double row1ToScreenBottomHeight = 0.0;
  double colBToScreenRightWidth = 0.0;
  double offsetX = 0.0;
  double offsetY = 0.0;

  // Number of cells in the tableView widget.
  int tableViewRows = 0;
  int tableViewCols = 0;

  final SheetDataUsecase sheetDataUsecase;
  final GridUsecase gridUsecase;
  final WorkbookUsecase workbookUsecase;
  final SelectionUsecase selectionUsecase;

  String get currentSheetId => workbookUsecase.currentSheetId;

  GridController(
    this.sheetDataUsecase,
    this.gridUsecase,
    this.workbookUsecase,
    this.selectionUsecase,
  );

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
    updateRowColCount(
      sheetId,
      row1ToScreenBottomHeight: row1ToScreenBottomHeight,
      colBToScreenRightWidth: colBToScreenRightWidth,
    );
  }

  void scrollToCell() {
    final selection = selectionUsecase
        .getSelectionData(currentSheetId)
        .primarySelectedCell;
    int rowId = selection.x;
    int colId = selection.y;
    SelectionData lastSelection = selectionUsecase.getSelectionData(
      currentSheetId,
    );
    bool scrollX = true;
    bool scrollY = true;
    SheetData currentSheet = sheetDataUsecase.getSheet(currentSheetId);
    if (rowId > 0) {
      // Vertical Logic
      final double targetTop =
          gridUsecase.getTargetTop(currentSheetId, rowId) -
          gridUsecase.getTargetTop(currentSheetId, 1);
      final double targetBottom = gridUsecase.getTargetTop(
        currentSheetId,
        rowId + 1,
      );
      final double verticalViewport = row1ToScreenBottomHeight;

      if (targetTop < offsetX) {
        lastSelection.scrollOffsetX = targetTop;
      } else if (targetBottom > verticalViewport) {
        lastSelection.scrollOffsetX = targetBottom - verticalViewport;
        updateRowColCount(
          currentSheetId,
          row1ToScreenBottomHeight: targetBottom,
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

      if (targetLeft < offsetY) {
        lastSelection.scrollOffsetY = targetLeft;
      } else if (targetRight > colBToScreenRightWidth) {
        lastSelection.scrollOffsetY = targetRight - colBToScreenRightWidth;
        updateRowColCount(currentSheetId, colBToScreenRightWidth: targetRight);
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

  void updateRowColCountCurrentSheet({
    double? heightPixels,
    double? heightViewport,
    double? widthPixels,
    double? widthViewport,
  }) {
    if (heightPixels != null) {
      offsetX = heightPixels;
    }
    if (widthPixels != null) {
      offsetY = widthPixels;
    }
    double? row1ToScreenBottomHeight =
        heightViewport != null
        ? heightPixels ?? offsetX +
              heightViewport -
              sheetDataUsecase.getSheet(currentSheetId).colHeaderHeight
        : null;
    double? colBToScreenRightWidth = widthViewport != null
        ? widthPixels ?? offsetY +
              widthViewport -
              sheetDataUsecase.getSheet(currentSheetId).rowHeaderWidth
        : null;
    updateRowColCount(
      currentSheetId,
      row1ToScreenBottomHeight: row1ToScreenBottomHeight,
      colBToScreenRightWidth: colBToScreenRightWidth,
    );
  }

  /// update the number of rows and columns in the tableView based on the parameters and minRows and minCols functions.
  void updateRowColCount(
    String sheetId, {
    double? row1ToScreenBottomHeight,
    double? colBToScreenRightWidth,
  }) {
    int targetRows = tableViewRows;
    int targetCols = tableViewCols;
    if (row1ToScreenBottomHeight != null) {
      this.row1ToScreenBottomHeight = row1ToScreenBottomHeight;
      targetRows = minRows(
        sheetId,
        rowCount(sheetId),
        row1ToScreenBottomHeight,
      );
    }
    if (colBToScreenRightWidth != null) {
      this.colBToScreenRightWidth = colBToScreenRightWidth;
      targetCols = minCols(sheetId, colCount(sheetId), colBToScreenRightWidth);
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
