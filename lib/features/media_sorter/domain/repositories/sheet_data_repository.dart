import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/core_sheet_content.dart';

abstract class SheetDataRepository {
  bool containsSheetId(int sheetId);
  int rowCount(int sheetId);
  int colCount(int sheetId);
  CoreSheetContent getSheet(int sheetId);

  void delete();
  Future<void> copySelectionToClipboard();
  Future<Either<Failure, Unit>> pasteSelection();
  String getCellContent(CellPosition cell, int sheetId);

  void setColumnType(
    int colId,
    ColumnType newColumnType,
    int sheetId,
  );
  Future<Either<Failure, Unit>> loadSheet(int sheetId);

  void addNewSheet(int sheetId, String title);

  void setCellUpdate(int rowId, int colId, String newValue, int sheetId);
}
