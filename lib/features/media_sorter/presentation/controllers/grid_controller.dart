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

  late bool Function(
  )
  canBeSorted;
  late String Function(List<List<String>> table, int row, int col)
  getCellContent;

  final SpreadsheetLayoutCalculator _layoutCalculator =
      SpreadsheetLayoutCalculator();

  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) =>
      content.table.isNotEmpty ? content.table[0].length : 0;

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
        rowCount(loadedSheetsDataStore.currentSheet.sheetContent),
        row1ToScreenBottomHeight,
      );
    }
    if (visibleWidth != null) {
      colBToScreenRightWidth = visibleWidth;
      targetCols = minCols(
        colCount(loadedSheetsDataStore.currentSheet.sheetContent),
        colBToScreenRightWidth,
      );
    }
    if (targetRows != selectionDataStore.tableViewRows ||
        targetCols != selectionDataStore.tableViewCols) {
      selectionDataStore.setTableViewRows = targetRows;
      selectionDataStore.tableViewCols = targetCols;
    }
  }

  int minRows(
    int rowCount,
    double height,
  ) {
    double tableHeight = getTargetTop(loadedSheetsDataStore.currentSheet, rowCount - 1);
    if (height >= tableHeight) {
      return loadedSheetsDataStore.currentSheet.rowsBottomPos.length +
          ((height - getTargetTop(loadedSheetsDataStore.currentSheet, loadedSheetsDataStore.currentSheet.rowsBottomPos.length - 1) + 1) /
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
    final int nbKnownBottomPos = loadedSheetsDataStore.currentSheet.rowsBottomPos.length;
    var rowsBottomPos = loadedSheetsDataStore.currentSheet.rowsBottomPos;
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
    final int nbKnownRightPos = loadedSheetsDataStore.currentSheet.colRightPos.length;
    var columnsRightPos = loadedSheetsDataStore.currentSheet.colRightPos;
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
    double tableWidth = getTargetLeft(loadedSheetsDataStore.currentSheet, colCount - 1);
    if (width >= tableWidth) {
      return loadedSheetsDataStore.currentSheet.colRightPos.length +
          ((width - getTargetLeft(loadedSheetsDataStore.currentSheet, loadedSheetsDataStore.currentSheet.colRightPos.length - 1) + 1) /
                  GetDefaultSizes.getDefaultCellWidth())
              .ceil();
    }
    return colCount;
  }

  double getColumnWidth(SheetData sheet, int col) {
    return getTargetLeft(sheet, col + 1) - getTargetLeft(sheet, col);
  }

  double calculateRequiredRowHeight(SheetData sheet, String text, int colId) {
    final double availableWidth =
        getColumnWidth(sheet, colId) - PageConstants.horizontalPadding;
    return _layoutCalculator.calculateRowHeight(text, availableWidth);
  }

  void adjustRowHeightAfterUpdate(
    SheetData sheet,
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
    int row,
    int col,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth,
    String newValue,
    String prevValue,
  ) {
    if (row >= sheet.rowsBottomPos.length &&
        row >= rowCount(sheet.sheetContent)) {
      updateRowColCount(
        sheet,
        currentSheetName,
        visibleHeight: row1ToScreenBottomHeight,
        visibleWidth: colBToScreenRightWidth,
        notify: false,
      );
      return;
    }

    double heightItNeeds = calculateRequiredRowHeight(sheet, newValue, col);

    if (heightItNeeds > GetDefaultSizes.getDefaultRowHeight() &&
        sheet.rowsBottomPos.length <= row) {
      int prevRowsBottomPosLength = sheet.rowsBottomPos.length;
      sheet.rowsBottomPos.addAll(
        List.filled(row + 1 - sheet.rowsBottomPos.length, 0),
      );
      for (int i = prevRowsBottomPosLength; i <= row; i++) {
        sheet.rowsBottomPos[i] = i == 0
            ? GetDefaultSizes.getDefaultRowHeight()
            : sheet.rowsBottomPos[i - 1] +
                  GetDefaultSizes.getDefaultRowHeight();
      }
    }

    if (row < sheet.rowsBottomPos.length) {
      if (sheet.rowsManuallyAdjustedHeight.length <= row ||
          !sheet.rowsManuallyAdjustedHeight[row]) {
        double currentHeight = getRowHeight(sheet, row);
        if (heightItNeeds < currentHeight) {
          double heightItNeeded = calculateRequiredRowHeight(
            sheet,
            prevValue,
            col,
          );
          if (heightItNeeded == currentHeight) {
            double newHeight = heightItNeeds;
            if (row < sheet.sheetContent.table.length) {
              for (int j = 0; j < colCount(sheet.sheetContent); j++) {
                if (j == col) continue;
                newHeight = max(
                  calculateRequiredRowHeight(
                    sheet,
                    sheet.sheetContent.table[row][j],
                    j,
                  ),
                  newHeight,
                );
                if (newHeight == heightItNeeded) break;
              }
            }
            if (newHeight < heightItNeeded) {
              double heightDiff = currentHeight - newHeight;
              for (int r = row; r < sheet.rowsBottomPos.length; r++) {
                sheet.rowsBottomPos[r] -= heightDiff;
              }
              if (newHeight == GetDefaultSizes.getDefaultRowHeight()) {
                int removeFrom = sheet.rowsBottomPos.length;
                for (int r = sheet.rowsBottomPos.length - 1; r >= 0; r--) {
                  if (r < sheet.rowsManuallyAdjustedHeight.length &&
                          sheet.rowsManuallyAdjustedHeight[r] ||
                      sheet.rowsBottomPos[r] >
                          (r == 0 ? 0 : sheet.rowsBottomPos[r - 1]) +
                              GetDefaultSizes.getDefaultRowHeight()) {
                    break;
                  }
                  removeFrom--;
                }
                sheet.rowsBottomPos = sheet.rowsBottomPos.sublist(
                  0,
                  removeFrom,
                );
              }
            }
          }
        } else if (heightItNeeds > currentHeight) {
          double heightDiff = heightItNeeds - currentHeight;
          for (int r = row; r < sheet.rowsBottomPos.length; r++) {
            sheet.rowsBottomPos[r] = sheet.rowsBottomPos[r] + heightDiff;
          }
        }
      }
    } else if (heightItNeeds == GetDefaultSizes.getDefaultRowHeight() &&
        row == sheet.rowsBottomPos.length - 1) {
      int i = row;
      while (sheet.rowsBottomPos[i] == GetDefaultSizes.getDefaultRowHeight() &&
          row > 0) {
        sheet.rowsBottomPos.removeLast();
        i--;
      }
    }
    updateRowColCount(
      sheet,
      currentSheetName,
      visibleHeight: row1ToScreenBottomHeight,
      visibleWidth: colBToScreenRightWidth,
      notify: false,
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
          getCellContent(
            sheet.sheetContent.table,
            rowId,
            srcColId,
          ).isNotEmpty) {
        return true;
      }
    }
    return false;
  }
}
