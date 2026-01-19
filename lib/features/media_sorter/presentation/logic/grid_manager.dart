import 'dart:async';
import 'dart:math';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/layout_calculator.dart';
import '../../domain/entities/column_type.dart';

class SpreadsheetScrollRequest {
  final Point<int>? cell;
  final double? offsetX;
  final double? offsetY;
  final bool animate;

  SpreadsheetScrollRequest.toCell(this.cell)
      : offsetX = null,
        offsetY = null,
        animate = true;

  SpreadsheetScrollRequest.toOffset({this.offsetX, this.offsetY, this.animate = false})
      : cell = null;
}

class GridManager {
  final SpreadsheetController controller;
  final SpreadsheetLayoutCalculator _layoutCalculator = SpreadsheetLayoutCalculator();

  // --- Scroll Stream Controller ---
  final StreamController<SpreadsheetScrollRequest> _scrollController =
      StreamController<SpreadsheetScrollRequest>.broadcast();
  Stream<SpreadsheetScrollRequest> get scrollStream => _scrollController.stream;

  double visibleWindowHeight = 0.0;
  double visibleWindowWidth = 0.0;

  GridManager(this.controller);

  void dispose() {
    _scrollController.close();
  }

  // --- Grid Dimensions & Structure ---

  void increaseColumnCount(int col) {
    if (col >= controller.colCount) {
      final needed = col + 1 - controller.colCount;
      for (var r = 0; r < controller.rowCount; r++) {
        controller.sheetContent.table[r].addAll(List.filled(needed, '', growable: true));
      }
      controller.sheetContent.columnTypes.addAll(List.filled(needed, ColumnType.attributes));
    }
  }

  // Helper for increaseColumnCount specific to the original logic
  // Since we don't have the ColumnType import visible in the snippet provided for the NEW file,
  // I will rely on the fact that we can manipulate the list.
  
  void decreaseRowCount(int row) {
    if (row == controller.rowCount - 1) {
      while (row >= 0 && !controller.sheetContent.table[row].any((cell) => cell.isNotEmpty)) {
        controller.sheetContent.table.removeLast();
        row--;
      }
    }
  }

  // --- Layout Calculations ---

  double getColumnWidth(int col) {
    return getTargetLeft(col + 1) - getTargetLeft(col);
  }

  double calculateRequiredRowHeight(String text, int colId) {
    final double availableWidth =
        getColumnWidth(colId) - PageConstants.horizontalPadding;
    return _layoutCalculator.calculateRowHeight(text, availableWidth);
  }

  double getDefaultRowHeight() {
    return PageConstants.defaultFontHeight + 2 * PageConstants.verticalPadding;
  }

  double getDefaultCellWidth() {
    return PageConstants.defaultCellWidth + 2 * PageConstants.horizontalPadding;
  }

  double getRowHeight(int row) {
    if (row < controller.sheet.rowsBottomPos.length) {
      if (row == 0) {
        return controller.sheet.rowsBottomPos[0];
      } else {
        return controller.sheet.rowsBottomPos[row] - controller.sheet.rowsBottomPos[row - 1];
      }
    }
    return getDefaultRowHeight();
  }

  // --- Complex Row Height Adjustment Logic (Extracted from updateCell) ---
  void adjustRowHeightAfterUpdate(int row, int col, String newValue, String prevValue) {
    if (row >= controller.sheet.rowsBottomPos.length && row >= controller.rowCount) {
      updateRowColCount(
          visibleHeight: visibleWindowHeight,
          visibleWidth: visibleWindowWidth,
          notify: false);
      return;
    }

    double heightItNeeds = calculateRequiredRowHeight(newValue, col);
    
    if (heightItNeeds > getDefaultRowHeight() &&
        controller.sheet.rowsBottomPos.length <= row) {
      int prevRowsBottomPosLength = controller.sheet.rowsBottomPos.length;
      controller.sheet.rowsBottomPos.addAll(
        List.filled(row + 1 - controller.sheet.rowsBottomPos.length, 0),
      );
      for (int i = prevRowsBottomPosLength; i <= row; i++) {
        controller.sheet.rowsBottomPos[i] = i == 0
            ? getDefaultRowHeight()
            : controller.sheet.rowsBottomPos[i - 1] + getDefaultRowHeight();
      }
    }

    if (row < controller.sheet.rowsBottomPos.length) {
      if (controller.sheet.rowsManuallyAdjustedHeight.length <= row ||
          !controller.sheet.rowsManuallyAdjustedHeight[row]) {
        double currentHeight = getRowHeight(row);
        if (heightItNeeds < currentHeight) {
          double heightItNeeded = calculateRequiredRowHeight(prevValue, col);
          if (heightItNeeded == currentHeight) {
            double newHeight = heightItNeeds;
            for (int j = 0; j < controller.colCount; j++) {
              if (j == col) continue;
              newHeight = max(
                calculateRequiredRowHeight(controller.sheetContent.table[row][j], j),
                newHeight,
              );
              if (newHeight == heightItNeeded) break;
            }
            if (newHeight < heightItNeeded) {
              double heightDiff = currentHeight - newHeight;
              for (int r = row; r < controller.sheet.rowsBottomPos.length; r++) {
                controller.sheet.rowsBottomPos[r] -= heightDiff;
              }
              if (newHeight == getDefaultRowHeight()) {
                int removeFrom = controller.sheet.rowsBottomPos.length;
                for (int r = controller.sheet.rowsBottomPos.length - 1; r >= 0; r--) {
                  if (r < controller.sheet.rowsManuallyAdjustedHeight.length &&
                          controller.sheet.rowsManuallyAdjustedHeight[r] ||
                      controller.sheet.rowsBottomPos[r] >
                          (r == 0 ? 0 : controller.sheet.rowsBottomPos[r - 1]) +
                              getDefaultRowHeight()) {
                    break;
                  }
                  removeFrom--;
                }
                controller.sheet.rowsBottomPos = controller.sheet.rowsBottomPos.sublist(
                  0,
                  removeFrom,
                );
              }
            }
          }
        } else if (heightItNeeds > currentHeight) {
          double heightDiff = heightItNeeds - currentHeight;
          for (int r = row; r < controller.sheet.rowsBottomPos.length; r++) {
            controller.sheet.rowsBottomPos[r] = controller.sheet.rowsBottomPos[r] + heightDiff;
          }
        }
      }
    } else if (heightItNeeds == getDefaultRowHeight() &&
        row == controller.sheet.rowsBottomPos.length - 1) {
      int i = row;
      while (controller.sheet.rowsBottomPos[i] == getDefaultRowHeight() && row > 0) {
        controller.sheet.rowsBottomPos.removeLast();
        i--;
      }
    }
    updateRowColCount(
        visibleHeight: visibleWindowHeight,
        visibleWidth: visibleWindowWidth,
        notify: false);
  }

  // --- View Port & Target Calculations ---

  void updateRowColCount({double? visibleHeight, double? visibleWidth, bool notify = true}) {
    int targetRows = controller.tableViewRows;
    int targetCols = controller.tableViewCols;
    
    if (visibleHeight != null) {
      visibleWindowHeight = visibleHeight;
      targetRows = minRows(visibleWindowHeight);
    }
    if (visibleWidth != null) {
      visibleWindowWidth = visibleWidth;
      targetCols = minCols(visibleWindowWidth);
    }
    
    // We access the selection manager via the controller
    // This assumes the controller exposes the way to set these, 
    // or we modify the selection model directly via the controller's selection getter.
    if (targetRows != controller.tableViewRows || targetCols != controller.tableViewCols) {
       controller.selection.rowCount = targetRows;
       controller.selection.colCount = targetCols;
      if (notify) {
        controller.notify();
      }
    }
  }

  double getTargetTop(int row) {
    if (row <= 0) return 0.0;
    final int nbKnownBottomPos = controller.sheet.rowsBottomPos.length;
    var rowsBottomPos = controller.sheet.rowsBottomPos;
    final int tableHeight = nbKnownBottomPos == 0
        ? 0
        : rowsBottomPos.last.toInt();
    final double targetTop = row - 1 < nbKnownBottomPos
        ? rowsBottomPos[row - 1].toDouble()
        : tableHeight + (row - nbKnownBottomPos) * getDefaultRowHeight();
    return targetTop;
  }

  double getTargetLeft(int col) {
    if (col <= 0) return 0.0;
    final int nbKnownRightPos = controller.sheet.colRightPos.length;
    var columnsRightPos = controller.sheet.colRightPos;
    final int tableWidth = nbKnownRightPos == 0
        ? 0
        : columnsRightPos.last.toInt();
    final double targetRight = col - 1 < nbKnownRightPos
        ? columnsRightPos[col - 1].toDouble()
        : tableWidth + (col - nbKnownRightPos) * getDefaultCellWidth();
    return targetRight;
  }

  int minRows(double height) {
    double tableHeight = getTargetTop(controller.rowCount - 1);
    if (height >= tableHeight) {
      return controller.sheet.rowsBottomPos.length +
          (height - getTargetTop(controller.sheet.rowsBottomPos.length - 1)) ~/
              getDefaultRowHeight() +
          1;
    }
    return controller.rowCount;
  }

  int minCols(double width) {
    double tableWidth = getTargetLeft(controller.colCount - 1);
    if (width >= tableWidth) {
      return controller.sheet.colRightPos.length +
          (width - getTargetLeft(controller.sheet.colRightPos.length - 1)) ~/
              getDefaultCellWidth() +
          1;
    }
    return controller.colCount;
  }

  // --- Scrolling ---

  void triggerScrollTo(int row, int col) {
    _scrollController.add(SpreadsheetScrollRequest.toCell(Point(row, col)));
  }

  void scrollToOffset({double? x, double? y, bool animate = false}) {
    _scrollController.add(
      SpreadsheetScrollRequest.toOffset(offsetX: x, offsetY: y, animate: animate),
    );
  }
}