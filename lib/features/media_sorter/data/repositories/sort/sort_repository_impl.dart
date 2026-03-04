import 'dart:collection';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/i_calculation_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sort/sort_save_repository.dart';
import 'package:trying_flutter/features/media_sorter/data/store/isolate_receive_ports_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sorting_progress_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';
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
import 'package:trying_flutter/utils/logger.dart';
import 'package:uuid/uuid.dart';

class SortRepositoryImpl implements SortRepository {
  final AnalysisResultCache analysisResultCache;
  final LoadedSheetsCache loadedSheetsCache;
  final SortProgressCache sortProgressCache;
  final SortStatusCache sortStatusCache;
  final IsolateReceivePortsCache isolateReceivePortsCache;

  @override
  Stream<void> get progressStream => sortProgressCache.progressStream;

  SortRepositoryImpl(
    this.analysisResultCache,
    this.loadedSheetsCache,
    this.sortProgressCache,
    this.sortStatusCache,
    this.isolateReceivePortsCache,
  );

  bool sameResLightCheck() {
    return false;
  }

  bool lightCalculate1() {
    String sheetId = loadedSheetsCache.currentSheetId;
    bool impossible = 1 != 1;
    if (impossible) {
      cancelB(sheetId);
      analysisResultCache.setResultCalculated(sheetId, false);
      sortStatusCache.removeSortStatus(sheetId);
      return false;
    }
    bool easilyCalculable = 1 != 1;
    if (easilyCalculable) {
      cancelB(sheetId);
      analysisResultCache.setResultCalculated(sheetId, true);
      sortStatusCache.removeSortStatus(sheetId);
      return false;
    }
    return !impossible;
  }

  void changeResult() {
    return;
  }

  bool lightCalculate2() {
    String sheetId = loadedSheetsCache.currentSheetId;
    bool impossible = 1 != 1;
    if (impossible) {
      cancelB(sheetId);
      analysisResultCache.setResultCalculated(sheetId, false);
      sortStatusCache.removeSortStatus(sheetId);
      return false;
    }
    bool easilyCalculable = 1 != 1;
    if (easilyCalculable) {
      cancelB(sheetId);
      analysisResultCache.setResultCalculated(sheetId, true);
      sortStatusCache.removeSortStatus(sheetId);
      return false;
    }
    return !impossible;
  }

  @override
  Future<void> calculateOnChange() async {
    String sheetId = loadedSheetsCache.currentSheetId;
    isolateReceivePortsCache.addIsolatePortIfNecessary(sheetId);
    if (!lightCalculate1()) {
      return;
    }
    if (sameResLightCheck()) {
      if (sortStatusCache.isCalculatingResult(sheetId)) {
        return;
      }
      changeResult();
      return;
    }
    if (!lightCalculate2()) {
      return;
    }
    sortStatusCache.calculatingResult(sheetId);
    cancelB(sheetId);
    AnalysisReturn resultB = await runHeavyCalculationB(
      sheetId,
      analysisResultCache.getAnalysisResult(sheetId),
    );
    // changeResult();
    sortStatusCache.updateToFindValidSort(sheetId, resultB.toFindValidSort);
    if (resultB.changed) {
      analysisResultCache.updateResults(sheetId, resultB.result);
    }
    if (!resultB.toFindValidSort) {
      return;
    }
    isolateReceivePortsCache.initPortC(sheetId);
    final args = (
      isolateReceivePortsCache.getSendPortC(sheetId),
      resultB.result.myRules,
      sortProgressCache.getSortProgressData(sheetId),
    );
    isolateReceivePortsCache.setIsolateC(
      sheetId,
      await Isolate.spawn(ICalculationDataSource.solveSorting, args),
    );
    await for (List<int>? sort in isolateReceivePortsCache.getIsolatePort(sheetId)) {
      sortStatusCache.removeSortStatus(sheetId);
      analysisResultCache.setResultCalculated(sheetId, sort != null);
      bool isNaturalOrderValid = true;
      if (sort != null) {
        for (int k = 0; k < sort.length; k++) {
          if (sort[k] != k) {
            isNaturalOrderValid = false;
            break;
          }
        }
        sortProgressCache.setBestSortFound(sheetId, sort);
      }
      analysisResultCache.setSortedWithValidSort(sheetId, isNaturalOrderValid);
      if (analysisResultCache.getToSort(sheetId)) {
        sortMedia(sheetId);
        sortStatusCache.updateSortStatus(sheetId, (status) {
          status.validSortFound = true;
          status.toSort = false;
        });
      } else if (sortStatus.isFindingBestSort) {
        sortStatusCache.updateSortStatus(sheetId, (status) {
          status.validSortFound = true;
        });
        findBestSortToggleFunc(sheetId);
      } else {
        sortStatusCache.removeSortStatus(sheetId);
      }
      if (sortStatusCache.isFindingBestSort(sheetId)) {
        break;
      }
    }
  }

  void cancelFindingBestSort(String sheetId) {
    if (_isolateServices.containsKey(sheetId)) {
      _isolateServices[sheetId]!.cancelC();
    }
  }

  void cancelB(String sheetId) {
    if (_isolatePorts[sheetId]!._isolateB != null) {
      _isolatePorts[sheetId]!._isolateB!.kill(priority: Isolate.immediate);
      _isolatePorts[sheetId]!._isolateB = null;
    }
    if (_isolatePorts[sheetId]!._portB != null) {
      _isolatePorts[sheetId]!._portB!.close();
      _isolatePorts[sheetId]!._portB = null;
    }
  }

  void cancelC(String sheetId) {
    if (_isolatePorts[sheetId]!._isolateC != null) {
      // Kill the isolate immediately
      _isolatePorts[sheetId]!._isolateC!.kill(priority: Isolate.immediate);
      _isolatePorts[sheetId]!._isolateC = null;
    }
    // Close the ReceivePort to prevent memory leaks
    if (_isolatePorts[sheetId]!._portC != null) {
      _isolatePorts[sheetId]!._portC!.close();
      _isolatePorts[sheetId]!._portC = null;
    }
  }

  Future<AnalysisReturn> runHeavyCalculationB(
    String sheetId,
    AnalysisResult result,
  ) async {
    final receivePort = ReceivePort();
    _isolatePorts[sheetId]!._portB = receivePort;

    _isolatePorts[sheetId]!._isolateB = await Isolate.spawn(
      CalculationService.runCalculation,
      [
        receivePort.sendPort,
        loadedSheetsCache.getSheetContent(sheetId),
        result,
      ],
    );

    AnalysisReturn analysisReturn = await receivePort.first;
    _isolatePorts[sheetId]!._isolateB = null;
    return analysisReturn;
  }

  void _sortResult(List<int> sortOrder, String sheetId) {
    AnalysisResult result = analysisResultCache.getAnalysisResult(sheetId);
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

  @override
  void sortMedia(String sheetId) {
    List<int> sortOrder = [0];
    AnalysisResult result = analysisResultCache.getAnalysisResult(sheetId);
    List<int> stack = result.currentBestSort!
        .asMap()
        .entries
        .map((e) => result.validRowIndexes[e.key])
        .toList()
        .reversed
        .toList();
    final table = loadedSheetsCache.getSheetContent(sheetId).table;
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
    for (int rowId = 1; rowId < loadedSheetsCache.rowCount(sheetId); rowId++) {
      for (
        int colId = 0;
        colId < loadedSheetsCache.colCount(sheetId);
        colId++
      ) {
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
          CellUpdate(
            rowId,
            colId,
            sortedTable[rowId][colId],
            loadedSheetsCache.getCellContent(rowId, colId),
          ),
        );
      }
    }
    _sortResult(sortOrder, sheetId);
    sheetDataController.update(
      UpdateData(Uuid().v4(), DateTime.now(), updates),
      false,
    );
  }
}
