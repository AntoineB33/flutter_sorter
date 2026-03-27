import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class SheetDataRepository {
  Stream<Failure> get failureStream;
  bool containsSheetId(int sheetId);
  int rowCount(int sheetId);
  int colCount(int sheetId);
  CoreSheetContent getSheet(int sheetId);
  Map<Record, UpdateUnit> delete();
  Future<void> copySelectionToClipboard();
  Future<Either<Failure, Map<Record, UpdateUnit>>> pasteSelection();
  String getCellContent(Point<int> cell, int sheetId);
  ColumnType getColumnType(int colId, int sheetId);
  String getSheetName(int sheetId);
  Future<Either<Failure, void>> loadSheet(int sheetId);
  Future<void> addNewSheet(int sheetId);
  void update(List<UpdateUnit> updates, int sheetId);
}
