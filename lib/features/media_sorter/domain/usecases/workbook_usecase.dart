import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/helpers/utils_services.dart';
import 'package:trying_flutter/utils/logger.dart';

class WorkbookUseCase {
  final WorkbookRepository workbookRepository;
  final SelectionRepository selectionRepository;
  final SortRepository sortRepository;
  final SheetDataRepository sheetDataRepository;

  WorkbookUseCase(
    this.workbookRepository,
    this.selectionRepository,
    this.sortRepository,
    this.sheetDataRepository,
  );

  String get currentSheetId => workbookRepository.currentSheetId;

  List<String> getRecentSheetIds() {
    return workbookRepository.getRecentSheetIds();
  }

  Future<void> clearAllData() async {
    Either<Failure, void> result;
    result = await workbookRepository.clearAllData();
    UtilsServices.handleDataCorruption(result);
  }

  Future<void> loadRecentSheetIds() async {
    Either<Failure, void> result;
    result = await workbookRepository.loadRecentSheetIds();
    UtilsServices.handleDataCorruption(result);
  }

  Future<void> loadLastSelections(bool success) async {
    Either<Failure, void> result;
    result = await selectionRepository.loadLastSelections(success);
    UtilsServices.handleDataCorruption(result);
  }

  Future<void> loadSheet(String sheetId, bool init) async {
    if (!init) {
      selectionRepository.saveAllLastSelected();
      workbookRepository.saveRecentSheetIds();
    }

    if (workbookRepository.containsSheetId(sheetId)) {
      if (!sheetDataRepository.containsSheetId(sheetId)) {
        Either<Failure, void> result = await sheetDataRepository.loadSheet(
          sheetId,
        );
        final success = UtilsServices.handleDataCorruption(result);
        if (!success) {
          selectionRepository.clearLastSelection(sheetId);
        }
      }
    } else {
      workbookRepository.addNewSheetId(sheetId);
      sheetDataRepository.addNewSheet(sheetId);
      sortRepository.addNewAnalysisResult(sheetId);
      selectionRepository.clearLastSelection(sheetId);
    }
    currentSheetName = sheetId;
    if (!init) {
      selectionRepository.saveLastSelection();
    }

    // Trigger Controller updates
    selectionController.updateRowColCount(
      sheet,
      currentSheetName,
      visibleHeight:
          selectionController.scrollOffsetX +
          _gridController.row1ToScreenBottomHeight,
      visibleWidth:
          selectionController.scrollOffsetY +
          _gridController.colBToScreenRightWidth,
      notify: false,
    );
  }
}
