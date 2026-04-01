import 'package:meta/meta.dart';
import 'package:trying_flutter/features/media_sorter/data/services/add_update.dart';
import 'package:trying_flutter/features/media_sorter/data/store/history_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/history_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
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

  void _removeLastHistoryEditingMode(Map<String, UpdateUnit> updates) {
    UpdateData lastUpdateData = historyData.updateHistories.last;
    lastUpdateData.addOtherwiseRemove = false;
    historyData.updateHistories.removeAt(historyData.historyIndex);
    historyData.historyIndex--;
    AddUpdate.addUpdate(updates, lastUpdateData);
    final historyChg = SheetDataUpdate(
      currentSheetId,
      true,
      historyIndex: historyData.historyIndex,
    );
    AddUpdate.addUpdate(updates, historyChg);
  }

  @override
  void commitHistory(
    Map<String, UpdateUnit> updates,
    int sheetId,
    bool isFromEditing,
  ) {
    final updateData = UpdateData(chronoIdCounter++, sheetId, updates, true);
    if (isFromEditing) {
      if (isLastChangeInSameEditingMode) {
        CellUpdate cellUpdate = updates.values.first as CellUpdate;
        UpdateData lastUpdateData = historyData.updateHistories.last;
        CellUpdate prevCellUpdate =
            lastUpdateData.updates.values.first as CellUpdate;
        if (cellUpdate.newValue == prevCellUpdate.prevValue) {
          _removeLastHistoryEditingMode(updates);
          isLastChangeInSameEditingMode = false;
          return;
        }
        cellUpdate.prevValue = prevCellUpdate.prevValue;
        historyData.updateHistories[historyData.historyIndex] = updateData;
        lastUpdateData.addOtherwiseRemove = false;
        AddUpdate.addUpdate(updates, lastUpdateData);
        AddUpdate.addUpdate(updates, updateData);
        return;
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
        AddUpdate.addUpdate(updates, historyData.updateHistories[i]);
      }
      historyData.updateHistories = historyData.updateHistories.sublist(
        0,
        historyData.historyIndex + 1,
      );
    }
    historyData.updateHistories.add(updateData);
    AddUpdate.addUpdate(updates, updateData);
    historyData.historyIndex++;
    if (historyData.historyIndex == 100) {
      historyData.updateHistories.first.addOtherwiseRemove = false;
      AddUpdate.addUpdate(updates, historyData.updateHistories.first);
      historyData.updateHistories.removeAt(0);
      historyData.historyIndex--;
    }
    final historyChg = SheetDataUpdate(
      currentSheetId,
      true,
      historyIndex: historyData.historyIndex,
    );
    AddUpdate.addUpdate(updates, historyChg);
  }

  @override
  @useResult
  UpdateUnit newPrimarySelection(int rowId, int colId) {
    var selectionData = selectionCache.getSelectionData(currentSheetId);
    if (selectionData.primSelHistoryId < selectionData.primSelHistory.length - 1) {
      final newPrimSelHistory = selectionData.primSelHistory.sublist(0, selectionData.primSelHistoryId + 1);
      selectionData.primSelHistory..clear()..addAll(newPrimSelHistory);
    }
    selectionData.primSelHistory.add(CellPosition(rowId, colId));
    selectionData = selectionData.copyWith(primSelHistoryId: selectionData.primSelHistoryId + 1);
    const int primSelHistoryLimit = 30;
    if (selectionData.primSelHistoryId == primSelHistoryLimit) {
      selectionData.primSelHistory.removeAt(0);
      selectionData = selectionData.copyWith(primSelHistoryId: selectionData.primSelHistoryId - 1);
    }
    return SheetDataUpdate(
      currentSheetId,
      true,
      primSelHistory: selectionData.primSelHistory,
      primSelHistoryId: selectionData.primSelHistoryId == primSelHistoryLimit - 1 ? null : selectionData.primSelHistoryId,
    );
  }

  @override
  void stopEditing(bool escape, {Map<String, UpdateUnit>? updates}) {
    if (escape && isLastChangeInSameEditingMode) {
      _removeLastHistoryEditingMode(updates!);
    }
    isLastChangeInSameEditingMode = false;
  }
}
