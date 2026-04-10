import 'dart:async';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/data/models/column_type.dart';
import 'package:trying_flutter/features/media_sorter/data/models/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/data/models/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/save_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';

class SheetDataUsecase {
  final SheetDataRepository sheetDataRepository;
  final SortRepository sortRepository;
  final GridRepository gridRepository;
  final SelectionRepository selectionRepository;
  final HistoryRepository historyRepository;
  final SaveRepository saveRepository;

  SheetDataUsecase(
    this.sheetDataRepository,
    this.sortRepository,
    this.gridRepository,
    this.selectionRepository,
    this.historyRepository,
    this.saveRepository,
  );

  int rowCount(int sheetId) {
    return sheetDataRepository.rowCount(sheetId);
  }

  int colCount(int sheetId) {
    return sheetDataRepository.colCount(sheetId);
  }

  String getCellContent(int row, int col, int sheetId) {
    return sheetDataRepository.getCellContent(CellPosition(row, col), sheetId);
  }

  @useResult
  ColumnTypeUpdate getColumnTypeUpdate(int colId, ColumnType newColumnType, int sheetId) {
    return sheetDataRepository.getColumnTypeUpdate(colId, newColumnType, sheetId);
  }

  CoreSheetContent getSheet(int sheetId) {
    return sheetDataRepository.getSheet(sheetId);
  }

  void applyUpdatesNoSort(
    IMap<String, UpdateUnit> updates,
    int sheetId,
    bool isFromHistory,
    bool isFromEditing,
  ) {
    ChangeSet changeSet = ChangeSet(initialChanges: updates);
    if (!isFromHistory) {
      changeSet.merge(
        historyRepository.commitHistory(updates, sheetId, isFromEditing),
      );
    }
    changeSet.merge(sheetDataRepository.update(updates, sheetId));
    saveRepository.save(changeSet);
  }

  @useResult
  ChangeSet delete() {
    return sheetDataRepository.delete();
  }

  Future<Either<Failure, IMap<String, UpdateUnit>>> paste() {
    return sheetDataRepository.pasteSelection();
  }

  Future<void> copyToClipboard() {
    return sheetDataRepository.copySelectionToClipboard();
  }
}
