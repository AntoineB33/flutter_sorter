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
  Map<String, UpdateUnit> delete();
  Future<void> copySelectionToClipboard();
  Future<Either<Failure, Map<String, UpdateUnit>>> pasteSelection();
  String getCellContent(Point<int> cell, int sheetId);
  ColumnType getColumnType(int colId, int sheetId);
  String getSheetTitle(int sheetId);
  double getColHeaderHeight(int sheetId);
  double getRowHeaderWidth(int sheetId);
  int getPrimarySelectedCellX(int sheetId);
  int getPrimarySelectedCellY(int sheetId); 
  double getScrollOffsetX(int sheetId);
  double getScrollOffsetY(int sheetId);
  Future<Either<Failure, void>> loadSheet(int sheetId);
  Future<void> addNewSheet(int sheetId);
  void update(Map<String, UpdateUnit> updates, int sheetId);
}
