import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';

abstract class WorkbookRepository {
  int get currentSheetId;
  String get currentSheetName;
  int getNewSheetId();
  List<int> getRecentSheetIds();
  void saveRecentSheetIds();
  bool containsSheetId(int sheetId);
  Future<Either<Failure, void>> clearAllData();
  Future<Either<Failure, void>> loadRecentSheetIds();
  void addNewSheetId(int sheetId, int index);
}
