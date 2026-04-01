import 'dart:isolate';

import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/calculation_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/local_data_source.dart';
import 'package:trying_flutter/features/media_sorter/data/services/add_update.dart';
import 'package:trying_flutter/features/media_sorter/data/store/isolate_receive_ports_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sorting_progress_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/helpers/calculation_service.dart';
import 'dart:async';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sort_status_cache.dart';

enum PreCalculationsResult { impossible, analysisDone, sortDone, needToCorrect }

class SortRepositoryImpl implements SortRepository {
  final ILocalDataSource saveDataSource;

  final AnalysisResultCache analysisResultCache;
  final LoadedSheetsCache loadedSheetsCache;
  final SortProgressCache sortProgressCache;
  final SortStatusCache sortStatusCache;
  final IsolateReceivePortsCache isolateReceivePortsCache;
  final SelectionCache selectionCache;
  final WorkbookCache workbookCache;

  int get currentSheetId => workbookCache.currentSheetId;

  @override
  bool isReordering(int sheetId) {
    return sortStatusCache.isReordering(sheetId);
  }

  @override
  bool getAnalysisDone(int sheetId) {
    return sortStatusCache.getAnalysisDone(sheetId);
  }

  @override
  @useResult
  Future<UpdateUnit?> analyze(int sheetId) async {
    isolateReceivePortsCache.cancelB(sheetId);
    AnalysisReturn resultB = await runHeavyCalculationB(
      sheetId,
      analysisResultCache.getAnalysisResult(sheetId),
    );
    sortStatusCache.analysisIsDone(sheetId, resultB.toFindValidSort);
    UpdateUnit? update;
    if (resultB.changed) {
      analysisResultCache.updateResults(sheetId, resultB.result);
      update = SheetDataUpdate(
        sheetId,
        true,
        analysisResult: resultB.result.toString(),
      );
    }
    if (!resultB.toFindValidSort) {
      return update;
    }
    sortProgressCache.update(
      sheetId,
      SortProgressData.empty(resultB.result.validRowIndexes.length),
    );
    return update;
  }

  @override
  List<int> getSheetIds() {
    return sortStatusCache.getSheetIds();
  }

  @override
  bool canFindBetterSort(int sheetId) {
    return !sortProgressCache.isValidSortImpossible(sheetId) &&
        (!analysisResultCache.bestSortPossibleFound(sheetId) ||
            !analysisResultCache.sortedWithCurrentBestSort(sheetId));
  }

  @override
  bool isApplyBetterSortButtonLocked() {
    return canFindBetterSort(currentSheetId) ||
        isCalculating(currentSheetId) &&
            sortStatusCache.willNextBestSortBeApplied(currentSheetId);
  }

  @override
  bool sortedWithCurrentBestSort(int sheetId) {
    return analysisResultCache.sortedWithCurrentBestSort(sheetId);
  }

  @override
  bool isApplyBetterSortButtonInAction() {
    return isCalculating(currentSheetId) &&
        (sortStatusCache.getToApplyOnce(currentSheetId) ||
            sortStatusCache.isCurrentBestSortAlwaysApplied(currentSheetId));
  }

  @override
  @useResult
  UpdateUnit setToAlwaysApplyBestSort(int sheetId, bool toAlwaysApply) {
    sortStatusCache.setToAlwaysApplyBestSort(currentSheetId, toAlwaysApply);
    return SheetDataUpdate(
      sheetId,
      true,
      toAlwaysApplyCurrentBestSort: toAlwaysApply,
    );
  }

  @override
  @useResult
  UpdateUnit removeSortStatus(int sheetId) {
    sortStatusCache.removeSortStatus(sheetId);
    return SheetDataUpdate(sheetId, true, sortInProgress: false);
  }

  @override
  void addNewAnalysisResult(int sheetId) {
    analysisResultCache.addNewAnalysisResult(sheetId);
  }

  @override
  bool isCurrentBestSortAlwaysApplied(int sheetId) =>
      sortStatusCache.isCurrentBestSortAlwaysApplied(sheetId);
  @override
  bool willNextBestSortBeApplied(int sheetId) =>
      sortStatusCache.willNextBestSortBeApplied(sheetId);
  @override
  bool getToApplyOnce(int sheetId) => sortStatusCache.getToApplyOnce(sheetId);
  @override
  bool isCalculating(int sheetId) => sortStatusCache.containsSheet(sheetId);
  @override
  bool isSortedWithValidSort(int sheetId) =>
      analysisResultCache.isSortedWithValidSort(sheetId);

  SortRepositoryImpl(
    this.saveDataSource,
    this.analysisResultCache,
    this.loadedSheetsCache,
    this.sortProgressCache,
    this.sortStatusCache,
    this.isolateReceivePortsCache,
    this.selectionCache,
    this.workbookCache,
  );

  @override
  @useResult
  UpdateUnit setToApplyOnce(int sheetId, bool toApplyOnce) {
    sortStatusCache.setToApplyOnce(sheetId, toApplyOnce);
    return SheetDataUpdate(sheetId, true, toApplyNextBestSort: toApplyOnce);
  }

  @override
  @useResult
  UpdateUnit setSortedWithCurrentBestSort(int sheetId, bool value) {
    analysisResultCache.setSortedWithCurrentBestSort(sheetId, value);
    return SheetDataUpdate(sheetId, true, sortedWithCurrentBestSort: value);
  }

  @override
  Future<Either<Failure, Unit>> loadSortStatus() async {
    try {
      final tables = await saveDataSource.getSortStatus();
      final sortStatusBySheet = {
        for (var table in tables)
          table.sheetId: SortStatus(
            table.toApplyNextBestSort,
            table.toAlwaysApplyCurrentBestSort,
            table.analysisDone,
          )
      };
      sortStatusCache.setSortStatus(sortStatusBySheet);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  PreCalculationsResult? sameResLightCheck() {
    return null;
  }

  UpdateUnit? lightCalculate1(int sheetId) {
    bool impossible = 1 != 1;
    if (impossible) {
      return SheetDataUpdate(sheetId, true, validSortIsImpossible: true);
    }
    bool analysisDone = 1 != 1;
    if (analysisDone) {
      return SheetDataUpdate(sheetId, true, analysisDone: true);
    }
    return null;
  }

  UpdateUnit? lightCalculate2(int sheetId) {
    bool impossible = 1 != 1;
    if (impossible) {
      return SheetDataUpdate(sheetId, true, validSortIsImpossible: true);
    }
    bool analysisDone = 1 != 1;
    if (analysisDone) {
      return SheetDataUpdate(sheetId, true, analysisDone: true);
    }
    return null;
  }

  @override
  Future<Stream<SortProgressDataMsg>> launchCalculation(int sheetId) async {
    isolateReceivePortsCache.initPortC(sheetId);
    final args = (
      isolateReceivePortsCache.getSendPortC(sheetId),
      analysisResultCache.getMyRules(sheetId),
      analysisResultCache.getGroupAttribution(sheetId),
      sortProgressCache.getSortProgressData(sheetId),
    );
    isolateReceivePortsCache.setIsolateC(
      sheetId,
      await Isolate.spawn(CalculationDatasource.solveSorting, args),
    );
    return isolateReceivePortsCache
        .getReceivePortC(sheetId)
        .cast<SortProgressDataMsg>();
  }

  @useResult
  UpdateUnit setSortedWithValidSort(int sheetId, bool sorted) {
    analysisResultCache.setSortedWithValidSort(sheetId, sorted);
    return SheetDataUpdate(
      sheetId,
      true,
      sortedWithValidSort: sorted,
    );
  }

  @override
  bool handleSortProgressDataMsg(
    SortProgressDataMsg sortProgressDataMsg,
    int sheetId,
    Map<String, UpdateUnit> updates,
  ) {
    SortProgressData sort = sortProgressDataMsg.sortProgressData;
    if (sortProgressDataMsg.newBestSortFound &&
        sortProgressCache.getSortProgressData(sheetId).bestDistFound.isEmpty) {
      bool isNaturalOrderValid = true;
      if (sort.hasValidSort()) {
        for (int k = 0; k < sort.bestSortFound.length; k++) {
          if (sort.bestSortFound[k] != k) {
            isNaturalOrderValid = false;
            break;
          }
        }
      }
      final result = setSortedWithValidSort(sheetId, isNaturalOrderValid);
      AddUpdate.addUpdate(updates, result);
    }
    sortProgressCache.update(sheetId, sort);
    if (!sort.hasMoreToExplore()) {
      final result = removeSortStatus(sheetId);
      AddUpdate.addUpdate(updates, result);
      if (sort.bestDistFound.isEmpty) {
        final result = setValidSortIsImpossible(sheetId, true);
        AddUpdate.addUpdate(updates, result);
        final result2 = setSortedWithCurrentBestSort(sheetId, true);
        AddUpdate.addUpdate(updates, result2);
      }
    }
    if (analysisResultCache.isFindingBestSort(sheetId) &&
        sortProgressDataMsg.newBestSortFound &&
        sortProgressDataMsg.sortProgressData.bestDistFound.every(
          (element) => element == 0,
        )) {
      return true;
    }
    return sortProgressDataMsg.newBestSortFound &&
        !analysisResultCache.isFindingBestSort(sheetId);
  }

  UpdateUnit setValidSortIsImpossible(int sheetId, bool impossible) {
    analysisResultCache.setValidSortIsImpossible(sheetId, impossible);
    return SheetDataUpdate(
      sheetId,
      true,
      validSortIsImpossible: impossible,
    );
  }

  @override
  void setFindingBestSort(int sheetId, bool findingBestSort) {
    analysisResultCache.setFindingBestSort(sheetId, findingBestSort);
    if (!findingBestSort &&
        sortProgressCache
            .getSortProgressData(sheetId)
            .bestDistFound
            .isNotEmpty) {
      isolateReceivePortsCache.cancelC(sheetId);
    }
  }

  @override
  bool isFindingBestSort(int sheetId) {
    return analysisResultCache.isFindingBestSort(sheetId);
  }

  Future<AnalysisReturn> runHeavyCalculationB(
    int sheetId,
    AnalysisResult result,
  ) async {
    isolateReceivePortsCache.initPortB(sheetId);

    isolateReceivePortsCache.setIsolateB(
      sheetId,
      await Isolate.spawn(CalculationService.runCalculation, [
        isolateReceivePortsCache.getReceivePortB(sheetId).sendPort,
        loadedSheetsCache.getCells(sheetId),
        result,
      ]),
    );

    AnalysisReturn analysisReturn = await isolateReceivePortsCache
        .getReceivePortB(sheetId)
        .first;
    isolateReceivePortsCache.setIsolateB(sheetId, null);
    return analysisReturn;
  }

  void _sortResult(List<int> sortOrder, int sheetId) {
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
  Map<String, UpdateUnit> sortTableWithCurrentBestSort(int sheetId) {
    List<int> sortOrder = [0];
    AnalysisResult result = analysisResultCache.getAnalysisResult(sheetId);
    List<int> stack = result.currentBestSort!
        .asMap()
        .entries
        .map((e) => result.validRowIndexes[e.key])
        .toList()
        .reversed
        .toList();
    final table = loadedSheetsCache.getCells(sheetId);
    List<int> added = List.filled(loadedSheetsCache.rowCount(sheetId), 0);
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
    final sortedTable = {
      for (CellPosition pos in table.keys)
        CellPosition(sortOrder[pos.rowId], pos.colId): table[pos]!,
    };
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
          sortedTable[CellPosition(rowId, colId)] =
              result.formatedTable[rowId][colId].strings[splitId];
          if (result.formatedTable[rowId][colId].integers.length <= splitId) {
            break;
          }
          sortedTable[CellPosition(rowId, colId)] =
              sortedTable[CellPosition(rowId, colId)]! +
              toNewPlacement[result
                  .formatedTable[rowId][colId]
                  .integers[splitId]];
        }
      }
    }
    final Map<String, UpdateUnit> updates = {};
    for (CellPosition pos in sortedTable.keys) {
      final cellUpdate = CellUpdate(
        sheetId,
        pos.rowId,
        pos.colId,
        sortedTable[pos]!,
      );
      updates[cellUpdate.getKey()] = cellUpdate;
    }
    _sortResult(sortOrder, sheetId);
    return updates;
  }
}
