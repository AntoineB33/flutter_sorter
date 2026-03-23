import 'dart:async';
import 'dart:math';
import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/helpers/utils_services.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/save_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';

class SheetDataUsecase {
  final SheetDataRepository sheetDataRepository;
  final SortRepository sortRepository;
  final GridRepository gridRepository;
  final HistoryRepository historyRepository;
  final SaveRepository saveRepository;

  final StreamSubscription<Failure> _failureSubscription;

  SheetDataUsecase(
    this.sheetDataRepository,
    this.sortRepository,
    this.gridRepository,
    this.historyRepository,
    this.saveRepository,
  ) : _failureSubscription = sheetDataRepository.failureStream.listen((failure) {
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

  @useResult
  void addPrevValue(Map<String, UpdateUnit> updates, String sheetId) {
    for (var update in updates.values) {
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
      } else if (update is SheetNameUpdate) {
        update.previousName = sheetDataRepository.getSheetName(sheetId);
      }
    }
  }

  void applyUpdatesNoSort(
    Map<String, UpdateUnit> updates,
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
  void save(Map<String, UpdateUnit> updates) {
    saveRepository.save(updates);
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
