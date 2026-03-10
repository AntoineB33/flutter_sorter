import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';

abstract class SelectionRepository {
  Future<Either<Failure, void>> loadLastSelections(bool lastSelectionLoaded);
  Future<Either<Failure, void>> loadLastSelection();
  void saveLastSelection();
  Future<Either<Failure, void>> sheetSwitch();
  void setPrimarySelection(int row, int col, bool keepSelection);
  void stopEditing();
}
