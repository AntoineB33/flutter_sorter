import 'dart:async';
import 'dart:math';
import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
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

  SheetDataUsecase(
    this.sheetDataRepository,
    this.sortRepository,
    this.gridRepository,
    this.historyRepository,
    this.saveRepository,
  );

  bool containsSheetId(int sheetId) {
    return sheetDataRepository.containsSheetId(sheetId);
  }

  int rowCount(int sheetId) {
    return sheetDataRepository.rowCount(sheetId);
  }

  int colCount(int sheetId) {
    return sheetDataRepository.colCount(sheetId);
  }

  String getCellContent(int row, int col, int sheetId) {
    return sheetDataRepository.getCellContent(Point<int>(row, col), sheetId);
  }

  CoreSheetContent getSheet(int sheetId) {
    return sheetDataRepository.getSheet(sheetId);
  }

  void addPrevValue(Map<String, UpdateUnit> updates, int sheetId) {
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
      } else if (update is SheetDataUpdate) {
        if (update.newName != null) {
          update.prevName = sheetDataRepository.getSheetTitle(sheetId);
        }
        if (update.colHeaderHeight != null) {
          update.prevColHeaderHeight = sheetDataRepository.getColHeaderHeight(sheetId);
        }
        if (update.rowHeaderWidth != null) {
          update.prevRowHeaderWidth = sheetDataRepository.getRowHeaderWidth(sheetId);
        }
        if (update.primarySelectedCellX != null) {
          update.prevPrimarySelectedCellX = sheetDataRepository.getPrimarySelectedCellX(sheetId);
        }
        if (update.primarySelectedCellY != null) {
          update.prevPrimarySelectedCellY = sheetDataRepository.getPrimarySelectedCellY(sheetId);
        }
        if (update.scrollOffsetX != null) {
          update.prevScrollOffsetX = sheetDataRepository.getScrollOffsetX(sheetId);
        }
        if (update.scrollOffsetY != null) {
          update.prevScrollOffsetY = sheetDataRepository.getScrollOffsetY(sheetId);
        }
      }
    }
  }

  void applyUpdatesNoSort(
    Map<String, UpdateUnit> updates,
    int sheetId,
    bool isFromHistory,
    bool isFromEditing,
  ) {
    if (!isFromHistory) {
      addPrevValue(updates, sheetId);
      historyRepository.commitHistory(updates, sheetId, isFromEditing);
    }
    sheetDataRepository.update(updates, sheetId);
    saveRepository.save(updates);
  }

  void save(Map<String, UpdateUnit> updates) {
    saveRepository.save(updates);
  }

  Map<String, UpdateUnit> delete() {
    return sheetDataRepository.delete();
  }

  Future<Either<Failure, Map<String, UpdateUnit>>> paste() {
    return sheetDataRepository.pasteSelection();
  }

  Future<void> copyToClipboard() {
    return sheetDataRepository.copySelectionToClipboard();
  }
}
