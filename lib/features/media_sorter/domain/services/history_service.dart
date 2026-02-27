import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';

class HistoryService {
  final LoadedSheetsDataStore loadedSheetsDataStore;

  SheetData get currentSheet => loadedSheetsDataStore.currentSheet;

  HistoryService(this.loadedSheetsDataStore);

  /// Commits the `currentUpdateHistory` to the Sheet's permanent history stack.
  void commitHistory(UpdateData updateData) {
    if (currentSheet.historyIndex < currentSheet.updateHistories.length - 1) {
      currentSheet.updateHistories = currentSheet.updateHistories.sublist(
        0,
        currentSheet.historyIndex + 1,
      );
    }
    currentSheet.updateHistories.add(updateData);
    currentSheet.historyIndex++;
    if (currentSheet.historyIndex == SpreadsheetConstants.historyMaxLength) {
      currentSheet.updateHistories.removeAt(0);
      currentSheet.historyIndex--;
    }
  }
}
