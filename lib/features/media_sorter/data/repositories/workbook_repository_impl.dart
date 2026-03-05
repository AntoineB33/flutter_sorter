import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/services/workbook_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';
import 'package:trying_flutter/utils/logger.dart';

class WorkbookRepositoryImpl implements WorkbookRepository {
  final FileSheetLocalDataSource fileSheetLocalDataSource;

  final LoadedSheetsCache loadedSheetsDataStore;
  final SelectionCache selectionDataStore;

  WorkbookRepositoryImpl(
    this.fileSheetLocalDataSource,
    this.loadedSheetsDataStore,
    this.selectionDataStore,
  );

  @override
  Future<void> init() async {
    await fileSheetLocalDataSource.clearAllData();

    bool saveRecentSheetIds = false;
    loadedSheetsDataStore.recentSheetIds = await fileSheetLocalDataSource
        .recentSheetIds();
    for (int i = 0; i < loadedSheetsDataStore.recentSheetIds.length; i++) {
      String sheetId = loadedSheetsDataStore.recentSheetIds[i];
      if (!WorkbookService.isValidSheetName(sheetId)) {
        logger.e(
          "Invalid sheet name '$sheetId' found in sheet names list, removing it.",
        );
        loadedSheetsDataStore.removeSheet(i);
        saveRecentSheetIds = true;
      }
    }

    // --- get sort status by sheet ---
    await sortController.loadAllSortStatus();
    bool saveCalculationStatusBySheet = false;
    for (var name in sortController.sortStatusBySheet.keys.toList()) {
      if (!WorkbookService.isValidSheetName(name)) {
        logger.e(
          "Sort status found for sheet '$name' which is not in sheet names list, removing it.",
        );
        sortController.sortStatusBySheet.remove(name);
        saveCalculationStatusBySheet = true;
      } else if (!loadedSheetsDataStore.sheetNames.contains(name)) {
        loadedSheetsDataStore.sheetNames.add(name);
        saveRecentSheetIds = true;
        selectionDataStore.lastSelectionBySheet[name] = SelectionData.empty();
        saveLastSelectionBySheet = true;
        debugPrint("No sheet data saved for sort status of sheet $name");
      }
    }

    // --- get last selection for current sheet ---
    selectionController.loadLastSelection();

    // --- save any correction if needed ---
    if (saveRecentSheetIds) {
      await saveSheetDataUseCase.saveRecentSheetIds(
        loadedSheetsDataStore.currentSheetId,
      );
    }
    if (saveRecentSheetIds) {
      await saveSheetDataUseCase.saveRecentSheetIds(
        loadedSheetsDataStore.sheetNames,
      );
    }
    if (saveLastSelectionBySheet) {
      await selectionController.saveAllLastSelected();
    }
    if (saveCalculationStatusBySheet) {
      sortController.saveAllSortStatus(loadedSheetsDataStore.currentSheetId);
    }
    await loadSheetByName(loadedSheetsDataStore.currentSheetId, init: true);
    for (var name in sortStatusDataStore.sortStatusBySheet.keys.toList()) {
      if (!sortStatusDataStore.getSortStatus(name).resultCalculated ||
          !sortStatusDataStore.getSortStatus(name).validSortFound) {
        if (!analysisDataStore.analysisResults.containsKey(name)) {
          await sortController.loadAnalysisResult(name);
        }
        sortController.calculate(name);
      } else if (!sortStatusDataStore.getSortStatus(name).isFindingBestSort) {
        await sortController.loadAnalysisResult(name);
        sortController.findBestSortToggle();
      } else if (!sortStatusDataStore
          .getSortStatus(name)
          .sortWhileFindingBestSort) {
        await sortController.loadAnalysisResult(name);
        sortController.findBestSortAndSortToggle(
          _dataController.sheet(name),
          selectionController.lastSelectionBySheet,
          name,
          _gridController.row1ToScreenBottomHeight,
          _gridController.colBToScreenRightWidth,
        );
      }
    }
  }
}
