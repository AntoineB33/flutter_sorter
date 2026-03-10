import 'dart:async';

import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final LoadedSheetsCache loadedSheetsDataStore;
  
  final _updateDataController = StreamController<UpdateRequest>.broadcast();
  @override
  Stream<UpdateRequest> get updateDataStream => _updateDataController.stream;

  HistoryRepositoryImpl(this.loadedSheetsDataStore);

  @override
  void moveInUpdateHistory(int direction) {
    final currentSheet = loadedSheetsDataStore.currentSheet;
    if (currentSheet.historyIndex + direction < 0 ||
        currentSheet.historyIndex + direction >= currentSheet.updateHistories.length) {
      return;
    }
    currentSheet.historyIndex += direction;
    final updateData = currentSheet.updateHistories[currentSheet.historyIndex];
    _updateDataController.add(UpdateRequest(updateData, true));
  }
  
  @override
  void commitHistory(UpdateData updateData) {
    final currentSheet = loadedSheetsDataStore.currentSheet;
    if (currentSheet.historyIndex < currentSheet.updateHistories.length - 1) {
      currentSheet.updateHistories = currentSheet.updateHistories.sublist(
        0,
        currentSheet.historyIndex + 1,
      );
    }
    currentSheet.updateHistories.add(updateData);
    currentSheet.historyIndex++;
    if (currentSheet.historyIndex == 100) {
      currentSheet.updateHistories.removeAt(0);
      currentSheet.historyIndex--;
    }
  }

  @override
  void setCellContent(int rowId, int colId, String prevVal, String newVal) {
    commitHistory(UpdateData())
  }
}