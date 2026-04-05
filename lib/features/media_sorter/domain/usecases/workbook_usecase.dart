import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/save_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';
import 'package:trying_flutter/utils/logger.dart';

class WorkbookUsecase {
  final WorkbookRepository workbookRepository;
  final SelectionRepository selectionRepository;
  final SortRepository sortRepository;
  final SheetDataRepository sheetDataRepository;
  final GridRepository gridRepository;
  final SaveRepository saveRepository;

  WorkbookUsecase(
    this.workbookRepository,
    this.selectionRepository,
    this.sortRepository,
    this.sheetDataRepository,
    this.gridRepository,
    this.saveRepository,
  );

  int get currentSheetId => workbookRepository.currentSheetId;
  String get currentSheetName => workbookRepository.currentSheetName;

  String getSheetTitle(int sheetId) {
    return sheetDataRepository.getSheetTitle(sheetId);
  }

  List<int> getRecentSheetIds() {
    return workbookRepository.getRecentSheetIds();
  }

  Future<void> clearAllData() async {
    Either<Failure, void> result;
    result = await workbookRepository.clearAllData();
    if (result.isLeft()) {
      logger.e('Failed to clear all data.');
    }
  }

  Future<void> loadRecentSheetIds() async {
    Either<Failure, void> result;
    result = await workbookRepository.loadRecentSheetIds();
    if (result.isLeft()) {
      logger.e('Failed to load recent sheet IDs.');
    } else if (workbookRepository.getRecentSheetIds().isEmpty) {
      createDefaultSheet();
    }
  }

  void createDefaultSheet() {
    createSheetByName(SpreadsheetConstants.defaultSheetTitle);
  }

  void createSheetByName(String name) {
    loadSheet(workbookRepository.getNewSheetId(), false);
  }

  Future<Either<Failure, Unit>> loadSheet(int sheetId, bool init) async {
    if (workbookRepository.containsSheetId(sheetId)) {
      if (!sheetDataRepository.containsSheetId(sheetId)) {
        final result = await sheetDataRepository.loadSheet(
          sheetId,
        );
        if (result.isLeft()) {
          createDefaultSheet();
          return result;
        }
      }
      saveRepository.saveUpdate(
        SheetDataUpdate(sheetId, true, lastOpened: DateTime.now()),
      );
    } else {
      workbookRepository.addNewSheetId(sheetId, 0);
      sheetDataRepository.addNewSheet(sheetId);
      sortRepository.addNewAnalysisResult(sheetId);
      selectionRepository.setSelectionData(sheetId, SelectionData.empty());
      gridRepository.initializeGrid(sheetId);
      saveRepository.saveUpdate(SheetDataUpdate.initial(sheetId));
    }
    return Right(unit);
  }
}
