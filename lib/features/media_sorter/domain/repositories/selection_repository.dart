import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';

abstract class SelectionRepository {
  Stream<Failure> get failureStream;
  int get primarySelectedCellX;
  int get primarySelectedCellY;
  bool containsSheetId(int sheetId);
  double getScrollOffsetX(int sheetId);
  double getScrollOffsetY(int sheetId);
  List<int> getSheetIds();
  Future<Either<Failure, void>> loadLastSelections(bool lastSelectionLoaded);
  Future<Either<Failure, void>> loadLastSelection();
  void saveLastSelection();
  void saveAllLastSelected();
  void setPrimarySelection(int row, int col, bool keepSelection);
  void clearLastSelection();
  void clearSheetSelection(int sheetId);
  SelectionData getSelectionData(int sheetId);
  void selectAll();
  void setSelectionData(int sheetId, SelectionData selectionData);
  void removeSelectionData(int sheetId);
}
