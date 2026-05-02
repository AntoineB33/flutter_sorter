import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/core_sheet_content.dart';

abstract class SheetDataRepository {
  bool containsSheetId(int sheetId);
  int rowCount(int sheetId);
  int colCount(int sheetId);
  CoreSheetContent getSheet(int sheetId);

  List<SyncRequest> delete();
  Future<void> copySelectionToClipboard();
  Future<Either<Failure, List<SyncRequest>>> pasteSelection();
  String getCellContent(CellPosition cell, int sheetId);

  List<SyncRequest> setColumnType(
    int colId,
    ColumnType newColumnType,
    int sheetId,
  );
  Future<Either<Failure, Unit>> loadSheet(int sheetId);

  List<SyncRequest> addNewSheet(int sheetId, String title);

  List<SyncRequest> update(List<SyncRequest> updates, int sheetId);

  List<SyncRequest> setCellUpdate(String newValue, int sheetId);
}
