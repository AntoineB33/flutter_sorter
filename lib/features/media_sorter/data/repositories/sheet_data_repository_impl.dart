import 'dart:math';

import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';

class SheetDataRepositoryImpl implements SheetDataRepository {
  final LoadedSheetsCache loadedSheetsCache;
  final SelectionCache selectionCache;
  final LoadedSheetsCache loadedSheetsData;

  SheetDataRepositoryImpl(this.loadedSheetsCache, this.selectionCache, this.loadedSheetsData);

  @override
  String get currentSheetId => loadedSheetsCache.currentSheetId;

  @override
  int rowCount(String sheetId) {
    return loadedSheetsCache.rowCount(sheetId);
  }

  @override
  int colCount(String sheetId) {
    return loadedSheetsCache.colCount(sheetId);
  }

  @override
  void delete() {
    List<UpdateUnit> updates = [];
    for (Point<int> cell in selectionCache.selection.selectedCells) {
      updates.add(
        CellUpdate(
          cell.x,
          cell.y,
          '',
          loadedSheetsData.getCellContent(cell.x, cell.y),
        ),
      );
    }
    UpdateData updateData = UpdateData(Uuid().v4(), DateTime.now(), updates);
    update(updateData, true);
    notifyListeners();
    scheduleSheetSave(currentSheetName);
    sortService.calculate(currentSheetName);
  }
}