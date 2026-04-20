import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';

abstract class WorkbookRepository {
  int get currentSheetId;
  String get currentSheetName;
  List<int> getRecentSheetIds();
  Future<Either<Failure, void>> clearAllData();
  Future<Either<Failure, void>> loadRecentSheetIds();
  
  List<SyncRequest> addNewSheetId(int index);
}
