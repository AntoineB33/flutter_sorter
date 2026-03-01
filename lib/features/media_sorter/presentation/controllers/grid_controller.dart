import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/layout_calculator.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/presentation/models/scroll_request.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/selection_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/get_default_sizes.dart';

class GridController extends ChangeNotifier {
  // --- states ---
  double row1ToScreenBottomHeight = 0.0;
  double colBToScreenRightWidth = 0.0;
  int tableViewRows = 0;
  int tableViewCols = 0;

  LoadedSheetsDataStore loadedSheetsDataStore;
  SelectionDataStore selectionDataStore;

  final SpreadsheetLayoutCalculator _layoutCalculator =
      SpreadsheetLayoutCalculator();
  final _scrollEventController = StreamController<ScrollRequest>.broadcast();
  Stream<ScrollRequest> get onScrollEvent => _scrollEventController.stream;

  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) =>
      content.table.isNotEmpty ? content.table[0].length : 0;
  
  SheetData get currentSheet => loadedSheetsDataStore.currentSheet;

  GridController(this.loadedSheetsDataStore, this.selectionDataStore);

  void updateRowColCount(
    bool notify,{
    double? visibleHeight,
    double? visibleWidth,
  }) {
    int targetRows = tableViewRows;
    int targetCols = tableViewCols;
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
    if (targetRows != tableViewRows ||
        targetCols != tableViewCols) {
      tableViewRows = targetRows;
      tableViewCols = targetCols;
      if (notify) {
        notifyListeners();
      }
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

  double getRowHeight(int row) {
    if (row < currentSheet.rowsBottomPos.length) {
      if (row == 0) {
        return currentSheet.rowsBottomPos[0];
      } else {
        return currentSheet.rowsBottomPos[row] - currentSheet.rowsBottomPos[row - 1];
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

  double getColumnWidth(int col) {
    return getTargetLeft(col + 1) - getTargetLeft(col);
  }

  double calculateRequiredRowHeight(String text, int colId) {
    final double availableWidth =
        getColumnWidth(colId) - PageConstants.horizontalPadding;
    return _layoutCalculator.calculateRowHeight(text, availableWidth);
  }

  void adjustRowHeightAfterUpdate(UpdateData updateData) {
    for (var update in updateData.updates) {
      if (update is CellUpdate) {
        final int row = update.rowId;
        final int col = update.colId;
        final String newValue = update.newValue;
        final String prevValue = update.prevValue;

        if (row >= currentSheet.rowsBottomPos.length &&
            row >= rowCount(currentSheet.sheetContent)) {
          break;
        }

        double heightItNeeds = calculateRequiredRowHeight(newValue, col);

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
            double currentHeight = getRowHeight(row);
            if (heightItNeeds < currentHeight) {
              double heightItNeeded = calculateRequiredRowHeight(
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
      }
    }
    updateRowColCount(
      false,
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

  /// Calculates offsets and scrolls to ensure the target cell is visible.
  void scrollToCell(
    int rowId,
    int colId,
  ) {
    bool saveSelection = false;
    bool scrollX = true;
    bool scrollY = true;
    if (rowId > 0) {
      // Vertical Logic
      final double targetTop =
          getTargetTop(rowId) - getTargetTop(1);
      final double targetBottom = getTargetTop(rowId + 1);
      final double verticalViewport =
          verticalController.position.viewportDimension -
          currentSheet.rowHeaderWidth;

      if (targetTop < verticalController.offset) {
        saveSelection = true;
        selectionDataStore.scrollOffsetX = targetTop;
      } else if (targetBottom > verticalController.offset + verticalViewport) {
        saveSelection = true;
        selectionDataStore.scrollOffsetX =
            targetBottom - verticalViewport;
        updateRowColCount(true, visibleHeight: targetBottom);
      } else {
        scrollY = false;
      }
    }

    if (cell.y > 0) {
      // Horizontal Logic
      final double targetLeft =
          getTargetLeft(cell.y) -
          getTargetLeft(1);
      final double targetRight = getTargetLeft(cell.y + 1);
      final double horizontalViewport =
          horizontalController.position.viewportDimension -
          currentSheet.rowHeaderWidth;

      if (targetLeft < horizontalController.offset) {
        saveSelection = true;
        selectionDataStore.scrollOffsetY = targetLeft;
      } else if (targetRight >
          selectionDataStore.scrollOffsetY + horizontalViewport) {
        saveSelection = true;
        selectionDataStore.scrollOffsetY =
            targetRight - horizontalViewport;
        updateRowColCount(true, visibleWidth: targetRight);
      } else {
        scrollX = false;
      }
    }
    if (scrollX || scrollY) {
      _scrollEventController.add(
        ScrollRequest(
          xOffset: scrollX ? selectionDataStore.scrollOffsetY : null,
          yOffset: scrollY ? selectionDataStore.scrollOffsetX : null,
        ),
      );
    }
    if (saveSelection) {
      selectionDataStore.saveSelection();
    }
  }
  

  @override
  void dispose() {
    _scrollEventController.close();
    super.dispose();
  }
}
