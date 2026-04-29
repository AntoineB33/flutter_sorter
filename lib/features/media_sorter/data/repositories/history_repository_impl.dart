import 'package:drift/drift.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/store/history_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final LoadedSheetsCache loadedSheetsDataStore;
  final WorkbookCache workbookCache;
  final SelectionCache selectionCache;
  final HistoryCache historyCache;
  int chronoIdCounter = 0;
  bool isLastChangeInSameEditingMode = false;

  int get currentSheetId => workbookCache.currentSheetId;
  CoreSheetContent get currentSheet =>
      loadedSheetsDataStore.getSheet(currentSheetId);
  HistoryData get historyData => historyCache[currentSheetId]!;

  HistoryRepositoryImpl(
    this.loadedSheetsDataStore,
    this.workbookCache,
    this.selectionCache,
    this.historyCache,
  );

  @override
  List<SyncRequest> moveInUpdateHistory(int direction) {
    if (historyData.historyIndex + direction < 0 ||
        historyData.historyIndex + direction >=
            historyData.updateHistories.length) {
      return [];
    }
    historyData.historyIndex += direction;
    final updateData = historyData.updateHistories[historyData.historyIndex];
    return updateData;
  }

  List<SyncRequest> _removeLastHistoryBcEdit() {
    final lastUpdateData =
        historyData.updateHistories.last.first as SyncRequestImpl;
    List<SyncRequest> changeList = [];
    changeList.add(
      SyncRequestImpl(
        HistoryWrapper(
          UpdateHistoriesTableCompanion(
            chronoId: Value(chronoIdCounter++),
            sheetId: Value(currentSheetId),
          ),
        ),
        DataBaseOperationType.delete,
      ),
    );
    historyData.updateHistories.removeAt(historyData.historyIndex);
    historyData.historyIndex--;
    changeList.add(
      SyncRequestImpl(
        SheetDataWrapper(
          SheetDataTablesCompanion(
            sheetId: Value(currentSheetId),
            historyIndex: Value(historyData.historyIndex),
          ),
        ),
        DataBaseOperationType.update,
      ),
    );
    return changeList;
  }

  @override
  List<SyncRequest> commitHistory(
    List<SyncRequest> updates,
    int sheetId,
    bool isFromEditing,
  ) {
    List<SyncRequest> changeList = [];
    List<SyncRequest> historyUpdates = updates.map((e) {
      switch((e as SyncRequestImpl).companionWrapper) {
        case SheetCellWrapper():
          final cellUpdate = (e.companionWrapper as SheetCellWrapper).companion;
          return SyncRequestImpl(
            SheetCellWrapper(
              SheetCellsTableCompanion(
                sheetId: Value(sheetId),
                row: cellUpdate.row,
                col: cellUpdate.col,
                content: cellUpdate.content,
                newValue: cellUpdate.newValue,
              ),
            ),
            DataBaseOperationType.update,
          );
        case HistoryWrapper():
          final historyUpdate = (e.companionWrapper as HistoryWrapper).companion;
          return SyncRequestImpl(
            HistoryWrapper(
              UpdateHistoriesTableCompanion(
                chronoId: Value(chronoIdCounter++),
                sheetId: Value(sheetId),
                updates: Value(historyUpdate.updates),
              ),
            ),
            DataBaseOperationType.delete,
          );
        case SheetDataWrapper():
          final sheetDataUpdate = (e.companionWrapper as SheetDataWrapper).companion;
          return SyncRequestImpl(
            SheetDataWrapper(
              SheetDataTablesCompanion(
                sheetId: Value(sheetId),
                historyIndex: Value(sheetDataUpdate.historyIndex),
              ),
            ),
            DataBaseOperationType.update,
          );
        default:
      return e;
    }).toList();
    changeList.add(
      SyncRequestImpl(
        HistoryWrapper(
          UpdateHistoriesTableCompanion(
            chronoId: Value(chronoIdCounter++),
            sheetId: Value(currentSheetId),
            updates: Value(updates),
          ),
        ),
        DataBaseOperationType.delete,
      ),
    );
    if (isFromEditing) {
      if (isLastChangeInSameEditingMode) {
        final cellUpdate = ((updates.first as SyncRequestImpl).companionWrapper as SheetCellWrapper).companion;
        final lastUpdateData = historyData.updateHistories.last;
        final prevCellUpdate =
            lastUpdateData.first as SyncRequestImpl;
        if (loadedSheetsDataStore.getCellContent(sheetId, cellUpdate.row.value, cellUpdate.col.value) == (prevCellUpdate.companionWrapper as SheetCellWrapper).companion.content.value) {
          isLastChangeInSameEditingMode = false;
          return _removeLastHistoryBcEdit();
        }
        return [];
      }
      isLastChangeInSameEditingMode = true;
    }
    if (historyData.historyIndex < historyData.updateHistories.length - 1) {
      for (
        int i = historyData.historyIndex + 1;
        i < historyData.updateHistories.length;
        i++
      ) {
        historyData.updateHistories[i].addOtherwiseRemove = false;
        changeList.addUpdate(historyData.updateHistories[i]);
      }
      historyData.updateHistories = historyData.updateHistories.sublist(
        0,
        historyData.historyIndex + 1,
      );
    }
    historyData.updateHistories.add(updateData);
    changeList.addUpdate(updateData);
    historyData.historyIndex++;
    if (historyData.historyIndex == SpreadsheetConstants.historyLimit) {
      historyData.updateHistories.first.addOtherwiseRemove = false;
      changeList.addUpdate(historyData.updateHistories.first);
      historyData.updateHistories.removeAt(0);
      historyData.historyIndex--;
    }
    final historyChg = SheetDataUpdate(
      currentSheetId,
      true,
      historyIndex: historyData.historyIndex,
    );
    changeList.addUpdate(historyChg);
    return changeList;
  }

  @override
  UpdateUnit commitSelection(SelectionState selectionState) {
    var selectionData = selectionCache.getSelectionData(currentSheetId);
    if (selectionData.primSelHistoryId <
        selectionData.selectionStates.length - 1) {
      final newPrimSelHistory = selectionData.selectionStates.sublist(
        0,
        selectionData.primSelHistoryId + 1,
      );
      selectionData.selectionStates
        ..clear()
        ..addAll(newPrimSelHistory);
    }
    selectionData.selectionStates.add(selectionState);
    selectionData = selectionData.copyWith(
      primSelHistoryId: selectionData.primSelHistoryId + 1,
    );
    const int primSelHistoryLimit = SpreadsheetConstants.primSelHistoryLimit;
    if (selectionData.primSelHistoryId == primSelHistoryLimit) {
      selectionData.selectionStates.removeAt(0);
      selectionData = selectionData.copyWith(
        primSelHistoryId: selectionData.primSelHistoryId - 1,
      );
    }
    selectionCache.setSelectionData(currentSheetId, selectionData);
    return SheetDataUpdate(
      currentSheetId,
      true,
      selectionHistory: selectionData,
    );
  }

  @override
  changeList addSheetId(int sheetId) {
    final historyData = HistoryData.empty();
    historyCache.setUpdateHistories(sheetId, historyData);
    final changeList = changeList();
    changeList.addUpdate(
      SheetDataUpdate(sheetId, true, historyIndex: historyData.historyIndex),
    );
    return changeList;
  }

  @override
  changeList stopEditing(bool escape) {
    changeList changeList = changeList();
    if (escape && isLastChangeInSameEditingMode) {
      changeList = _removeLastHistoryBcEdit();
    }
    isLastChangeInSameEditingMode = false;
    return changeList;
  }
}
