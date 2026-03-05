import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class SortRepository {
  Stream<UpdateRequest> get updateDataStream;
  Stream<Failure?> get failureStream;
  Stream<void> get progressStream;
  Stream<void> get sortStatusStream;
  bool toSort(String sheetId);
  bool sortedWithValidSort(String sheetId);
  void sortMedia(String sheetId);
  Future<void> calculateOnChange();
  Future<void> saveAllSortStatus();
}