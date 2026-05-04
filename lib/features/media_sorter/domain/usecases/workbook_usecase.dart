import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/layout_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';

class WorkbookUsecase {
  final WorkbookRepository workbookRepository;
  final LoadedSheetsCache loadedSheetsCache;
  final SelectionRepository selectionRepository;
  final SortRepository sortRepository;
  final SheetDataRepository sheetDataRepository;
  final GridRepository gridRepository;
  final HistoryRepository historyRepository;

  WorkbookUsecase(
    this.workbookRepository,
    this.loadedSheetsCache,
    this.selectionRepository,
    this.sortRepository,
    this.sheetDataRepository,
    this.gridRepository,
    this.historyRepository,
  );

  int get currentSheetId => workbookRepository.currentSheetId;
  String get currentSheetName => workbookRepository.currentSheetName;

  List<int> getRecentSheetIds() {
    return workbookRepository.getRecentSheetIds();
  }

  Future<void> clearAllData() async {
    Either<Failure, void> result;
    result = await workbookRepository.clearAllData();
    if (result.isLeft()) {
      throw Exception('Failed to clear all data.');
    }
  }

  Future<void> loadRecentSheetIds() async {
    Either<Failure, void> result;
    result = await workbookRepository.loadRecentSheetIds();
    if (result.isLeft()) {
      throw Exception('Failed to load recent sheet IDs.');
    } else if (workbookRepository.getRecentSheetIds().isEmpty) {
      createDefaultSheet();
    }
  }

  void createDefaultSheet() {
    createSheetByName(SpreadsheetConstants.defaultSheetTitle);
  }

  void createSheetByName(String title) {
    workbookRepository.addNewSheetId(title);
    sheetDataRepository.addNewSheet(currentSheetId, title);
    sortRepository.addSheetId(currentSheetId);
    selectionRepository.setPrimarySelection(0, 0, false);
    gridRepository.setLayout(currentSheetId, LayoutData.empty());
    historyRepository.addSheetId(currentSheetId);
    historyRepository.scheduleCommit();
  }

  Future<Either<Failure, Unit>> loadSheet(int sheetId) async {
    if (!sheetDataRepository.containsSheetId(sheetId)) {
      final result = await sheetDataRepository.loadSheet(sheetId);
      if (result.isLeft()) {
        createDefaultSheet();
        return result;
      }
    }
    return Right(unit);
  }

  void openSheet(int sheetId) {
    workbookRepository.openSheet(sheetId);
    loadedSheetsCache.openSheet(sheetId);
  }
}
