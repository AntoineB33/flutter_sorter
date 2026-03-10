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
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/get_default_sizes.dart';

class GridController extends ChangeNotifier {
  // --- states ---
  final _scrollEventController = StreamController<ScrollRequest>.broadcast();
  Stream<ScrollRequest> get onScrollEvent => _scrollEventController.stream;

  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) =>
      content.table.isNotEmpty ? content.table[0].length : 0;

  SheetData get currentSheet => loadedSheetsDataStore.currentSheet;

  GridController(this.loadedSheetsDataStore, this.selectionDataStore);


  int minRows(int rowCount, double height) {
    double tableHeight = getTargetTop(rowCount - 1);
    if (height >= tableHeight) {
      return currentSheet.rowsBottomPos.length +
          ((height - getTargetTop(currentSheet.rowsBottomPos.length - 1) + 1) /
                  GetDefaultSizes.getDefaultRowHeight())
              .ceil();
    }
    return rowCount;
  }


  int minCols(int colCount, double width) {
    double tableWidth = getTargetLeft(colCount - 1);
    if (width >= tableWidth) {
      return currentSheet.colRightPos.length +
          ((width - getTargetLeft(currentSheet.colRightPos.length - 1) + 1) /
                  GetDefaultSizes.getDefaultCellWidth())
              .ceil();
    }
    return colCount;
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
                  for (
                    int j = 0;
                    j < colCount(currentSheet.sheetContent);
                    j++
                  ) {
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
                  for (
                    int r = row;
                    r < currentSheet.rowsBottomPos.length;
                    r++
                  ) {
                    currentSheet.rowsBottomPos[r] -= heightDiff;
                  }
                  if (newHeight == GetDefaultSizes.getDefaultRowHeight()) {
                    int removeFrom = currentSheet.rowsBottomPos.length;
                    for (
                      int r = currentSheet.rowsBottomPos.length - 1;
                      r >= 0;
                      r--
                    ) {
                      if (r < currentSheet.rowsManuallyAdjustedHeight.length &&
                              currentSheet.rowsManuallyAdjustedHeight[r] ||
                          currentSheet.rowsBottomPos[r] >
                              (r == 0 ? 0 : currentSheet.rowsBottomPos[r - 1]) +
                                  GetDefaultSizes.getDefaultRowHeight()) {
                        break;
                      }
                      removeFrom--;
                    }
                    currentSheet.rowsBottomPos = currentSheet.rowsBottomPos
                        .sublist(0, removeFrom);
                  }
                }
              }
            } else if (heightItNeeds > currentHeight) {
              double heightDiff = heightItNeeds - currentHeight;
              for (int r = row; r < currentSheet.rowsBottomPos.length; r++) {
                currentSheet.rowsBottomPos[r] =
                    currentSheet.rowsBottomPos[r] + heightDiff;
              }
            }
          }
        } else if (heightItNeeds == GetDefaultSizes.getDefaultRowHeight() &&
            row == currentSheet.rowsBottomPos.length - 1) {
          int i = row;
          while (currentSheet.rowsBottomPos[i] ==
                  GetDefaultSizes.getDefaultRowHeight() &&
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
          loadedSheetsDataStore.getCellContent(rowId, srcColId).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _scrollEventController.close();
    super.dispose();
  }
}
