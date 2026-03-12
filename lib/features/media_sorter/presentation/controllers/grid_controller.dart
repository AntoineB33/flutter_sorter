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

  // Number of cells in the tableView widget.
  int tableViewRows = 0;
  int tableViewCols = 0;

  final SheetDataUsecase sheetDataUsecase;
  final GridUsecase gridUsecase;
  final WorkbookUseCase workbookUsecase;
  final SelectionUsecase selectionUsecase;

  GridController(this.sheetDataUsecase, this.gridUsecase, this.workbookUsecase, this.selectionUsecase);


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
      false,
      visibleHeight: row1ToScreenBottomHeight,
      visibleWidth: colBToScreenRightWidth,
    );
  }
  
  bool scrollToCell(ScrollController verticalController, ScrollController horizontalController, int rowId, int colId) {
    String currentSheetId = workbookUsecase.currentSheetId;
    SelectionData lastSelection = selectionUsecase.getSelectionData(currentSheetId);
    bool saveSelection = false;
    bool scrollX = true;
    bool scrollY = true;
    SheetData currentSheet = sheetDataUsecase.getSheet(currentSheetId);
    if (rowId > 0) {
      // Vertical Logic
      final double targetTop = gridUsecase.getTargetTop(currentSheetId, rowId) - gridUsecase.getTargetTop(currentSheetId, 1);
      final double targetBottom = gridUsecase.getTargetTop(currentSheetId, rowId + 1);
      final double verticalViewport =
          verticalController.position.viewportDimension -
          currentSheet.rowHeaderWidth;

      if (targetTop < verticalController.offset) {
        saveSelection = true;
        lastSelection.scrollOffsetX = targetTop;
      } else if (targetBottom > verticalController.offset + verticalViewport) {
        saveSelection = true;
        lastSelection.scrollOffsetX = targetBottom - verticalViewport;
        updateRowColCount(currentSheetId, true, visibleHeight: targetBottom);
      } else {
        scrollY = false;
      }
    }

    if (colId > 0) {
      // Horizontal Logic
      final double targetLeft = gridUsecase.getTargetLeft(currentSheetId, colId) - gridUsecase.getTargetLeft(currentSheetId, 1);
      final double targetRight = gridUsecase.getTargetLeft(currentSheetId, colId + 1);
      final double horizontalViewport =
          horizontalController.position.viewportDimension -
          currentSheet.rowHeaderWidth;

      if (targetLeft < horizontalController.offset) {
        saveSelection = true;
        lastSelection.scrollOffsetY = targetLeft;
      } else if (targetRight >
          lastSelection.scrollOffsetY + horizontalViewport) {
        saveSelection = true;
        lastSelection.scrollOffsetY = targetRight - horizontalViewport;
        updateRowColCountCurrentSheet(true, visibleWidth: targetRight);
      } else {
        scrollX = false;
      }
    }
    if (scrollX || scrollY) {
      _scrollEventController.add(
        ScrollRequest(
          xOffset: scrollX ? lastSelection.scrollOffsetY : null,
          yOffset: scrollY ? lastSelection.scrollOffsetX : null,
        ),
      );
    }
    return saveSelection;
  }

  void updateRowColCountCurrentSheet(
    bool notify,{
    double? visibleHeight,
    double? visibleWidth,
  }) {
    String sheetId = workbookUsecase.currentSheetId;
    updateRowColCount(
      sheetId,
      false,
      visibleHeight: row1ToScreenBottomHeight,
      visibleWidth: colBToScreenRightWidth,
    );
  }

  void updateRowColCount(
    String sheetId,
    bool notify,{
    double? visibleHeight,
    double? visibleWidth,
  }) {
    int targetRows = tableViewRows;
    int targetCols = tableViewCols;
    if (visibleHeight != null) {
      row1ToScreenBottomHeight = visibleHeight;
      targetRows = minRows(
        sheetId,
        rowCount(sheetId),
        row1ToScreenBottomHeight,
      );
    }
    if (visibleWidth != null) {
      colBToScreenRightWidth = visibleWidth;
      targetCols = minCols(
        sheetId,
        colCount(sheetId),
        colBToScreenRightWidth,
      );
    }
    if (targetRows != tableViewRows || targetCols != tableViewCols) {
      tableViewRows = targetRows;
      tableViewCols = targetCols;
      if (notify) {
        notifyListeners();
      }
    }
  }

  bool isRowValid(
    String sheetId,
    int rowId,
  ) {
    return gridUsecase.isRowValid(sheetId, rowId);
  }

  @override
  void dispose() {
    _scrollEventController.close();
    super.dispose();
  }
}
