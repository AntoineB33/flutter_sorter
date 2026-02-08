import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/layout_calculator.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/get_default_sizes.dart';

class GridController {
  // --- states ---
  double row1ToScreenBottomHeight = 0.0;
  double colBToScreenRightWidth = 0.0;


  final SpreadsheetLayoutCalculator _layoutCalculator =
      SpreadsheetLayoutCalculator();
      
  GridController(); 


  int minRows(SheetData sheet, List<double> rowsBottomPos, int rowCount, double height) {
    double tableHeight = getTargetTop(sheet, rowCount - 1);
    if (height >= tableHeight) {
      return rowsBottomPos.length +
          ((height - getTargetTop(sheet, rowsBottomPos.length - 1) + 1) /
                  GetDefaultSizes.getDefaultRowHeight())
              .ceil();
    }
    return rowCount;
  }
  
  (int, int) updateRowColCount(SelectionData selection, SheetData sheet, int rowCount, int colCount, {
    double? visibleHeight,
    double? visibleWidth,
  }) {
    int targetRows = selection.tableViewRows;
    int targetCols = selection.tableViewCols;
    if (visibleHeight != null) {
      row1ToScreenBottomHeight = visibleHeight;
      targetRows = minRows(
        sheet,
        sheet.rowsBottomPos,
        rowCount,
        row1ToScreenBottomHeight,
      );
    }
    if (visibleWidth != null) {
      colBToScreenRightWidth = visibleWidth;
      targetCols = minCols(
        sheet,
        sheet.colRightPos,
        colCount,
        colBToScreenRightWidth,
      );
    }
    return (targetRows, targetCols);
  }

  void increaseColumnCount(int col, int rowCount, int colCount, SheetContent sheetContent) {
    if (col >= colCount) {
      final needed = col + 1 - colCount;
      for (var r = 0; r < rowCount; r++) {
        sheetContent.table[r].addAll(List.filled(needed, '', growable: true));
      }
      sheetContent.columnTypes.addAll(
        List.filled(needed, ColumnType.attributes),
      );
    }
  }

  void decreaseRowCount(int row, int rowCount, SheetContent sheetContent) {
    if (row == rowCount - 1) {
      while (row >= 0 &&
          !sheetContent.table[row].any((cell) => cell.isNotEmpty)) {
        sheetContent.table.removeLast();
        row--;
      }
    }
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

  double getTargetTop(SheetData sheet, int row) {
    if (row <= 0) return 0.0;
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

  double getTargetLeft(SheetData sheet, int col) {
    if (col <= 0) return 0.0;
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

  int minCols(SheetData sheet, List<double> colRightPos, int colCount, double width) {
    double tableWidth = getTargetLeft(sheet, colCount - 1);
    if (width >= tableWidth) {
      return colRightPos.length +
          ((width - getTargetLeft(sheet, colRightPos.length - 1) + 1) /
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

  String updateCell(int row, int col, SheetContent sheetContent, int rowCount, int colCount, String newValue) {
    String prevValue = '';
    if (newValue.isNotEmpty || (row < rowCount && col < colCount)) {
      if (row >= rowCount) {
        final needed = row + 1 - rowCount;
        sheetContent.table.addAll(
          List.generate(
            needed,
            (_) => List.filled(colCount, '', growable: true),
          ),
        );
      }
      increaseColumnCount(col, rowCount, colCount, sheetContent);
      prevValue = sheetContent.table[row][col];
      sheetContent.table[row][col] = newValue;
    }

    // Clean up empty rows/cols at the end
    if (newValue.isEmpty &&
        row < rowCount &&
        col < colCount &&
        (row == rowCount - 1 || col == colCount - 1) &&
        prevValue.isNotEmpty) {
      decreaseRowCount(row, rowCount, sheetContent);
      if (col == colCount - 1) {
        int colId = col;
        bool canRemove = true;
        while (canRemove && colId >= 0) {
          for (var r = 0; r < rowCount; r++) {
            if (sheetContent.table[r][colId].isNotEmpty) {
              canRemove = false;
              break;
            }
          }
          if (canRemove) {
            for (var r = 0; r < rowCount; r++) {
              sheetContent.table[r].removeLast();
            }
            colId--;
          }
        }
      }
    }
    return prevValue;
  }

}
