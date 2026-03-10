import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class SortRepository {
  Stream<void> get progressStream;
  Stream<void> get sortStatusStream;
  Stream<void> get saveStream;
  Future<Either<Failure, void>> loadSortStatus();
  bool toSort(String sheetId);
  bool sortedWithValidSort(String sheetId);
  void handleSortProgressDataMsg(SortProgressDataMsg sortProgressDataMsg, String sheetId);
  List<UpdateUnit> sortMedia(String sheetId);
  Stream<SortProgressDataMsg> calculateOnChange();
  Future<void> saveAllSortStatus();
  Future<void> saveDataProgress(String sheetId);
}
