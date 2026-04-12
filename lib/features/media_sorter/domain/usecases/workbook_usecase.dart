import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/data/models/layout_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';
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
  final HistoryRepository historyRepository;
  final SaveRepository saveRepository;

  WorkbookUsecase(
    this.workbookRepository,
    this.selectionRepository,
    this.sortRepository,
    this.sheetDataRepository,
    this.gridRepository,
    this.historyRepository,

    this.saveRepository,
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

  void createSheetByName(String title) {
    ChangeSet changeSet = ChangeSet();
    final sheetDataUpdate = workbookRepository.addNewSheetId(0);
    final sheetId = sheetDataUpdate.sheetId;
    changeSet.addUpdate(sheetDataUpdate);
    changeSet.addUpdate(sheetDataRepository.addNewSheet(sheetId, title));
    changeSet.merge(sortRepository.addSheetId(sheetId));
    changeSet.addUpdate(
      selectionRepository.setSelectionData(sheetId, SelectionData.empty()),
    );
    changeSet.addUpdate(gridRepository.setLayout(sheetId, LayoutData.empty()));
    changeSet.merge(historyRepository.addSheetId(sheetId));
    changeSet.addUpdate(SheetDataUpdate(sheetId, true, lastOpened: DateTime.now()));
    saveRepository.save(changeSet);
  }

  Future<Either<Failure, Unit>> loadSheet(int sheetId) async {
    if (!sheetDataRepository.containsSheetId(sheetId)) {
      final result = await sheetDataRepository.loadSheet(sheetId);
      if (result.isLeft()) {
        createDefaultSheet();
        return result;
      }
    }
    saveRepository.saveUpdate(
      SheetDataUpdate(sheetId, true, lastOpened: DateTime.now()),
    );
    return Right(unit);
  }
}
