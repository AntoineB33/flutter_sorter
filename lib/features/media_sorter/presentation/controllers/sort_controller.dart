import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_response.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/parse_paste_data_usecase.dart';
import 'dart:async';

import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/services/isolate_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/analysis_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/sort_status_data_store.dart';
import 'package:trying_flutter/utils/logger.dart';

class SortController extends ChangeNotifier {
  final AnalysisDataStore analysisDataStore;
  final LoadedSheetsDataStore loadedSheetsDataStore;
  final SortStatusDataStore sortStatusDataStore;
  final Map<String, ManageWaitingTasks<void>> _saveResultExecutors = {};
  final ManageWaitingTasks<void> _saveSortStatusExecutor =
      ManageWaitingTasks<void>();
  final Map<String, IsolateService> _isolateServices = {};

  final SaveSheetDataUseCase _saveSheetDataUseCase;
  final GetSheetDataUseCase _getSheetDataUseCase;

  final CalculationService calculationService = CalculationService();

  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) =>
      content.table.isNotEmpty ? content.table[0].length : 0;

  SortController(
    this._getSheetDataUseCase,
    this._saveSheetDataUseCase,
    this.sortStatusDataStore,
    this.loadedSheetsDataStore,
    this.analysisDataStore,
  ) {
    sortStatusDataStore.addListener(saveAllSortStatus);
  }

  Future<void> loadAllSortStatus() async {
    sortStatusDataStore.loadAllSortStatus(
      await _saveSheetDataUseCase.repository.getAllSortStatus(),
    );
  }

  void saveAllSortStatus() {
    _saveSortStatusExecutor.execute(() async {
      await _saveSheetDataUseCase.saveAllSortStatus(
        sortStatusDataStore.sortStatusBySheet,
      );
      await Future.delayed(
        Duration(milliseconds: SpreadsheetConstants.saveAllSortStatusDelayMs),
      );
    });
  }

  bool lightCalculations(AnalysisResult result) {
    return false;
  }

  Future<void> calculate(String name) async {
    SortStatus sortStatus = sortStatusDataStore.getSortStatus(name);
    AnalysisResult result = analysisDataStore.getAnalysisResult(name);
    if (sortStatus.resultCalculated && lightCalculations(result)) {
      return;
    }
    _isolateServices[name] ??= IsolateService();
    _isolateServices[name]!.cancelB();
    AnalysisReturn resultB = await _isolateServices[name]!.runHeavyCalculationB(
      loadedSheetsDataStore.getSheet(name).sheetContent,
      result,
    );
    sortStatusDataStore.updateSortStatus(name, (status) {
      status.resultCalculated = true;
      status.validSortFound = !resultB.noSortToFind && status.validSortFound;
      if (resultB.result.validRowIndexes.isEmpty) {
        status.validSortFound = true;
      }
    });
    if (resultB.changed) {
      analysisDataStore.updateResults(name, resultB.result);
    }
    sortStatus = sortStatusDataStore.getSortStatus(name);
    if (!sortStatus.validSortFound) {
      try {
        SortingResponse? response = await _isolateServices[name]!
            .runHeavyCalculationC(result);
        if (response != null) {
          analysisDataStore.getAnalysisResult(name).sorted =
              response.isNaturalOrderValid;
          result.currentBestSort = response.sortedIds;
        }
        if (sortStatus.toSort) {
          sortMedia(name);
          sortStatusDataStore.updateSortStatus(name, (status) {
            status.validSortFound = true;
            status.toSort = false;
          });
        } else if (sortStatus.isFindingBestSort) {
          sortStatusDataStore.updateSortStatus(name, (status) {
            status.validSortFound = true;
          });
          findBestSortToggleFunc(name);
        } else {
          sortStatusDataStore.removeSortStatus(name);
        }
      } catch (e) {
        result.errorRoot.newChildren!.add(
          NodeStruct(
            message:
                "An error occurred while trying to find a valid sorting satisfying all constraints : $e",
          ),
        );
      }
    }
  }

  Future<void> saveAnalysisResult(
    String sheetName,
    AnalysisResult result,
  ) async {
    _saveResultExecutors[sheetName] ??= ManageWaitingTasks<void>();
    _saveResultExecutors[sheetName]!.execute(() async {
      await _saveSheetDataUseCase.saveAnalysisResult(sheetName, result);
      await Future.delayed(
        Duration(milliseconds: SpreadsheetConstants.saveAnalysisResultDelayMs),
      );
    });
  }

  static Future<SortingResponse?> solveSatisfaction(
    AnalysisResult result,
  ) async {
    try {
      // await for pauses the execution of this function
      // until the stream is closed by the server.
      return SortUsecase.solveSorting(
        result.myRules,
        result.validAreas,
        result.validRowIndexes.length,
      );
    } catch (error) {
      result.errorRoot.newChildren!.add(
        NodeStruct(
          message:
              "An error occurred while trying to find a valid sorting satisfying all constraints : $error",
        ),
      );
    }
    return null;
  }

  void sortResult(
    Map<String, AnalysisResult> analysisResults,
    String currentSheetName,
    List<int> sortOrder,
  ) {
    AnalysisResult result = analysisResults[currentSheetName]!;
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
        (j) => HashSet<Attribute>.from(
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
          HashSet<Attribute>.from(
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
    AnalysisResult result = analysisResults[currentSheetName]!;
    List<int> stack = result.currentBestSort!
        .asMap()
        .entries
        .map((e) => result.validRowIndexes[e.key])
        .toList()
        .reversed
        .toList();
    final table = sheet.sheetContent.table;
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
    for (int rowId = 1; rowId < rowCount(sheet.sheetContent); rowId++) {
      for (int colId = 0; colId < colCount(sheet.sheetContent); colId++) {
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
          CellUpdate(row: rowId, col: colId, value: sortedTable[rowId][colId]),
        );
      }
    }
    sortResult(analysisResults, currentSheetName, sortOrder);
    setTable(
      sheet,
      analysisResults,
      lastSelectionBySheet,
      getSortStatus(currentSheetName),
      row1ToScreenBottomHeight,
      colBToScreenRightWidth,
      currentSheetName,
      updates,
      toCalculate: false,
    );
  }

  bool sortToggleAvailable() {
    if (sortStatusDataStore.containsSheet(
      loadedSheetsDataStore.currentSheetName,
    )) {
      return (!sortStatusDataStore.currentSortStatus.resultCalculated &&
              sortStatusDataStore.currentSortStatus.okToCalculateResult) ||
          sortStatusDataStore.currentSortStatus.okToFindValidSort &&
              sortStatusDataStore.currentSortStatus.validSortFound;
    } else {
      return analysisDataStore.currentSheetAnalysisResult.currentBestSort !=
          null;
    }
  }

  void sortToggle() {
    if (!sortStatusDataStore.currentSortStatus.resultCalculated) {
      sortStatusDataStore.updateSortStatus(
        loadedSheetsDataStore.currentSheetName,
        (status) {
          status.toSort = true;
        },
      );
    } else {
      sortMedia(loadedSheetsDataStore.currentSheetName);
    }
  }

  void findBestSortCurrentSheet() {
    findBestSortToggle(loadedSheetsDataStore.currentSheetName, true);
  }

  Future<void> findBestSortToggle(String sheetName, bool sortTable) async {
    SortStatus sortStatus = sortStatusDataStore.getSortStatus(sheetName);
    if (sortStatus.isFindingBestSort) {
      if (sortStatus.sortWhileFindingBestSort != sortTable) {
        sortStatusDataStore.updateSortStatus(sheetName, (status) {
          status.sortWhileFindingBestSort = sortTable;
        });
      } else {
        sortStatusDataStore.updateSortStatus(sheetName, (status) {
          status.isFindingBestSort = false;
        });
      }
    } else {
      sortStatusDataStore.updateSortStatus(sheetName, (status) {
        status.isFindingBestSort = true;
        status.sortWhileFindingBestSort = sortTable;
      });
    }
    if (!sortStatus.resultCalculated) {
      await calculate(sheetName);
    }
    if (sortStatus.resultCalculated) {
      findBestSortToggleFunc(sheetName);
    }
  }

  Future<void> findBestSortToggleFunc(String sheetName) async {
    final service = SortingService();

    try {
      // await for pauses the execution of this function
      // until the stream is closed by the server.
      await for (final solution in service.solveSortingStream(
        analysisDataStore.tableToAtt.length,
        analysisDataStore.myRules,
        groupsToMaximize: analysisDataStore.groupsToMaximize,
      )) {
        if (!sortStatusDataStore.getSortStatus(sheetName).isFindingBestSort) {
          // If the user has toggled off the "finding best sort" mode, we should stop processing results.
          break;
        }
        analysisDataStore.updateResults(sheetName, (result) {
          result.bestMediaSortOrder = solution.sortedIds!;
        });
        sortMedia(sheetName);
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
