import 'dart:async';

import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final LoadedSheetsCache loadedSheetsDataStore;
  final SelectionRepository selectionRepository;
  final SheetDataRepository sheetDataRepository;
  final WorkbookRepository workbookRepository;
  int chronoIdCounter = 0;

  HistoryRepositoryImpl(this.loadedSheetsDataStore, this.selectionRepository, this.sheetDataRepository, this.workbookRepository);

  @override
  void moveInUpdateHistory(int direction) {
    final currentSheet = workbookRepository.currentSheet;
    if (currentSheet.historyIndex + direction < 0 ||
        currentSheet.historyIndex + direction >= currentSheet.updateHistories.length) {
      return;
    }
    currentSheet.historyIndex += direction;
    final updateData = currentSheet.updateHistories[currentSheet.historyIndex];
    _updateDataController.add(UpdateRequest(updateData, true));
  }
  
  @override
  void commitHistory(List<UpdateUnit> updates, String sheetId) {
    final updateData = UpdateData(chronoIdCounter++, sheetId, updates);
    final sheet = loadedSheetsDataStore.getSheet(sheetId);
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

  @override
  void stopEditing(String prevValue) {
    commitHistory(
        [
          CellUpdate(
            selectionRepository.primarySelectedCell.x,
            selectionRepository.primarySelectedCell.y,
            sheetDataRepository.getCellContent(
              selectionRepository.primarySelectedCell,
              workbookRepository.currentSheetId,
            ),
            prevValue,
          ),
        ], workbookRepository.currentSheetId
      );
  }

  @override
  void setCellContent(int rowId, int colId, String prevVal, String newVal) {
    commitHistory(UpdateData())
  }
}