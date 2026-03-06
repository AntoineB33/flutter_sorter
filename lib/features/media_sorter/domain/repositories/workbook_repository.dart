import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/data_load_result.dart';

abstract class WorkbookRepository {
  Future<Either<Failure, DataLoadResult>> init();
  void checkSortStatusSheetIds();
}