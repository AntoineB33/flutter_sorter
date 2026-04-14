import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/data/models/column_type.dart';
import 'package:trying_flutter/features/media_sorter/data/models/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/data/models/update_data.dart';

abstract class SheetDataRepository {
  bool containsSheetId(int sheetId);
  int rowCount(int sheetId);
  int colCount(int sheetId);
  CoreSheetContent getSheet(int sheetId);
  @useResult
  ChangeSet delete();
  Future<void> copySelectionToClipboard();
  Future<Either<Failure, IMap<String, UpdateUnit>>> pasteSelection();
  String getCellContent(CellPosition cell, int sheetId);
  @useResult
  ColumnTypeUpdate getColumnTypeUpdate(int colId, ColumnType newColumnType, int sheetId);
  Future<Either<Failure, Unit>> loadSheet(int sheetId);
  @useResult
  ChangeSet addNewSheet(int sheetId, String title);
  @useResult
  ChangeSet update(IMap<String, UpdateUnit> updates, int sheetId);
}
