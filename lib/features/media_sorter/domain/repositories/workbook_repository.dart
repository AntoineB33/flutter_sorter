import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';

abstract class WorkbookRepository {
  String get currentSheetId;
  String get currentSheetName;
  List<String> getRecentSheetIds();
  void saveRecentSheetIds();
  bool containsSheetId(String sheetId);
  Future<Either<Failure, void>> clearAllData();
  Future<Either<Failure, void>> loadRecentSheetIds();
  void addNewSheetId(String sheetId, int index);
}
