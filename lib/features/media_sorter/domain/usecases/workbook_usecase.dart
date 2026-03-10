import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/utils_services.dart';
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

  List<String> getRecentSheetIds() {
    return workbookRepository.getRecentSheetIds();
  }

  Future<void> clearAllData() async {
    Either<Failure, void> result;
    result = await workbookRepository.clearAllData();
    UtilsServices.handleDataCorruption(result);
  }

  Future<void> init() async {
    workbookRepository.loadRecentSheetIds().then((result) {
      UtilsServices.handleDataCorruption(result);
      loadSheet(true);
      selectionRepository.loadLastSelection().then((result) {
        bool success = UtilsServices.handleDataCorruption(result);
        selectionRepository.loadLastSelections(success).then((result) {
          UtilsServices.handleDataCorruption(result);
          sortRepository.loadSortStatus().then((result) {
            UtilsServices.handleDataCorruption(result);
          });
        });
      });
    });
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

  Future<void> loadSheet(
    String name, {
    bool init = false,
    SelectionData? lastSelection,
  }) async {
    if (!init) {
      selectionRepository.sheetSwitch();
      workbookRepository.saveRecentSheetIds();
    }

    if (workbookRepository.containsSheetId(name)) {
      if (!sheetDataRepository.containsSheetId(name)) {
        _dataController.createSaveExecutor(name);
        try {
          _dataController.loadedSheetsData[name] = await getDataUseCase
              .loadSheet(name);
        } catch (e) {
          logger.e("Error parsing sheet data for $name: $e");
          _dataController.loadedSheetsData[name] = SheetData.empty();
          selectionController.clearLastSelection(name);
        }
        await sortController.loadAnalysisResult(name);
      }
    } else {
      _dataController.loadedSheetsData[name] = SheetData.empty();
      sortController.analysisResults[name] = AnalysisResult.empty();
      selectionController.clearLastSelection(name);
      sheetNames.add(name);
      saveSheetDataUseCase.saveRecentSheetIds(sheetNames);
      _dataController.createSaveExecutor(name);
    }
    currentSheetName = name;
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

    _streamController.scrollToOffset(
      x: selectionController.scrollOffsetX,
      y: selectionController.scrollOffsetY,
      animate: true,
    );
    notifyListeners();
  }
}
