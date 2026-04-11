import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/models/update_data.dart';

abstract class WorkbookRepository {
  int get currentSheetId;
  String get currentSheetName;
  List<int> getRecentSheetIds();
  Future<Either<Failure, void>> clearAllData();
  Future<Either<Failure, void>> loadRecentSheetIds();
  @useResult
  SheetDataUpdate addNewSheetId(int index);
}
