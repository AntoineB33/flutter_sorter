import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';

abstract class SelectionRepository {
  Stream<Failure> get failureStream;
  Point<int> get primarySelectedCell;
  Future<Either<Failure, void>> loadLastSelections(bool lastSelectionLoaded);
  Future<Either<Failure, void>> loadLastSelection();
  void saveLastSelection();
  void saveAllLastSelected();
  void setPrimarySelection(int row, int col, bool keepSelection);
  void clearLastSelection();
  SelectionData getSelectionData(String sheetId);
  void selectAll();
  void setSelectionData(String sheetId, SelectionData selectionData);
}
