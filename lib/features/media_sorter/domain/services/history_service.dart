import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';

class HistoryService {
  final LoadedSheetsCache loadedSheetsDataStore;

  SheetData get currentSheet => loadedSheetsDataStore.currentSheet;

  HistoryService(this.loadedSheetsDataStore);

  /// Commits the `currentUpdateHistory` to the Sheet's permanent history stack.
}
