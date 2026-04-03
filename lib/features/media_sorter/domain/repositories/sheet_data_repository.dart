
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/core/entities/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

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
  ColumnType getColumnType(int colId, int sheetId);
  String getSheetTitle(int sheetId);
  Future<Either<Failure, Unit>> loadSheet(int sheetId);
  Future<void> addNewSheet(int sheetId);
  @useResult
  ChangeSet update(IMap<String, UpdateUnit> updates, int sheetId);
}
