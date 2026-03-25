import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/utils_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/helpers/utils_services.dart';

class WorkbookUsecase {
  final WorkbookRepository workbookRepository;
  final SelectionRepository selectionRepository;
  final SortRepository sortRepository;
  final SheetDataRepository sheetDataRepository;

  WorkbookUsecase(
    this.workbookRepository,
    this.selectionRepository,
    this.sortRepository,
    this.sheetDataRepository,
  );

  int get currentSheetId => workbookRepository.currentSheetId;
  String get currentSheetName => workbookRepository.currentSheetName;

  List<int> getRecentSheetIds() {
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

  Future<void> loadSheet(int sheetId, bool init) async {
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
          selectionRepository.clearSheetSelection(sheetId);
        }
      }
    } else {
      workbookRepository.addNewSheetId(sheetId, 0);
      sheetDataRepository.addNewSheet(sheetId);
      sortRepository.addNewAnalysisResult(sheetId);
      selectionRepository.clearSheetSelection(sheetId);
    }
    if (!init) {
      selectionRepository.saveLastSelection();
    }
  }
}
