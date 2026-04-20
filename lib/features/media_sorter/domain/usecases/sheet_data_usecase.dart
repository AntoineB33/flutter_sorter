import 'dart:async';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/local_data_source.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';

class SheetDataUsecase {
  final SheetDataRepository sheetDataRepository;
  final SortRepository sortRepository;
  final GridRepository gridRepository;
  final SelectionRepository selectionRepository;
  final HistoryRepository historyRepository;
  final ILocalDataSource saveRepository;

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

  
  List<SyncRequest> setColumnType(int colId, ColumnType newColumnType, int sheetId) {
    return sheetDataRepository.setColumnType(colId, newColumnType, sheetId);
  }

  CoreSheetContent getSheet(int sheetId) {
    return sheetDataRepository.getSheet(sheetId);
  }

  void applyUpdatesNoSort(
    List<SyncRequest> updates,
    int sheetId,
    bool isFromHistory,
    bool isFromEditing,
  ) {
    if (!isFromHistory) {
      updates.addAll(
        historyRepository.commitHistory(updates, sheetId, isFromEditing),
      );
    }
    updates.addAll(sheetDataRepository.update(updates, sheetId));
    saveRepository.save(updates);
  }

  
  List<SyncRequest> delete() {
    return sheetDataRepository.delete();
  }

  Future<Either<Failure, List<SyncRequest>>> paste() {
    return sheetDataRepository.pasteSelection();
  }

  Future<void> copyToClipboard() {
    return sheetDataRepository.copySelectionToClipboard();
  }

  
  ChangeSet setCellContent(String newValue, int sheetId) {
    return sheetDataRepository.setCellContent(newValue, sheetId);
  }
}
