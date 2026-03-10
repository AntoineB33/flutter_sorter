import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/get_default_sizes.dart';

class GridRepositoryImpl implements GridRepository {
  final LoadedSheetsCache loadedSheetsCache;

  GridRepositoryImpl(this.loadedSheetsCache);

  int rowCount(String sheetId) {
    return loadedSheetsCache.rowCount(sheetId);
  }

  int colCount(String sheetId) {
    return loadedSheetsCache.colCount(sheetId);
  }

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
  void adjustRowHeightAfterUpdate(String sheetId, UpdateData updateData) {
    SheetData sheet = loadedSheetsCache.getSheet(sheetId);
    for (var update in updateData.updates) {
      if (update is CellUpdate) {
        final int row = update.rowId;
        final int col = update.colId;
        final String newValue = update.newValue;
        final String prevValue = update.prevValue;

        if (row >= sheet.rowsBottomPos.length &&
            row >= rowCount(sheetId)) {
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
  /// Calculates offsets and scrolls to ensure the target cell is visible.
  @override
  void scrollToCell(int rowId, int colId) {
    bool saveSelection = false;
    bool scrollX = true;
    bool scrollY = true;
    if (rowId > 0) {
      // Vertical Logic
      final double targetTop = getTargetTop(rowId) - getTargetTop(1);
      final double targetBottom = getTargetTop(rowId + 1);
      final double verticalViewport =
          verticalController.position.viewportDimension -
          currentSheet.rowHeaderWidth;

      if (targetTop < verticalController.offset) {
        saveSelection = true;
        selectionDataStore.scrollOffsetX = targetTop;
      } else if (targetBottom > verticalController.offset + verticalViewport) {
        saveSelection = true;
        selectionDataStore.scrollOffsetX = targetBottom - verticalViewport;
        updateRowColCount(true, visibleHeight: targetBottom);
      } else {
        scrollY = false;
      }
    }

    if (cell.y > 0) {
      // Horizontal Logic
      final double targetLeft = getTargetLeft(cell.y) - getTargetLeft(1);
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
        selectionDataStore.scrollOffsetY = targetRight - horizontalViewport;
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
}