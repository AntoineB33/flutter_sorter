import 'dart:math';

import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/layout_calculator.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/selection_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/get_default_sizes.dart';

class GridController {
  // --- states ---
  double row1ToScreenBottomHeight = 0.0;
  double colBToScreenRightWidth = 0.0;

  LoadedSheetsDataStore loadedSheetsDataStore;
  SelectionDataStore selectionDataStore;

  final SpreadsheetLayoutCalculator _layoutCalculator =
      SpreadsheetLayoutCalculator();

  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) =>
      content.table.isNotEmpty ? content.table[0].length : 0;
  
  SheetData get currentSheet => loadedSheetsDataStore.currentSheet;

  GridController(this.loadedSheetsDataStore, this.selectionDataStore);

  void updateRowColCount({
    double? visibleHeight,
    double? visibleWidth,
  }) {
    int targetRows = selectionDataStore.tableViewRows;
    int targetCols = selectionDataStore.tableViewCols;
    if (visibleHeight != null) {
      row1ToScreenBottomHeight = visibleHeight;
      targetRows = minRows(
        rowCount(currentSheet.sheetContent),
        row1ToScreenBottomHeight,
      );
    }
    if (visibleWidth != null) {
      colBToScreenRightWidth = visibleWidth;
      targetCols = minCols(
        colCount(currentSheet.sheetContent),
        colBToScreenRightWidth,
      );
    }
    if (targetRows != selectionDataStore.tableViewRows ||
        targetCols != selectionDataStore.tableViewCols) {
      selectionDataStore.tableViewRows = targetRows;
      selectionDataStore.tableViewCols = targetCols;
    }
  }

  int minRows(
    int rowCount,
    double height,
  ) {
    double tableHeight = getTargetTop(rowCount - 1);
    if (height >= tableHeight) {
      return currentSheet.rowsBottomPos.length +
          ((height - getTargetTop(currentSheet.rowsBottomPos.length - 1) + 1) /
                  GetDefaultSizes.getDefaultRowHeight())
              .ceil();
    }
    return rowCount;
  }

  double getRowHeight(SheetData sheet, int row) {
    if (row < sheet.rowsBottomPos.length) {
      if (row == 0) {
        return sheet.rowsBottomPos[0];
      } else {
        return sheet.rowsBottomPos[row] - sheet.rowsBottomPos[row - 1];
      }
    }
    return GetDefaultSizes.getDefaultRowHeight();
  }

  double getTargetTop(int row) {
    if (row <= 0) return 0.0;
    final int nbKnownBottomPos = currentSheet.rowsBottomPos.length;
    var rowsBottomPos = currentSheet.rowsBottomPos;
    final int tableHeight = nbKnownBottomPos == 0
        ? 0
        : rowsBottomPos.last.toInt();
    final double targetTop = row - 1 < nbKnownBottomPos
        ? rowsBottomPos[row - 1].toDouble()
        : tableHeight +
              (row - nbKnownBottomPos) * GetDefaultSizes.getDefaultRowHeight();
    return targetTop;
  }

  double getTargetLeft(int col) {
    if (col <= 0) return 0.0;
    final int nbKnownRightPos = currentSheet.colRightPos.length;
    var columnsRightPos = currentSheet.colRightPos;
    final int tableWidth = nbKnownRightPos == 0
        ? 0
        : columnsRightPos.last.toInt();
    final double targetRight = col - 1 < nbKnownRightPos
        ? columnsRightPos[col - 1].toDouble()
        : tableWidth +
              (col - nbKnownRightPos) * GetDefaultSizes.getDefaultCellWidth();
    return targetRight;
  }

  int minCols(
    int colCount,
    double width,
  ) {
    double tableWidth = getTargetLeft(colCount - 1);
    if (width >= tableWidth) {
      return currentSheet.colRightPos.length +
          ((width - getTargetLeft(currentSheet.colRightPos.length - 1) + 1) /
                  GetDefaultSizes.getDefaultCellWidth())
              .ceil();
    }
    return colCount;
  }

  double getColumnWidth(SheetData sheet, int col) {
    return getTargetLeft(col + 1) - getTargetLeft(col);
  }

  double calculateRequiredRowHeight(SheetData sheet, String text, int colId) {
    final double availableWidth =
        getColumnWidth(sheet, colId) - PageConstants.horizontalPadding;
    return _layoutCalculator.calculateRowHeight(text, availableWidth);
  }

  void adjustRowHeightAfterUpdate(
    int row,
    int col,
    String newValue,
    String prevValue,
  ) {
    if (row >= currentSheet.rowsBottomPos.length &&
        row >= rowCount(currentSheet.sheetContent)) {
      updateRowColCount(
        visibleHeight: row1ToScreenBottomHeight,
        visibleWidth: colBToScreenRightWidth,
      );
      return;
    }

    double heightItNeeds = calculateRequiredRowHeight(currentSheet, newValue, col);

    if (heightItNeeds > GetDefaultSizes.getDefaultRowHeight() &&
        currentSheet.rowsBottomPos.length <= row) {
      int prevRowsBottomPosLength = currentSheet.rowsBottomPos.length;
      currentSheet.rowsBottomPos.addAll(
        List.filled(row + 1 - currentSheet.rowsBottomPos.length, 0),
      );
      for (int i = prevRowsBottomPosLength; i <= row; i++) {
        currentSheet.rowsBottomPos[i] = i == 0
            ? GetDefaultSizes.getDefaultRowHeight()
            : currentSheet.rowsBottomPos[i - 1] +
                  GetDefaultSizes.getDefaultRowHeight();
      }
    }

    if (row < currentSheet.rowsBottomPos.length) {
      if (currentSheet.rowsManuallyAdjustedHeight.length <= row ||
          !currentSheet.rowsManuallyAdjustedHeight[row]) {
        double currentHeight = getRowHeight(currentSheet, row);
        if (heightItNeeds < currentHeight) {
          double heightItNeeded = calculateRequiredRowHeight(
            currentSheet,
            prevValue,
            col,
          );
          if (heightItNeeded == currentHeight) {
            double newHeight = heightItNeeds;
            if (row < currentSheet.sheetContent.table.length) {
              for (int j = 0; j < colCount(currentSheet.sheetContent); j++) {
                if (j == col) continue;
                newHeight = max(
                  calculateRequiredRowHeight(
                    currentSheet,
                    currentSheet.sheetContent.table[row][j],
                    j,
                  ),
                  newHeight,
                );
                if (newHeight == heightItNeeded) break;
              }
            }
            if (newHeight < heightItNeeded) {
              double heightDiff = currentHeight - newHeight;
              for (int r = row; r < currentSheet.rowsBottomPos.length; r++) {
                currentSheet.rowsBottomPos[r] -= heightDiff;
              }
              if (newHeight == GetDefaultSizes.getDefaultRowHeight()) {
                int removeFrom = currentSheet.rowsBottomPos.length;
                for (int r = currentSheet.rowsBottomPos.length - 1; r >= 0; r--) {
                  if (r < currentSheet.rowsManuallyAdjustedHeight.length &&
                          currentSheet.rowsManuallyAdjustedHeight[r] ||
                      currentSheet.rowsBottomPos[r] >
                          (r == 0 ? 0 : currentSheet.rowsBottomPos[r - 1]) +
                              GetDefaultSizes.getDefaultRowHeight()) {
                    break;
                  }
                  removeFrom--;
                }
                currentSheet.rowsBottomPos = currentSheet.rowsBottomPos.sublist(
                  0,
                  removeFrom,
                );
              }
            }
          }
        } else if (heightItNeeds > currentHeight) {
          double heightDiff = heightItNeeds - currentHeight;
          for (int r = row; r < currentSheet.rowsBottomPos.length; r++) {
            currentSheet.rowsBottomPos[r] = currentSheet.rowsBottomPos[r] + heightDiff;
          }
        }
      }
    } else if (heightItNeeds == GetDefaultSizes.getDefaultRowHeight() &&
        row == currentSheet.rowsBottomPos.length - 1) {
      int i = row;
      while (currentSheet.rowsBottomPos[i] == GetDefaultSizes.getDefaultRowHeight() &&
          row > 0) {
        currentSheet.rowsBottomPos.removeLast();
        i--;
      }
    }
    updateRowColCount(
      visibleHeight: row1ToScreenBottomHeight,
      visibleWidth: colBToScreenRightWidth,
    );
  }

  bool isRowValid(
    SheetData sheet,
    int rowId,
    AnalysisResult result,
    SortStatus sortStatus,
  ) {
    if (sortStatus.resultCalculated) {
      return rowId < result.isMedium.length && result.isMedium[rowId];
    }
    if (rowId == 0) {
      return false;
    }
    for (
      int srcColId = 0;
      srcColId < colCount(sheet.sheetContent);
      srcColId++
    ) {
      if (GetNames.isSourceColumn(sheet.sheetContent.columnTypes[srcColId]) &&
          loadedSheetsDataStore.getCellContent(
            rowId,
            srcColId,
          ).isNotEmpty) {
        return true;
      }
    }
    return false;
  }
}
