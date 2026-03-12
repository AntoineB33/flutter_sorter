import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';

abstract class SelectionRepository {
  Point<int> get primarySelectedCell;
  Future<Either<Failure, void>> loadLastSelections(bool lastSelectionLoaded);
  Future<Either<Failure, void>> loadLastSelection();
  void saveLastSelection();
  Future<Either<Failure, void>> sheetSwitch();
  void setPrimarySelection(int row, int col, bool keepSelection);
  void stopEditing();
  void clearLastSelection(String sheetId);
  SelectionData getSelectionData(String sheetId);
  bool isSorting(String sheetId);
}
