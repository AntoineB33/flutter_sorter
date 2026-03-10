import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class SheetDataRepository {
  String get currentSheetId;
  bool containsSheetId(String sheetId);
  int rowCount(String sheetId);
  int colCount(String sheetId);
  void update(List<UpdateUnit> updates, String sheetId);
  List<CellUpdate> delete(List<Point<int>> cells);
  Future<void> copySelectionToClipboard();
  Future<Either<Failure, List<CellUpdate>>> pasteSelection();
  List<CellUpdate> setCellContent(Point<int> cell, String newVal);
}