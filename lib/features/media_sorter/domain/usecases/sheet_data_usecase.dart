import 'dart:async';
import 'dart:math';
import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/helpers/utils_services.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';

class SheetDataUsecase {
  final SheetDataRepository sheetDataRepository;
  final SortRepository sortRepository;
  final GridRepository gridRepository;
  final HistoryRepository historyRepository;

  final StreamSubscription<Failure> _failureSubscription;

  SheetDataUsecase({
    required this.sheetDataRepository,
    required this.sortRepository,
    required this.gridRepository,
    required this.historyRepository,
  }) : _failureSubscription = sheetDataRepository.failureStream.listen((failure) {
          UtilsServices.handleDataCorruption(Left(failure));
        });
  
  void dispose() {
    _failureSubscription.cancel();
  }

  bool containsSheetId(String sheetId) {
    return sheetDataRepository.containsSheetId(sheetId);
  }

  int rowCount(String sheetId) {
    return sheetDataRepository.rowCount(sheetId);
  }

  int colCount(String sheetId) {
    return sheetDataRepository.colCount(sheetId);
  }

  String getCellContent(int row, int col, String sheetId) {
    return sheetDataRepository.getCellContent(Point<int>(row, col), sheetId);
  }

  SheetData getSheet(String sheetId) {
    return sheetDataRepository.getSheet(sheetId);
  }

  void addPrevValue(List<UpdateUnit> updates, String sheetId) {
    for (var update in updates) {
      if (update is CellUpdate) {
        update.prevValue = sheetDataRepository.getCellContent(
          Point<int>(update.rowId, update.colId),
          sheetId,
        );
      } else if (update is ColumnTypeUpdate) {
        update.previousColumnType = sheetDataRepository.getColumnType(
          update.colId,
          sheetId,
        );
      }
    }
  }

  void applyUpdatesNoSort(
    List<UpdateUnit> updates,
    String sheetId,
    bool isFromHistory,
    bool isFromEditing,
  ) {
    if (!isFromHistory) {
      addPrevValue(updates, sheetId);
      historyRepository.commitHistory(updates, sheetId, isFromEditing);
    }
    sheetDataRepository.update(updates, sheetId);
  }

  List<CellUpdate> delete() {
    return sheetDataRepository.delete();
  }

  Future<Either<Failure, List<CellUpdate>>> paste() {
    return sheetDataRepository.pasteSelection();
  }

  Future<void> copyToClipboard() {
    return sheetDataRepository.copySelectionToClipboard();
  }
}
