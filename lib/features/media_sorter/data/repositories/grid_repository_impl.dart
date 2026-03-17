import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/get_default_sizes.dart';

class GridRepositoryImpl implements GridRepository {
  final LoadedSheetsCache loadedSheetsCache;
  final WorkbookCache workbookCache;
  final SelectionCache selectionCache;

  String get currentSheetId => workbookCache.currentSheetId;

  GridRepositoryImpl(this.loadedSheetsCache, this.workbookCache, this.selectionCache);

  int rowCount(String sheetId) {
    return loadedSheetsCache.rowCount(sheetId);
  }

  int colCount(String sheetId) {
    return loadedSheetsCache.colCount(sheetId);
  }

  @override
  double getTargetLeft(String sheetId, int col) {
    if (col <= 0) return 0.0;
    SheetData sheet = loadedSheetsCache.getSheet(sheetId);
    final int nbKnownRightPos = sheet.colRightPos.length;
    var columnsRightPos = sheet.colRightPos;
    final int tableWidth = nbKnownRightPos == 0
        ? 0
        : columnsRightPos.last.toInt();
    final double targetRight = col - 1 < nbKnownRightPos
        ? columnsRightPos[col - 1].toDouble()
        : tableWidth +
              (col - nbKnownRightPos) * GetDefaultSizes.getDefaultCellWidth();
    return targetRight;
  }

  double getColumnWidth(String sheetId, int col) {
    return getTargetLeft(sheetId, col + 1) - getTargetLeft(sheetId, col);
  }

  double calculateRequiredRowHeight(String sheetId, String text, int colId) {
    final double availableWidth =
        getColumnWidth(sheetId, colId) - PageConstants.horizontalPadding;
    return calculateRowHeight(text, availableWidth);
  }
  
  double calculateRowHeight(String text, double availableWidth) {
    if (availableWidth <= 0) return 30.0;
    
    const double horizontalPadding = PageConstants.horizontalPadding * 2; // Left + Right padding
    const double borderWidth = PageConstants.borderWidth * 2;       // Left + Right border

    // 1. Adjust available width for text wrapping
    final double textLayoutWidth = availableWidth - horizontalPadding - borderWidth;

    if (textLayoutWidth <= 0) return 30.0;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: PageConstants.cellStyle),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
    );

    // 2. Layout using the constricted width
    textPainter.layout(minWidth: 0, maxWidth: textLayoutWidth);

    // 3. Add Vertical Spacing
    const double verticalPaddingTotal = PageConstants.verticalPadding * 2; 
    const double verticalBorderTotal = PageConstants.borderWidth * 2;

    return textPainter.height + verticalPaddingTotal + verticalBorderTotal;
  }

  
  @override
  double getRowHeight(String sheetId, int row) {
    SheetData sheet = loadedSheetsCache.getSheet(sheetId);
    if (row < sheet.rowsBottomPos.length) {
      if (row == 0) {
        return sheet.rowsBottomPos[0];
      } else {
        return sheet.rowsBottomPos[row] -
            sheet.rowsBottomPos[row - 1];
      }
    }
    return GetDefaultSizes.getDefaultRowHeight();
  }

  @override
  int minRows(String sheetId, int rowCount, double height) {
    SheetData sheet = loadedSheetsCache.getSheet(sheetId);
    double tableHeight = getTargetTop(sheetId, rowCount - 1);
    if (height >= tableHeight) {
      return sheet.rowsBottomPos.length +
          ((height - getTargetTop(sheetId, sheet.rowsBottomPos.length - 1) + 1) /
                  GetDefaultSizes.getDefaultRowHeight())
              .ceil();
    }
    return rowCount;
  }
  
  @override
  int minCols(String sheetId, int colCount, double width) {
    SheetData sheet = loadedSheetsCache.getSheet(sheetId);
    double tableWidth = getTargetLeft(sheetId, colCount - 1);
    if (width >= tableWidth) {
      return sheet.colRightPos.length +
          ((width - getTargetLeft(sheetId, sheet.colRightPos.length - 1) + 1) /
                  GetDefaultSizes.getDefaultCellWidth())
              .ceil();
    }
    return colCount;
  }
  
  @override
  double getTargetTop(String sheetId, int row) {
    if (row <= 0) return 0.0;
    SheetData sheet = loadedSheetsCache.getSheet(sheetId);
    final int nbKnownBottomPos = sheet.rowsBottomPos.length;
    var rowsBottomPos = sheet.rowsBottomPos;
    final int tableHeight = nbKnownBottomPos == 0
        ? 0
        : rowsBottomPos.last.toInt();
    final double targetTop = row - 1 < nbKnownBottomPos
        ? rowsBottomPos[row - 1].toDouble()
        : tableHeight +
              (row - nbKnownBottomPos) * GetDefaultSizes.getDefaultRowHeight();
    return targetTop;
  }

  @override
  void adjustRowHeightAfterUpdate(String sheetId, List<UpdateUnit> updates) {
    SheetData sheet = loadedSheetsCache.getSheet(sheetId);
    for (var update in updates) {
      if (update is CellUpdate) {
        final int row = update.rowId;
        final int col = update.colId;
        final String newValue = update.newValue;
        final String prevValue = update.prevValue!;

        if (row >= sheet.rowsBottomPos.length &&
            row >= rowCount(sheetId)) {
          break;
        }

        double heightItNeeds = calculateRequiredRowHeight(sheetId, newValue, col);

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
            double currentHeight = getRowHeight(sheetId, row);
            if (heightItNeeds < currentHeight) {
              double heightItNeeded = calculateRequiredRowHeight(
                sheetId,
                prevValue,
                col,
              );
              if (heightItNeeded == currentHeight) {
                double newHeight = heightItNeeds;
                if (row < sheet.sheetContent.table.length) {
                  for (
                    int j = 0;
                    j < colCount(sheetId);
                    j++
                  ) {
                    if (j == col) continue;
                    newHeight = max(
                      calculateRequiredRowHeight(
                        sheetId,
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
                  for (
                    int r = row;
                    r < sheet.rowsBottomPos.length;
                    r++
                  ) {
                    sheet.rowsBottomPos[r] -= heightDiff;
                  }
                  if (newHeight == GetDefaultSizes.getDefaultRowHeight()) {
                    int removeFrom = sheet.rowsBottomPos.length;
                    for (
                      int r = sheet.rowsBottomPos.length - 1;
                      r >= 0;
                      r--
                    ) {
                      if (r < sheet.rowsManuallyAdjustedHeight.length &&
                              sheet.rowsManuallyAdjustedHeight[r] ||
                          sheet.rowsBottomPos[r] >
                              (r == 0 ? 0 : sheet.rowsBottomPos[r - 1]) +
                                  GetDefaultSizes.getDefaultRowHeight()) {
                        break;
                      }
                      removeFrom--;
                    }
                    sheet.rowsBottomPos = sheet.rowsBottomPos
                        .sublist(0, removeFrom);
                  }
                }
              }
            } else if (heightItNeeds > currentHeight) {
              double heightDiff = heightItNeeds - currentHeight;
              for (int r = row; r < sheet.rowsBottomPos.length; r++) {
                sheet.rowsBottomPos[r] =
                    sheet.rowsBottomPos[r] + heightDiff;
              }
            }
          }
        } else if (heightItNeeds == GetDefaultSizes.getDefaultRowHeight() &&
            row == sheet.rowsBottomPos.length - 1) {
          int i = row;
          while (sheet.rowsBottomPos[i] ==
                  GetDefaultSizes.getDefaultRowHeight() &&
              row > 0) {
            sheet.rowsBottomPos.removeLast();
            i--;
          }
        }
      }
    }
    }


}