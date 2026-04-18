import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:trying_flutter/features/media_sorter/data/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/data/store/layout_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/layout_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/get_default_sizes.dart';

class GridRepositoryImpl implements GridRepository {
  final LoadedSheetsCache loadedSheetsCache;
  final WorkbookCache workbookCache;
  final SelectionCache selectionCache;
  final LayoutCache layoutCache;

  int get currentSheetId => workbookCache.currentSheetId;

  GridRepositoryImpl(
    this.loadedSheetsCache,
    this.workbookCache,
    this.selectionCache,
    this.layoutCache,
  );

  @override
  LayoutData getLayout(int sheetId) {
    return layoutCache.getLayout(sheetId);
  }

  int rowCount(int sheetId) {
    return loadedSheetsCache.rowCount(sheetId);
  }

  int colCount(int sheetId) {
    return loadedSheetsCache.colCount(sheetId);
  }

  @override
  double getTargetLeft(int sheetId, int col) {
    if (col <= 0) return 0.0;
    final layout = layoutCache.getLayout(sheetId);
    final int nbKnownRightPos = layout.colRightPos.length;
    var columnsRightPos = layout.colRightPos;
    final int tableWidth = nbKnownRightPos == 0
        ? 0
        : columnsRightPos.last.toInt();
    final double targetRight = col - 1 < nbKnownRightPos
        ? columnsRightPos[col - 1].toDouble()
        : tableWidth +
              (col - nbKnownRightPos) * GetDefaultSizes.getDefaultCellWidth();
    return targetRight;
  }

  double getColumnWidth(int sheetId, int col) {
    return getTargetLeft(sheetId, col + 1) - getTargetLeft(sheetId, col);
  }

  double calculateRequiredRowHeight(int sheetId, String text, int colId) {
    final double availableWidth =
        getColumnWidth(sheetId, colId) - PageConstants.horizontalPadding;
    return calculateRowHeight(text, availableWidth);
  }

  double calculateRowHeight(String text, double availableWidth) {
    if (availableWidth <= 0) return 30.0;

    const double horizontalPadding =
        PageConstants.horizontalPadding * 2; // Left + Right padding
    const double borderWidth =
        PageConstants.borderWidth * 2; // Left + Right border

    // 1. Adjust available width for text wrapping
    final double textLayoutWidth =
        availableWidth - horizontalPadding - borderWidth;

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
  double getRowHeight(int sheetId, int row) {
    final layout = layoutCache.getLayout(sheetId);
    if (row < layout.rowsBottomPos.length) {
      if (row == 0) {
        return layout.rowsBottomPos[0];
      } else {
        return layout.rowsBottomPos[row] - layout.rowsBottomPos[row - 1];
      }
    }
    return GetDefaultSizes.getDefaultRowHeight();
  }

  @override
  int minRows(int sheetId, int rowCount, double height) {
    final layout = layoutCache.getLayout(sheetId);
    double tableHeight = getTargetTop(sheetId, rowCount - 1);
    if (height >= tableHeight) {
      return layout.rowsBottomPos.length +
          ((height -
                      getTargetTop(sheetId, layout.rowsBottomPos.length - 1) +
                      1) /
                  GetDefaultSizes.getDefaultRowHeight())
              .ceil();
    }
    return rowCount;
  }

  @override
  int minCols(int sheetId, int colCount, double width) {
    final layout = layoutCache.getLayout(sheetId);
    double tableWidth = getTargetLeft(sheetId, colCount - 1);
    if (width >= tableWidth) {
      return layout.colRightPos.length +
          ((width - getTargetLeft(sheetId, layout.colRightPos.length - 1) + 1) /
                  GetDefaultSizes.getDefaultCellWidth())
              .ceil();
    }
    return colCount;
  }

  @override
  double getTargetTop(int sheetId, int row) {
    if (row <= 0) return 0.0;
    final layout = layoutCache.getLayout(sheetId);
    final int nbKnownBottomPos = layout.rowsBottomPos.length;
    var rowsBottomPos = layout.rowsBottomPos;
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
  ChangeSet adjustRowHeightAfterUpdate(
    int sheetId,
    IMap<String, UpdateUnit> updates,
  ) {
    final ChangeSet changeSet = ChangeSet(initialChanges: updates);
    final layout = layoutCache.getLayout(sheetId);
    for (var update in updates.values) {
      if (update is CellUpdate) {
        final int row = update.rowId;
        final int col = update.colId;
        final String newValue = update.newValue;
        final String prevValue = update.prevValue;

        if (row >= layout.rowsBottomPos.length && row >= rowCount(sheetId)) {
          break;
        }

        double heightItNeeds = calculateRequiredRowHeight(
          sheetId,
          newValue,
          col,
        );

        if (heightItNeeds > GetDefaultSizes.getDefaultRowHeight() &&
            layout.rowsBottomPos.length <= row) {
          int prevRowsBottomPosLength = layout.rowsBottomPos.length;
          layout.rowsBottomPos.addAll(
            List.filled(row + 1 - layout.rowsBottomPos.length, 0),
          );
          for (int i = prevRowsBottomPosLength; i <= row; i++) {
            layout.rowsBottomPos[i] = i == 0
                ? GetDefaultSizes.getDefaultRowHeight()
                : layout.rowsBottomPos[i - 1] +
                      GetDefaultSizes.getDefaultRowHeight();
            changeSet.addUpdate(
              RowsBottomPosUpdate(
                sheetId,
                i,
                newBottomPos: layout.rowsBottomPos[i],
              ),
            );
          }
        }

        if (row < layout.rowsBottomPos.length) {
          if (layout.rowsManuallyAdjustedHeight.length <= row ||
              !layout.rowsManuallyAdjustedHeight[row]) {
            double currentHeight = getRowHeight(sheetId, row);
            if (heightItNeeds < currentHeight) {
              double heightItNeeded = calculateRequiredRowHeight(
                sheetId,
                prevValue,
                col,
              );
              if (heightItNeeded == currentHeight) {
                double newHeight = heightItNeeds;
                if (row < rowCount(sheetId)) {
                  for (int j = 0; j < colCount(sheetId); j++) {
                    if (j == col) continue;
                    newHeight = max(
                      calculateRequiredRowHeight(
                        sheetId,
                        loadedSheetsCache.getCellContent(sheetId, row, j),
                        j,
                      ),
                      newHeight,
                    );
                    if (newHeight == heightItNeeded) break;
                  }
                }
                if (newHeight < heightItNeeded) {
                  double heightDiff = currentHeight - newHeight;
                  for (int r = row; r < layout.rowsBottomPos.length; r++) {
                    layout.rowsBottomPos[r] -= heightDiff;
                    changeSet.addUpdate(
                      RowsBottomPosUpdate(
                        sheetId,
                        r,
                        newBottomPos: layout.rowsBottomPos[r],
                      ),
                    );
                  }
                  if (newHeight == GetDefaultSizes.getDefaultRowHeight()) {
                    int removeFrom = layout.rowsBottomPos.length;
                    for (int r = layout.rowsBottomPos.length - 1; r >= 0; r--) {
                      if (r < layout.rowsManuallyAdjustedHeight.length &&
                              layout.rowsManuallyAdjustedHeight[r] ||
                          layout.rowsBottomPos[r] >
                              (r == 0 ? 0 : layout.rowsBottomPos[r - 1]) +
                                  GetDefaultSizes.getDefaultRowHeight()) {
                        break;
                      }
                      removeFrom--;
                    }
                    for (
                      int i = removeFrom;
                      i < layout.rowsBottomPos.length;
                      i++
                    ) {
                      changeSet.addUpdate(RowsBottomPosUpdate(sheetId, i));
                    }
                    layout.rowsBottomPos = layout.rowsBottomPos.sublist(
                      0,
                      removeFrom,
                    );
                  }
                }
              }
            } else if (heightItNeeds > currentHeight) {
              double heightDiff = heightItNeeds - currentHeight;
              for (int r = row; r < layout.rowsBottomPos.length; r++) {
                layout.rowsBottomPos[r] = layout.rowsBottomPos[r] + heightDiff;
                changeSet.addUpdate(
                  RowsBottomPosUpdate(
                    sheetId,
                    r,
                    newBottomPos: layout.rowsBottomPos[r],
                  ),
                );
              }
            }
          }
        } else if (heightItNeeds == GetDefaultSizes.getDefaultRowHeight() &&
            row == layout.rowsBottomPos.length - 1) {
          int i = row;
          while (layout.rowsBottomPos[i] ==
                  GetDefaultSizes.getDefaultRowHeight() &&
              row > 0) {
            layout.rowsBottomPos.removeLast();
            changeSet.addUpdate(RowsBottomPosUpdate(sheetId, i));
            i--;
          }
        }
      }
    }
    return changeSet;
  }

  @override
  SheetDataUpdate setLayout(int sheetId, LayoutData layoutData) {
    layoutCache.setLayout(sheetId, layoutData);
    return SheetDataUpdate(sheetId, true, colHeaderHeight: layoutData.colHeaderHeight, rowHeaderWidth: layoutData.rowHeaderWidth, scrollOffsetX: layoutData.scrollOffsetX, scrollOffsetY: layoutData.scrollOffsetY);
  }
}
