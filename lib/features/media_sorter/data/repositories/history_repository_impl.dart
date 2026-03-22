import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final LoadedSheetsCache loadedSheetsDataStore;
  final WorkbookCache workbookCache;
  final SelectionCache selectionCache;
  int chronoIdCounter = 0;
  bool isLastChangeInSameEditingMode = false;

  String get currentSheetId => workbookCache.currentSheetId;
  SheetData get currentSheet => loadedSheetsDataStore.getSheet(currentSheetId);

  HistoryRepositoryImpl(this.loadedSheetsDataStore, this.workbookCache, this.selectionCache);

  @override
  UpdateData? moveInUpdateHistory(int direction) {
    if (currentSheet.historyIndex + direction < 0 ||
        currentSheet.historyIndex + direction >= currentSheet.updateHistories.length) {
      return null;
    }
    currentSheet.historyIndex += direction;
    final updateData = currentSheet.updateHistories[currentSheet.historyIndex];
    return updateData;
  }

  void _removeLastHistoryEditingMode(Map<String, UpdateUnit> updates) {
    UpdateData lastUpdateData = currentSheet.updateHistories.last;
    lastUpdateData.addOtherwiseRemove = false;
    currentSheet.updateHistories.removeAt(currentSheet.historyIndex);
    currentSheet.historyIndex--;
    updates[lastUpdateData.getStringKey()] = lastUpdateData;
    updates[SheetDataTables.historyIndexUpdateKey] = Pass();
  }
  
  @override
  void commitHistory(Map<String, UpdateUnit> updates, String sheetId, bool isFromEditing) {
    final sheet = loadedSheetsDataStore.getSheet(sheetId);
    final updateData = UpdateData(chronoIdCounter++, sheetId, updates);
    if (isFromEditing) {
      if (isLastChangeInSameEditingMode) {
        CellUpdate cellUpdate = updates.values.first as CellUpdate;
        UpdateData lastUpdateData = currentSheet.updateHistories.last;
        CellUpdate prevCellUpdate = lastUpdateData.updates.values.first as CellUpdate;
        if (cellUpdate.newValue == prevCellUpdate.prevValue) {
          _removeLastHistoryEditingMode(updates);
          isLastChangeInSameEditingMode = false;
          return;
        }
        cellUpdate.prevValue = prevCellUpdate.prevValue;
        sheet.updateHistories[sheet.historyIndex] = updateData;
        lastUpdateData.addOtherwiseRemove = false;
        updates[lastUpdateData.getStringKey()] = lastUpdateData;
        updates[updateData.getStringKey()] = updateData;
        return;
      }
      isLastChangeInSameEditingMode = true;
    }
    if (sheet.historyIndex < sheet.updateHistories.length - 1) {
      sheet.updateHistories = sheet.updateHistories.sublist(
        0,
        sheet.historyIndex + 1,
      );
    }
    sheet.updateHistories.add(updateData);
    updates[updateData.getStringKey()] = updateData;
    sheet.historyIndex++;
    if (sheet.historyIndex == 100) {
      updates[sheet.updateHistories.first.getStringKey()] = sheet.updateHistories.first;
      sheet.updateHistories.removeAt(0);
      sheet.historyIndex--;
    }
    updates[SheetDataTables.historyIndexUpdateKey] = Pass();
  }

  @override
  void stopEditing(Map<String, UpdateUnit> updates, bool escape) {
    if (escape && isLastChangeInSameEditingMode) {
      _removeLastHistoryEditingMode(updates);
    }
    isLastChangeInSameEditingMode = false;
  }
}