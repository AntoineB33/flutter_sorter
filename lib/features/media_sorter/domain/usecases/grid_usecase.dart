import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';

class GridUsecase {
  final GridRepository repository;

  GridUsecase(this.repository);

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
}