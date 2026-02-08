import 'dart:math';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/spreadsheet_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/get_default_sizes.dart';

class SpreadsheetLayoutDelegate {
  final SpreadsheetController manager;
  final GridController _gridController;
  final SelectionController _selectionController;
  final SheetDataController _dataController;

  SpreadsheetLayoutDelegate(
    this.manager,
    this._gridController,
    this._selectionController,
    this._dataController,
  );

  void adjustRowHeightAfterUpdate(
    int row,
    int col,
    String newValue,
    String prevValue,
  ) {
    if (row >= _dataController.sheet.rowsBottomPos.length &&
        row >= _dataController.rowCount) {
      updateRowColCount(
        visibleHeight: _gridController.row1ToScreenBottomHeight,
        visibleWidth: _gridController.colBToScreenRightWidth,
        notify: false,
      );
      return;
    }

    double heightItNeeds = _dataController.calculateRequiredRowHeight(
      newValue,
      col,
    );

    if (heightItNeeds > GetDefaultSizes.getDefaultRowHeight() &&
        _dataController.sheet.rowsBottomPos.length <= row) {
      int prevRowsBottomPosLength = _dataController.sheet.rowsBottomPos.length;
      _dataController.sheet.rowsBottomPos.addAll(
        List.filled(row + 1 - _dataController.sheet.rowsBottomPos.length, 0),
      );
      for (int i = prevRowsBottomPosLength; i <= row; i++) {
        _dataController.sheet.rowsBottomPos[i] = i == 0
            ? GetDefaultSizes.getDefaultRowHeight()
            : _dataController.sheet.rowsBottomPos[i - 1] +
                  GetDefaultSizes.getDefaultRowHeight();
      }
    }

    if (row < _dataController.sheet.rowsBottomPos.length) {
      if (_dataController.sheet.rowsManuallyAdjustedHeight.length <= row ||
          !_dataController.sheet.rowsManuallyAdjustedHeight[row]) {
        double currentHeight = _dataController.getRowHeight(row);
        if (heightItNeeds < currentHeight) {
          double heightItNeeded = _dataController.calculateRequiredRowHeight(
            prevValue,
            col,
          );
          if (heightItNeeded == currentHeight) {
            double newHeight = heightItNeeds;
            if (row < _dataController.sheetContent.table.length) {
              for (int j = 0; j < _dataController.colCount; j++) {
                if (j == col) continue;
                newHeight = max(
                  _dataController.calculateRequiredRowHeight(
                    _dataController.sheetContent.table[row][j],
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
                r < _dataController.sheet.rowsBottomPos.length;
                r++
              ) {
                _dataController.sheet.rowsBottomPos[r] -= heightDiff;
              }
              if (newHeight == GetDefaultSizes.getDefaultRowHeight()) {
                int removeFrom = _dataController.sheet.rowsBottomPos.length;
                for (
                  int r = _dataController.sheet.rowsBottomPos.length - 1;
                  r >= 0;
                  r--
                ) {
                  if (r <
                              _dataController
                                  .sheet
                                  .rowsManuallyAdjustedHeight
                                  .length &&
                          _dataController.sheet.rowsManuallyAdjustedHeight[r] ||
                      _dataController.sheet.rowsBottomPos[r] >
                          (r == 0
                                  ? 0
                                  : _dataController.sheet.rowsBottomPos[r -
                                        1]) +
                              GetDefaultSizes.getDefaultRowHeight()) {
                    break;
                  }
                  removeFrom--;
                }
                _dataController.sheet.rowsBottomPos = _dataController
                    .sheet
                    .rowsBottomPos
                    .sublist(0, removeFrom);
              }
            }
          }
        } else if (heightItNeeds > currentHeight) {
          double heightDiff = heightItNeeds - currentHeight;
          for (
            int r = row;
            r < _dataController.sheet.rowsBottomPos.length;
            r++
          ) {
            _dataController.sheet.rowsBottomPos[r] =
                _dataController.sheet.rowsBottomPos[r] + heightDiff;
          }
        }
      }
    } else if (heightItNeeds == GetDefaultSizes.getDefaultRowHeight() &&
        row == _dataController.sheet.rowsBottomPos.length - 1) {
      int i = row;
      while (_dataController.sheet.rowsBottomPos[i] ==
              GetDefaultSizes.getDefaultRowHeight() &&
          row > 0) {
        _dataController.sheet.rowsBottomPos.removeLast();
        i--;
      }
    }
    updateRowColCount(
      visibleHeight: _gridController.row1ToScreenBottomHeight,
      visibleWidth: _gridController.colBToScreenRightWidth,
      notify: false,
    );
  }
}
