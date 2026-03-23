import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class SheetDataRepository {
  Stream<Failure> get failureStream;
  bool containsSheetId(String sheetId);
  int rowCount(String sheetId);
  int colCount(String sheetId);
  SheetData getSheet(String sheetId);
  List<CellUpdate> delete();
  Future<void> copySelectionToClipboard();
  Future<Either<Failure, List<CellUpdate>>> pasteSelection();
  String getCellContent(Point<int> cell, String sheetId);
  ColumnType getColumnType(int colId, String sheetId);
  String getSheetName(String sheetId);
  Future<Either<Failure, void>> loadSheet(String sheetId);
  Future<void> addNewSheet(String sheetId);
  void update(List<UpdateUnit> updates, String sheetId);
}
