import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/services/workbook_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sort_status_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/data_load_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';
import 'package:trying_flutter/utils/logger.dart';

class WorkbookRepositoryImpl implements WorkbookRepository {
  final FileSheetLocalDataSource fileSheetLocalDataSource;

  final LoadedSheetsCache loadedSheetsCache;
  final SelectionCache selectionCache;
  final SortStatusCache sortStatusCache;

  WorkbookRepositoryImpl(
    this.fileSheetLocalDataSource,
    this.loadedSheetsCache,
    this.selectionCache,
    this.sortStatusCache
  );

  @override
  Future<Either<Failure, DataLoadResult>> init() async {
    await fileSheetLocalDataSource.clearAllData();
    try {
      loadedSheetsCache.recentSheetIds = await fileSheetLocalDataSource
          .recentSheetIds();
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e.e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
    bool corruptedButRecovered = false;
    for (int i = 0; i < loadedSheetsCache.recentSheetIds.length; i++) {
      String sheetId = loadedSheetsCache.recentSheetIds[i];
      if (!WorkbookService.isValidSheetName(sheetId)) {
        loadedSheetsCache.removeSheet(i);
        corruptedButRecovered = true;
      }
    }
    if (corruptedButRecovered) {
      return Right(DataLoadResult.corruptedButRecovered);
    } else {
      return Right(DataLoadResult.success);
    }


    // --- get last selection for current sheet ---
    selectionController.loadLastSelection();

    // --- save any correction if needed ---
    if (saveRecentSheetIds) {
      await saveSheetDataUseCase.saveRecentSheetIds(
        loadedSheetsCache.currentSheetId,
      );
    }
    if (saveRecentSheetIds) {
      await saveSheetDataUseCase.saveRecentSheetIds(
        loadedSheetsCache.sheetNames,
      );
    }
    if (saveLastSelectionBySheet) {
      await selectionController.saveAllLastSelected();
    }
    if (saveCalculationStatusBySheet) {
      sortController.saveAllSortStatus(loadedSheetsCache.currentSheetId);
    }
    await loadSheetByName(loadedSheetsCache.currentSheetId, init: true);
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

  @override
  Future<void> checkSortStatusSheetIds() async {
    for (var sheetId in sortStatusCache.getSheetIds()) {
      if (!WorkbookService.isValidSheetName(sheetId)) {
        logger.e(
          "Sort status found for sheet '$sheetId' which is not in sheet names list, removing it.",
        );
        sortStatusCache.removeSortStatus(sheetId);
        saveCalculationStatusBySheet = true;
      } else if (!loadedSheetsCache.containsSheetId(sheetId)) {
        loadedSheetsCache.addSheetId(sheetId, true);
        saveRecentSheetIds = true;
        selectionCache.setNewSelectionData(sheetId);
        saveLastSelectionBySheet = true;
        debugPrint("No sheet data saved for sort status of sheet $sheetId");
      }
    }
  }
}
