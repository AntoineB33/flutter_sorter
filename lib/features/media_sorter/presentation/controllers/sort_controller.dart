import 'dart:collection';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/sort_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_response.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/parse_paste_data_usecase.dart';
import 'dart:async';

import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort/sort_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/data/services/isolate_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/analysis_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/sort_status_data_store.dart';
import 'package:trying_flutter/utils/logger.dart';
import 'package:uuid/uuid.dart';

class SortController extends ChangeNotifier {
  final ManageWaitingTasks<void> _saveSortStatusExecutor =
      ManageWaitingTasks<void>(Duration(milliseconds: SpreadsheetConstants.saveAllSortStatusDelayMs));
  
  final SheetDataController sheetDataController;

  final SaveSheetDataUseCase _saveSheetDataUseCase;
  final GetSheetDataUseCase _getSheetDataUseCase;

  final SortService sortingService;

  final SortStatusDataStore sortStatusDataStore;
  final AnalysisDataStore analysisDataStore;
  final LoadedSheetsDataStore loadedSheetsDataStore;

  final CalculationService calculationService = CalculationService();

  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) =>
      content.table.isNotEmpty ? content.table[0].length : 0;

  SortController(
    this.sheetDataController,
    this._getSheetDataUseCase,
    this._saveSheetDataUseCase,
    this.sortingService,
    this.sortStatusDataStore,
    this.loadedSheetsDataStore,
    this.analysisDataStore,
  ) {
    sortStatusDataStore.addListener(saveAllSortStatus);
  }

  Future<void> loadAllSortStatus() async {
    final result = await _saveSheetDataUseCase.repository.getAllSortStatus();
    result.fold(
      (failure) => logger.e("Failed to load sort status: $failure"),
      (sortStatusMap) => sortStatusDataStore.loadAllSortStatus(sortStatusMap),
    );
  }

  void saveAllSortStatus() {
    _saveSortStatusExecutor.execute(() async {
      await _saveSheetDataUseCase.saveAllSortStatus(
        sortStatusDataStore.sortStatusBySheet,
      );
    });
  }

  @override
  void dispose() {
    _saveSortStatusExecutor.dispose();
    super.dispose();
  }

  Future<void> saveSortProgression(
    String sheetName,
    SortProgressData data,
  ) async {
    await _saveSheetDataUseCase.saveSortProgression(sheetName, data);
  }

  void sortResult(
    List<int> sortOrder,
  ) {
    AnalysisResult result = analysisDataStore.currentSheetAnalysisResult;
    int rowCount = result.tableToAtt.length;
    if (rowCount == 0) {
      return;
    }
    int colCount = result.tableToAtt[0].length;
    List<int> newInd = List.filled(rowCount, 0);
    for (int i = 0; i < rowCount; i++) {
      newInd[sortOrder[i]] = i;
    }
    result.tableToAtt = List.generate(
      rowCount,
      (i) => List.generate(
        colCount,
        (j) => Set<Attribute>.from(
          result.tableToAtt[sortOrder[i]][j].map(
            (e) => e.rowId != null ? Attribute.row(newInd[e.rowId!]) : e,
          ),
        ),
      ),
    );
    result.names.forEach((key, value) {
      value.rowId = newInd[value.rowId];
    });
    result.formatedTable = List.generate(
      rowCount,
      (i) => List.generate(
        colCount,
        (j) => StrInt(
          strings: result.formatedTable[sortOrder[i]][j].strings,
          integers: result.formatedTable[sortOrder[i]][j].integers
              .map((e) => newInd[e])
              .toList(),
        ),
      ),
    );
    result.attToRefFromAttColToCol.forEach((key, value) {
      if (key.rowId != null) {
        key.rowId = newInd[key.rowId!];
      }
      value = Map.fromEntries(
        value.entries.map((e) => MapEntry(newInd[e.key], e.value)),
      );
    });
    result.attToRefFromDepColToCol.forEach((key, value) {
      if (key.rowId != null) {
        key.rowId = newInd[key.rowId!];
      }
      value = Map.fromEntries(
        value.entries.map((e) => MapEntry(newInd[e.key], e.value)),
      );
    });
    for (int id = 0; id < result.validRowIndexes.length; id++) {
      result.validRowIndexes[id] = newInd[result.validRowIndexes[id]];
    }
    result.colToAtt = Map.fromEntries(
      result.colToAtt.entries.map(
        (e) => MapEntry(
          e.key,
          Set<Attribute>.from(
            e.value.map(
              (att) =>
                  att.rowId != null ? Attribute.row(newInd[att.rowId!]) : att,
            ),
          ),
        ),
      ),
    );
    result.myRules = Map.fromEntries(
      result.myRules.entries.map(
        (e) => MapEntry(
          newInd[e.key],
          Map.fromEntries(
            e.value.entries.map(
              (innerE) => MapEntry(newInd[innerE.key], innerE.value),
            ),
          ),
        ),
      ),
    );
    result.groupsToMaximize = result.groupsToMaximize
        .map((group) => group.map((id) => newInd[id]).toList())
        .toList();
    result.validAreas = List.generate(
      rowCount,
      (i) => result.validAreas[sortOrder[i]],
    );
  }

  void sortMedia(String name) {
    List<int> sortOrder = [0];
    AnalysisResult result = analysisDataStore.currentSheetAnalysisResult;
    List<int> stack = result.currentBestSort!
        .asMap()
        .entries
        .map((e) => result.validRowIndexes[e.key])
        .toList()
        .reversed
        .toList();
    final table = loadedSheetsDataStore.currentSheet.sheetContent.table;
    List<int> added = List.filled(table.length, 0);
    for (int i in stack) {
      added[i] = 1;
    }
    List<String> toNewPlacement = List.filled(table.length, '');
    for (int rowId in result.validRowIndexes) {
      stack.add(rowId);
      while (stack.isNotEmpty) {
        int current = stack[stack.length - 1];
        if (added[current] == 2) {
          stack.removeLast();
          continue;
        }
        for (Attribute ref
            in result.tableToAtt[current].expand((i) => i).toList()) {
          if (ref.isRow() && added[ref.rowId!] != 2) {
            stack.add(ref.rowId!);
            added[ref.rowId!] = 1;
          }
        }
        if (stack[stack.length - 1] == current) {
          toNewPlacement[current] = sortOrder.length.toString();
          sortOrder.add(current);
          stack.removeLast();
          added[current] = 2;
        }
      }
    }
    for (int rowId = 1; rowId < table.length; rowId++) {
      if (added[rowId] == 0) {
        sortOrder.add(rowId);
      }
    }
    List<List<String>> sortedTable = sortOrder.map((i) => table[i]).toList();
    for (int rowId = 1; rowId < rowCount(loadedSheetsDataStore.currentSheet.sheetContent); rowId++) {
      for (int colId = 0; colId < colCount(loadedSheetsDataStore.currentSheet.sheetContent); colId++) {
        if (result.formatedTable[rowId][colId].integers.isEmpty) {
          continue;
        }
        for (
          int splitId = 0;
          splitId < result.formatedTable[rowId][colId].strings.length;
          splitId++
        ) {
          sortedTable[rowId][colId] =
              result.formatedTable[rowId][colId].strings[splitId];
          if (result.formatedTable[rowId][colId].integers.length <= splitId) {
            break;
          }
          sortedTable[rowId][colId] +=
              toNewPlacement[result
                  .formatedTable[rowId][colId]
                  .integers[splitId]];
        }
      }
    }
    final List<CellUpdate> updates = [];
    for (int rowId = 1; rowId < sortedTable.length; rowId++) {
      for (int colId = 0; colId < sortedTable[rowId].length; colId++) {
        updates.add(
          CellUpdate(rowId, colId, sortedTable[rowId][colId], loadedSheetsDataStore.getCellContent(rowId, colId)),
        );
      }
    }
    sortResult(sortOrder);
    sheetDataController.update(UpdateData(Uuid().v4(), DateTime.now(), updates), false);
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
