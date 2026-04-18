import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/features/media_sorter/data/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/store/history_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/update_data.dart';
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
  UpdateData? moveInUpdateHistory(int direction) {
    if (historyData.historyIndex + direction < 0 ||
        historyData.historyIndex + direction >=
            historyData.updateHistories.length) {
      return null;
    }
    historyData.historyIndex += direction;
    final updateData = historyData.updateHistories[historyData.historyIndex];
    return updateData;
  }

  @useResult
  ChangeSet _removeLastHistoryBcEdit() {
    UpdateData lastUpdateData = historyData.updateHistories.last;
    lastUpdateData.addOtherwiseRemove = false;
    historyData.updateHistories.removeAt(historyData.historyIndex);
    historyData.historyIndex--;
    ChangeSet changeSet = ChangeSet();
    changeSet.addUpdate(lastUpdateData);
    final historyChg = SheetDataUpdate(
      currentSheetId,
      true,
      historyIndex: historyData.historyIndex,
    );
    changeSet.addUpdate(historyChg);
    return changeSet;
  }

  @override
  ChangeSet commitHistory(
    IMap<String, SyncRequest> updates,
    int sheetId,
    bool isFromEditing,
  ) {
    final updateData = UpdateData(chronoIdCounter++, sheetId, updates, true);
    final changeSet = ChangeSet(initialChanges: updates);
    if (isFromEditing) {
      if (isLastChangeInSameEditingMode) {
        CellUpdate cellUpdate = updates.values.first as CellUpdate;
        UpdateData lastUpdateData = historyData.updateHistories.last;
        CellUpdate prevCellUpdate =
            lastUpdateData.updates.values.first as CellUpdate;
        if (cellUpdate.newValue == prevCellUpdate.prevValue) {
          isLastChangeInSameEditingMode = false;
          return _removeLastHistoryBcEdit();
        }
        lastUpdateData.addOtherwiseRemove = true;
        changeSet.addUpdate(lastUpdateData);
        changeSet.addUpdate(updateData);
        historyData.updateHistories[historyData.historyIndex] = updateData;
        return changeSet;
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
        changeSet.addUpdate(historyData.updateHistories[i]);
      }
      historyData.updateHistories = historyData.updateHistories.sublist(
        0,
        historyData.historyIndex + 1,
      );
    }
    historyData.updateHistories.add(updateData);
    changeSet.addUpdate(updateData);
    historyData.historyIndex++;
    if (historyData.historyIndex == SpreadsheetConstants.historyLimit) {
      historyData.updateHistories.first.addOtherwiseRemove = false;
      changeSet.addUpdate(historyData.updateHistories.first);
      historyData.updateHistories.removeAt(0);
      historyData.historyIndex--;
    }
    final historyChg = SheetDataUpdate(
      currentSheetId,
      true,
      historyIndex: historyData.historyIndex,
    );
    changeSet.addUpdate(historyChg);
    return changeSet;
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
  ChangeSet addSheetId(int sheetId) {
    final historyData = HistoryData.empty();
    historyCache.setUpdateHistories(sheetId, historyData);
    final changeSet = ChangeSet();
    changeSet.addUpdate(
      SheetDataUpdate(sheetId, true, historyIndex: historyData.historyIndex),
    );
    return changeSet;
  }

  @override
  ChangeSet stopEditing(bool escape) {
    ChangeSet changeSet = ChangeSet();
    if (escape && isLastChangeInSameEditingMode) {
      changeSet = _removeLastHistoryBcEdit();
    }
    isLastChangeInSameEditingMode = false;
    return changeSet;
  }
}
