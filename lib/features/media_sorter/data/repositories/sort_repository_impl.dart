import 'dart:isolate';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/calculation_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/i_file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/services/utils_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/isolate_receive_ports_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sorting_progress_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/helpers/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';
import 'dart:async';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sort_status_cache.dart';

class SortRepositoryImpl implements SortRepository {
  final AnalysisResultCache analysisResultCache;
  final LoadedSheetsCache loadedSheetsCache;
  final SortProgressCache sortProgressCache;
  final SortStatusCache sortStatusCache;
  final IsolateReceivePortsCache isolateReceivePortsCache;
  final SelectionCache selectionCache;
  final WorkbookCache workbookCache;

  final IFileSheetLocalDataSource saveDataSource;

  final StreamController<Failure> _failureController =
      StreamController<Failure>.broadcast();

  late ManageWaitingTasks<void> _saveAnalysisResultExecutor;
  late ManageWaitingTasks<void> _saveSortStatusExecutor;
  late ManageWaitingTasks<void> _saveSortProgressExecutor;

  @override
  Stream<Failure> get failureStream => _failureController.stream;
  String get currentSheetId => workbookCache.currentSheetId;

  @override
  bool isSorting(String sheetId) {
    return sortStatusCache.isSorting(sheetId);
  }

  @override
  bool getAnalysisDone(String sheetId) {
    return sortStatusCache.getAnalysisDone(sheetId);
  }

  @override
  Future<void> analyze(String sheetId) async {
    isolateReceivePortsCache.cancelB(sheetId);
    AnalysisReturn resultB = await runHeavyCalculationB(
      sheetId,
      analysisResultCache.getAnalysisResult(sheetId),
    );
    sortStatusCache.analysisIsDone(sheetId, resultB.toFindValidSort);
    if (resultB.changed) {
      analysisResultCache.updateResults(sheetId, resultB.result);
      saveAnalysisResult(sheetId);
    }
    if (!resultB.toFindValidSort) {
      return;
    }
    sortProgressCache.update(
      sheetId,
      SortProgressData.empty(resultB.result.validRowIndexes.length),
    );
  }


  @override
  List<String> getSheetIds() {
    return sortStatusCache.getSheetIds();
  }

  @override
  bool isApplyBetterSortButtonLocked() {
    return sortProgressCache.isValidSortImpossible(currentSheetId) ||
        analysisResultCache.bestSortPossibleFound(currentSheetId) &&
            analysisResultCache.sortedWithCurrentBestSort(currentSheetId);
  }

  @override
  bool isBetterSortFound() {
    return !analysisResultCache.sortedWithCurrentBestSort(currentSheetId);
  }

  @override
  bool isApplyBetterSortButtonInAction() {
    return sortStatusCache.containsSheet(currentSheetId) &&
        (sortStatusCache.getToApplyOnce(currentSheetId) ||
            sortStatusCache.getToAlwaysApply(currentSheetId));
  }

  @override
  void applyBetterSortButton() {
    if (isBetterSortFound()) {
      sortMedia(currentSheetId);
    } else {
      sortStatusCache.setToApplyOnce(currentSheetId, true);
      saveAllSortStatus();
    }
  }

  @override
  void findBestSortToggle() {
    sortStatusCache.setToAlwaysApply(
      currentSheetId,
      !sortStatusCache.getToAlwaysApply(currentSheetId),
    );
    saveAllSortStatus();
  }

  @override
  bool showApplySortToggle() {
    return sortStatusCache.containsSheet(currentSheetId);
  }

  @override
  void applySortToggle() {
    sortStatusCache.setToAlwaysApply(
      currentSheetId,
      !sortStatusCache.getToAlwaysApply(currentSheetId),
    );
    saveAllSortStatus();
  }

  @override
  Future<Either<Failure, void>> getAnalysisResult(String sheetId) async {
    final result = await UrilsService.handleDataSourceCall(
      () => saveDataSource.getAnalysisResult(sheetId),
    );
    return result.fold((failure) => Left(failure), (analysisResult) {
      analysisResultCache.updateResults(sheetId, analysisResult);
      return Right(null);
    });
  }

  @override
  bool getToApplyNextSort(String sheetId) =>
      sortStatusCache.getToAlwaysApply(sheetId) ||
      sortStatusCache.getToApplyOnce(sheetId);
  @override
  bool sortedWithValidSort(String sheetId) =>
      analysisResultCache.sortedWithValidSort(sheetId);

  SortRepositoryImpl(
    this.analysisResultCache,
    this.loadedSheetsCache,
    this.sortProgressCache,
    this.sortStatusCache,
    this.isolateReceivePortsCache,
    this.saveDataSource,
    this.selectionCache,
    this.workbookCache,
  ) {
    _saveAnalysisResultExecutor = ManageWaitingTasks<void>(
      Duration(milliseconds: 2000),
      _failureController,
    );
    _saveSortStatusExecutor = ManageWaitingTasks<void>(
      Duration(milliseconds: 2000),
      _failureController,
    );
    _saveSortProgressExecutor = ManageWaitingTasks<void>(
      Duration(milliseconds: 2000),
      _failureController,
    );
  }

  @override
  void setToApplyOnce(String sheetId, bool toApplyOnce) {
    sortStatusCache.setToApplyOnce(sheetId, toApplyOnce);
    saveAllSortStatus();
  }

  @override
  Future<Either<Failure, void>> loadSortStatus() async {
    final result = await UrilsService.handleDataSourceCall(
      () => saveDataSource.getSortStatus(),
    );
    return result.fold((failure) => Left(failure), (ids) {
      sortStatusCache.setSortStatus(ids);
      bool sortStatusChanged = false;
      bool workbookSelectionCacheChanged = false;
      for (var sheetId in sortStatusCache.getSheetIds()) {
        if (!UrilsService.isValidSheetName(sheetId)) {
          sortStatusCache.removeSortStatus(sheetId);
          sortStatusChanged = true;
        } else if (!loadedSheetsCache.containsSheetId(sheetId)) {
          workbookCache.addSheetId(sheetId, 1);
          selectionCache.setSelectionData(sheetId, SelectionData.empty());
          workbookSelectionCacheChanged = true;
        }
      }
      return sortStatusChanged || workbookSelectionCacheChanged
          ? Left(
              CacheRepairedFailure(
                sortStatusChanged: sortStatusChanged,
                workbookCacheChanged: workbookSelectionCacheChanged,
                selectionCacheChanged: workbookSelectionCacheChanged,
              ),
            )
          : Right(null);
    });
  }

  bool sameResLightCheck() {
    return false;
  }

  bool lightCalculate1() {
    String sheetId = workbookCache.currentSheetId;
    int n = 10;
    bool impossible = 1 != 1;
    if (impossible) {
      sortProgressCache.update(sheetId, SortProgressData.empty());
      return false;
    }
    bool easilyCalculable = 1 != 1;
    if (easilyCalculable) {
      sortProgressCache.update(sheetId, SortProgressData.empty(n));
      return false;
    }
    return !impossible;
  }

  void changeResult() {
    return;
  }

  bool lightCalculate2() {
    String sheetId = workbookCache.currentSheetId;
    int n = 10;
    bool impossible = 1 != 1;
    if (impossible) {
      sortProgressCache.update(sheetId, SortProgressData.empty());
      return false;
    }
    bool easilyCalculable = 1 != 1;
    if (easilyCalculable) {
      sortProgressCache.update(sheetId, SortProgressData.empty(n));
      return false;
    }
    return !impossible;
  }

  @override
  Future<Stream<SortProgressDataMsg>> launchCalculation(String sheetId) async {
    isolateReceivePortsCache.initPortC(sheetId);
    final args = (
      isolateReceivePortsCache.getSendPortC(sheetId),
      analysisResultCache.getMyRules(sheetId),
      sortProgressCache.getSortProgressData(sheetId),
    );
    isolateReceivePortsCache.setIsolateC(
      sheetId,
      await Isolate.spawn(CalculationDatasource.solveSorting, args),
    );
    return isolateReceivePortsCache
        .getIsolatePort(sheetId)
        .cast<SortProgressDataMsg>();
  }

  @override
  void lightCalculations(String sheetId) async* {
    isolateReceivePortsCache.addIsolatePortIfNecessary(sheetId);
    if (!lightCalculate1()) {
      isolateReceivePortsCache.cancelB(sheetId);
      sortStatusCache.removeSortStatus(sheetId);
      return;
    }
    if (sameResLightCheck()) {
      if (sortStatusCache.getAnalysisDone(sheetId)) {
        return;
      }
      changeResult();
      return;
    }
    if (!lightCalculate2()) {
      isolateReceivePortsCache.cancelB(sheetId);
      sortStatusCache.removeSortStatus(sheetId);
      return;
    }
    sortStatusCache.isAnalysing(sheetId);
    setSortedWithValidSort(sheetId, false);
  }

  void setSortedWithValidSort(String sheetId, bool sorted) {
    analysisResultCache.setSortedWithValidSort(sheetId, sorted);
    saveAnalysisResult(sheetId);
  }

  @override
  bool handleSortProgressDataMsg(
    SortProgressDataMsg sortProgressDataMsg,
    String sheetId,
  ) {
    SortProgressData sort = sortProgressDataMsg.sortProgressData;
    if (sortProgressDataMsg.newBestSortFound &&
        sortProgressCache.getSortProgressData(sheetId).bestDistFound.isEmpty) {
      bool isNaturalOrderValid = true;
      if (sort.bestDistFound.isNotEmpty) {
        for (int k = 0; k < sort.bestSortFound.length; k++) {
          if (sort.bestSortFound[k] != k) {
            isNaturalOrderValid = false;
            break;
          }
        }
      }
      setSortedWithValidSort(sheetId, isNaturalOrderValid);
    }
    sortProgressCache.update(sheetId, sort);
    saveDataProgress(sheetId);
    if (sort.cursors[0] == sort.possibleIntsById[0].length) {
      sortStatusCache.removeSortStatus(sheetId);
      saveAllSortStatus();
    }
    return sortProgressDataMsg.newBestSortFound &&
        !analysisResultCache.getFindingBestSort(sheetId);
  }

  void cancelFindingBestSort(String sheetId) {
    isolateReceivePortsCache.cancelC(sheetId);
  }

  Future<AnalysisReturn> runHeavyCalculationB(
    String sheetId,
    AnalysisResult result,
  ) async {
    isolateReceivePortsCache.initPortB(sheetId);

    isolateReceivePortsCache.setIsolateB(
      sheetId,
      await Isolate.spawn(CalculationService.runCalculation, [
        isolateReceivePortsCache.getIsolatePort(sheetId).sendPort,
        loadedSheetsCache.getSheetContent(sheetId),
        result,
      ]),
    );

    AnalysisReturn analysisReturn = await isolateReceivePortsCache
        .getReceivePortB(sheetId)
        .first;
    isolateReceivePortsCache.setIsolateB(sheetId, null);
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
  List<UpdateUnit> sortMedia(String sheetId) {
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
            loadedSheetsCache.getCellContent(sheetId, rowId, colId),
          ),
        );
      }
    }
    _sortResult(sortOrder, sheetId);
    return updates;
  }

  void saveAnalysisResult(String sheetId) async {
    _saveAnalysisResultExecutor.execute(() async {
      try {
        await saveDataSource.saveAnalysisResult(
          sheetId,
          analysisResultCache.getAnalysisResult(sheetId),
        );
      } on CacheException catch (e) {
        _failureController.add(CacheFailure(e));
      }
    });
  }

  void saveAllSortStatus() async {
    _saveSortStatusExecutor.execute(() async {
      try {
        await saveDataSource.saveAllSortStatus(
          sortStatusCache.sortStatusBySheet,
        );
      } on CacheException catch (e) {
        _failureController.add(CacheFailure(e));
      }
    });
  }

  void saveDataProgress(String sheetId) {
    _saveSortProgressExecutor.execute(() async {
      try {
        await saveDataSource.saveSortProgression(
          sheetId,
          sortProgressCache.getSortProgressData(sheetId),
        );
      } on CacheException catch (e) {
        _failureController.add(CacheFailure(e));
      }
    });
  }
}
