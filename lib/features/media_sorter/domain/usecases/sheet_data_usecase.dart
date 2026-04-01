import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
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
    return sheetDataRepository.getCellContent(CellPosition(row, col), sheetId);
  }

  CoreSheetContent getSheet(int sheetId) {
    return sheetDataRepository.getSheet(sheetId);
  }

  void addPrevValue(Map<String, UpdateUnit> updates, int sheetId) {
    for (var entry in updates.entries) {
      var update = entry.value;
      if (update is CellUpdate) {
        update.prevValue = sheetDataRepository.getCellContent(
          CellPosition(update.rowId, update.colId),
          sheetId,
        );
      } else if (update is ColumnTypeUpdate) {
        update.previousColumnType = sheetDataRepository.getColumnType(
          update.colId,
          sheetId,
        );
      } else if (update is SheetDataUpdate) {
        if (update.newName != null) {
          updates[entry.key] = update.merge(
            SheetDataUpdate(
              update.sheetId,
              update.addOtherwiseRemove,
              prevName: sheetDataRepository.getSheetTitle(sheetId),
            ),
          );
        }
        if (update.colHeaderHeight != null) {
          updates[entry.key] = update.merge(
            SheetDataUpdate(
              update.sheetId,
              update.addOtherwiseRemove,
              prevColHeaderHeight: gridRepository
                  .getLayout(sheetId)
                  .colHeaderHeight,
            ),
          );
        }
        if (update.rowHeaderWidth != null) {
          updates[entry.key] = update.merge(
            SheetDataUpdate(
              update.sheetId,
              update.addOtherwiseRemove,
              prevRowHeaderWidth: gridRepository
                  .getLayout(sheetId)
                  .rowHeaderWidth,
            ),
          );
        }
      }
    }
  }

  void save(Map<String, UpdateUnit> updates) {
    saveRepository.save(updates);
  }

  void applyUpdatesNoSort(
    Map<String, UpdateUnit> updates,
    int sheetId,
    bool isFromHistory,
    bool isFromEditing,
  ) {
    if (!isFromHistory) {
      historyRepository.commitHistory(updates, sheetId, isFromEditing);
    }
    save(updates);
    sheetDataRepository.update(updates, sheetId);
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
