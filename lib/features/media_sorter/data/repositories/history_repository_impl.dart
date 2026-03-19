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

  String? get currentSheetId => workbookCache.currentSheetId;
  SheetData? get currentSheet => currentSheetId != null ? loadedSheetsDataStore.getSheet(currentSheetId!) : null;

  HistoryRepositoryImpl(this.loadedSheetsDataStore, this.workbookCache, this.selectionCache);

  @override
  UpdateData? moveInUpdateHistory(int direction) {
    if (currentSheet == null) return null;
    if (currentSheet!.historyIndex + direction < 0 ||
        currentSheet!.historyIndex + direction >= currentSheet!.updateHistories.length) {
      return null;
    }
    currentSheet!.historyIndex += direction;
    final updateData = currentSheet!.updateHistories[currentSheet!.historyIndex];
    return updateData;
  }
  
  @override
  void commitHistory(List<UpdateUnit> updates, String sheetId, bool isFromEditing) {
    final sheet = loadedSheetsDataStore.getSheet(sheetId);
    if (isFromEditing) {
      if (isLastChangeInSameEditingMode) {
        (sheet.updateHistories[sheet.historyIndex] as CellUpdate).newValue = (updates.first as CellUpdate).newValue;
      }
      isLastChangeInSameEditingMode = true;
    } else {
      final updateData = UpdateData(chronoIdCounter++, sheetId, updates);
      if (sheet.historyIndex < sheet.updateHistories.length - 1) {
        sheet.updateHistories = sheet.updateHistories.sublist(
          0,
          sheet.historyIndex + 1,
        );
      }
      sheet.updateHistories.add(updateData);
      sheet.historyIndex++;
      if (sheet.historyIndex == 100) {
        sheet.updateHistories.removeAt(0);
        sheet.historyIndex--;
      }
    }
  }

  @override
  void stopEditing(String prevValue) {
    isLastChangeInSameEditingMode = false;
    final primarySelectedCell = selectionCache.getSelectionData(currentSheetId!).primarySelectedCell;
    String newVal = loadedSheetsDataStore.getCellContent(
      currentSheetId!,
      primarySelectedCell.x,
      primarySelectedCell.y,
    );
    if (newVal == prevValue) return;
    commitHistory(
        [
          CellUpdate(
            primarySelectedCell.x,
            primarySelectedCell.y,
            newVal,
          ),
        ], currentSheetId!, false
      );
  }
}