import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';

abstract class WorkbookRepository {
  int get currentSheetId;
  String get currentSheetName;
  List<int> getRecentSheetIds();
  Future<Either<Failure, void>> clearAllData();
  Future<Either<Failure, void>> loadRecentSheetIds();
  
  void addNewSheetId(int index);
}
