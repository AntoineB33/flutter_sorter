import 'dart:collection';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sort/sort_save_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data/sheet_save_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/parse_paste_data_usecase.dart';
import 'dart:async';

import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sort_status_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort_usecase.dart';
import 'package:trying_flutter/utils/logger.dart';
import 'package:uuid/uuid.dart';

class SortController extends ChangeNotifier {
  StreamSubscription? _progressSubscription;
  StreamSubscription? _sortStatusSubscription;

  final SaveSheetDataUseCase _saveSheetDataUseCase;
  final GetSheetDataUseCase _getSheetDataUseCase;
  final SheetDataUsecase sheetDataUsecase;
  final SortUsecase sortUseCase;

  final CalculationService calculationService = CalculationService();
  late StreamSubscription _subscription;

  String get currentSheetId => sheetDataUsecase.currentSheetId;
  int get rowCount => sheetDataUsecase.rowCount();

  SortController(
    this._getSheetDataUseCase,
    this._saveSheetDataUseCase,
    this.sheetDataUsecase,
    this.sortUseCase,
  ) {
    sortSaveRepository.addListener(_onRepositoryUpdated);
    _subscription = sortingService.dataStream.listen((payload) {
      _onDataChanged(payload.bestSort, payload.sheetId);
    });
    _progressSubscription = sortUseCase.progressStream.listen(onDataProgressUpdate);
    _sortStatusSubscription = sortUseCase.sortStatusStream.listen(onSortStatusUpdate);
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _sortStatusSubscription?.cancel();
    super.dispose();
  }

  void onDataProgressUpdate(_) {
    sortUseCase.onDataProgressUpdate();
  }

  void onSortStatusUpdate(_) {
    sortUseCase.saveSortStatus();
  }

  void calculateOnChange() {
    sortUseCase.calculateOnChange();
  }

  void _onDataChanged(List<int> newData, String sheetId) {
    if (loadedSheetsDataStore.isLoaded(sheetId)) {
  }

  void _onRepositoryUpdated() {
    if (sortSaveRepository.syncFailure != null) {
      logger.e('Background save failed: ${sortSaveRepository.syncFailure}');
    }
  }

  Future<void> loadAllSortStatus() async {
    final result = await _saveSheetDataUseCase.sheetSaveRepository.getAllSortStatus();
    result.fold(
      (failure) => logger.e("Failed to load sort status: $failure"),
      (sortStatusMap) => sortStatusDataStore.loadAllSortStatus(sortStatusMap),
    );
  }

  Future<void> saveSortProgression(
    String sheetName,
    SortProgressData data,
  ) async {
    await _saveSheetDataUseCase.saveSortProgression(sheetName, data);
  }

  bool sortToggleAvailable() {
    if (sortStatusDataStore.containsSheet(
      loadedSheetsDataStore.currentSheetId,
    )) {
      return (!sortStatusDataStore.currentSortStatus.resultCalculated &&
              analysisDataStore
                  .currentSheetAnalysisResult
                  .okToCalculateResult) ||
          analysisDataStore.currentSheetAnalysisResult.okToFindValidSort &&
              sortStatusDataStore.currentSortStatus.validSortFound;
    } else {
      return analysisDataStore.currentSheetAnalysisResult.currentBestSort !=
          null;
    }
  }

  void sortToggle() {
    if (!sortStatusDataStore.currentSortStatus.resultCalculated) {
      sortStatusDataStore.updateSortStatus(
        loadedSheetsDataStore.currentSheetId,
        (status) {
          status.toSort = true;
        },
      );
    } else {
      sortMedia(loadedSheetsDataStore.currentSheetId);
    }
  }

  void findBestSortCurrentSheet(bool sortTable) {
    findBestSortToggle(loadedSheetsDataStore.currentSheetId, sortTable);
  }

  Future<void> findBestSortToggle(String sheetId, bool sortTable) async {
    SortStatus sortStatus = sortStatusDataStore.getSortStatus(sheetId);
    if (sortStatus.isFindingBestSort) {
      if (sortStatus.sortWhileFindingBestSort != sortTable) {
        sortStatusDataStore.updateSortStatus(sheetId, (status) {
          status.sortWhileFindingBestSort = sortTable;
        });
      } else {
        sortingService.cancelFindingBestSort(sheetId);
        sortStatusDataStore.updateSortStatus(sheetId, (status) {
          status.isFindingBestSort = false;
        });
      }
    } else {
      sortStatusDataStore.updateSortStatus(sheetId, (status) {
        status.isFindingBestSort = true;
        status.sortWhileFindingBestSort = sortTable;
      });
    }
    if (!sortStatus.resultCalculated) {
      await for (final solution in sortingService.findBestSort(sheetId)) {
        analysisDataStore.updateResults(sheetId, (result) {
          result.bestMediaSortOrder = solution.sortedIds!;
        });
      }
    }
    if (sortStatus.resultCalculated) {
      findBestSortToggleFunc(sheetId);
    }
  }

  void sortMedia(String sheetId) {
    sortUseCase.sortMedia(sheetId);
  }

  Future<void> findBestSortToggleFunc(String sheetId) async {
    await for (final yieldedResult in sortingService.findBestSort()) {
      // 2. This block runs every time the service yields a new result
      print('Received yielded result: $yieldedResult');

      // TODO: Update your state (e.g., notifyListeners(), emit(state), etc.)
      // so the UI reflects the newly yielded result.
    }
    try {
      // await for pauses the execution of this function
      // until the stream is closed by the server.
      await for (final solution in service.solveSortingStream(
        analysisDataStore.tableToAtt.length,
        analysisDataStore.myRules,
        groupsToMaximize: analysisDataStore.groupsToMaximize,
      )) {
        if (!sortStatusDataStore.getSortStatus(sheetId).isFindingBestSort) {
          // If the user has toggled off the "finding best sort" mode, we should stop processing results.
          break;
        }
        analysisDataStore.updateResults(sheetId, (result) {
          result.bestMediaSortOrder = solution.sortedIds!;
        });
        sortMedia(sheetId);
      }
    } catch (error) {
      result.errorRoot.newChildren!.add(
        NodeStruct(
          message: "Could not find a valid sorting satisfying all constraints.",
        ),
      );
    }
  }

  Future<void> loadAnalysisResult(String sheetName) async {
    try {
      await _getSheetDataUseCase.getAnalysisResult(sheetName);
    } catch (e) {
      logger.e("Error getting analysis result for $sheetName: $e");
    }
  }
}
