import 'package:drift/drift.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/local_data_source.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/data/store/current_change_list.dart';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/layout_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sort_status_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sorting_progress_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/history_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';


// ---------------------------------------------------------
// 1. Define Numbers as Types (Peano Arithmetic)
// ---------------------------------------------------------
sealed class Nat {}
class Z extends Nat {}           // Represents 0
class S<N extends Nat> extends Nat {} // Represents N + 1 (Successor)

// ---------------------------------------------------------
// 2. Phase 1: Counting Up
// ---------------------------------------------------------
class Phase1<N extends Nat> {
  // Every time we call 'doA', we wrap the current type N in an S<N>.
  // This increments our compile-time counter.
  Phase1<S<N>> doA() {
    return Phase1<S<N>>();
  }

  // Lock in the count and move to the second phase.
  Phase2<N> transition() {
    return Phase2<N>();
  }
}

// ---------------------------------------------------------
// 3. Phase 2: Base Class
// ---------------------------------------------------------
class Phase2<N extends Nat> {}

// ---------------------------------------------------------
// 4. Phase 2: Counting Down (The Magic)
// ---------------------------------------------------------
// This extension ONLY applies if N is greater than 0 (i.e., S<Prev>).
// It "unwraps" one layer of S, effectively decrementing the counter.
extension Phase2Decrement<Prev extends Nat> on Phase2<S<Prev>> {
  Phase2<Prev> doB() {
    return Phase2<Prev>();
  }
}

// ---------------------------------------------------------
// 5. Enforcing the End State
// ---------------------------------------------------------
// The 'finish' method ONLY exists if the counter has reached exactly 0.
extension Phase2End on Phase2<Z> {
  void finish() {}
}

class HistoryRepositoryImpl implements HistoryRepository {
  final ILocalDataSource localDataSource;

  final LoadedSheetsCache loadedSheetsDataStore;
  final WorkbookCache workbookCache;
  final SelectionCache selectionCache;
  final HistoryCache historyCache;
  final LayoutCache layoutCache;
  final SortStatusCache sortStatusCache;
  final SortProgressCache sortProgressCache;
  final AnalysisResultCache analysisResultCache;
  final CurrentChangeList currentChangeList;
  int chronoIdCounter = 0;
  int? lastChronoId;
  DateTime? lastTimestamp;

  int get currentSheetId => workbookCache.currentSheetId;
  CoreSheetContent get currentSheet =>
      loadedSheetsDataStore.getSheet(currentSheetId);
  HistoryData get historyData => historyCache[currentSheetId]!;
  HistoryData get selectionHistoryData => selectionCache[currentSheetId]!;

  HistoryRepositoryImpl(
    this.localDataSource,
    this.loadedSheetsDataStore,
    this.workbookCache,
    this.selectionCache,
    this.historyCache,
    this.layoutCache,
    this.sortStatusCache,
    this.sortProgressCache,
    this.analysisResultCache,
    this.currentChangeList,
  );

  @override
  void moveInUpdateHistory(HistoryType historyType, int direction) {
    int newHistoryIndex = historyData.historyIndex + direction;
    if (newHistoryIndex + direction < 0 ||
        newHistoryIndex + direction >= historyData.updateHistories.length) {
      return;
    }
    var updateData = historyData.updateHistories[newHistoryIndex];
    if (historyType == HistoryType.editModeChange &&
        updateData.type != HistoryType.editModeChange) {
      return;
    }
    if (historyType == HistoryType.other) {
      while (updateData.type == HistoryType.editModeChange) {
        newHistoryIndex += direction;
        if (newHistoryIndex + direction < 0 ||
            newHistoryIndex + direction >= historyData.updateHistories.length) {
          return;
        }
      }
    }
    updateData = historyData.updateHistories[newHistoryIndex];
    currentChangeList.changeListWithHist = updateData.updates.map((e) {
      var dataBaseOperationType = e.dataBaseOperationType;
      if (direction < 0) {
        dataBaseOperationType = switch (e.dataBaseOperationType) {
          DataBaseOperationType.insert => DataBaseOperationType.delete,
          DataBaseOperationType.delete => DataBaseOperationType.insert,
          DataBaseOperationType.update => DataBaseOperationType.update,
          DataBaseOperationType.deleteWhere =>
            DataBaseOperationType.deleteWhere,
        };
      }
      return SyncRequestWithHist(
        direction < 0 ? e.companionWrapper : e.historyCompW,
        direction < 0 ? e.historyCompW : e.companionWrapper,
        dataBaseOperationType,
      );
    }).toList();
    historyData.historyIndex = newHistoryIndex;
  }

  List<SyncRequestWithoutHist> reverseHistoryEntity(
    List<SyncRequestWithoutHist> updates,
  ) {
    List<SyncRequestWithoutHist> reversedUpdates = [];
    for (int i = updates.length - 1; i >= 0; i--) {
      var update = updates[i];
      var dataBaseOperationType = switch (update.dataBaseOperationType) {
        DataBaseOperationType.insert => DataBaseOperationType.delete,
        DataBaseOperationType.delete => DataBaseOperationType.insert,
        DataBaseOperationType.update => DataBaseOperationType.update,
        DataBaseOperationType.deleteWhere => DataBaseOperationType.deleteWhere,
      };
      DbCompanionWrapper newCmpWrp;
      switch (update.companionWrapper) {
        case SheetDataWrapper():
          final currCpm = (update.companionWrapper as SheetDataWrapper).companion;
          final sheetId = currCpm.sheetId;
          Value<String> title = currCpm.title.present ? Value(loadedSheetsDataStore.getSheet(sheetId.value).title) : Value.absent();
          Value<DateTime> lastOpened = currCpm.lastOpened.present ? Value(loadedSheetsDataStore.getSheet(sheetId.value).lastOpened) : Value.absent();
          Value<List<int>> usedRows = currCpm.usedRows.present ? Value(loadedSheetsDataStore.getSheet(sheetId.value).usedRows) : Value.absent();
          Value<List<int>> usedCols = currCpm.usedCols.present ? Value(loadedSheetsDataStore.getSheet(sheetId.value).usedCols) : Value.absent();
          Value<int> historyIndex = currCpm.historyIndex.present ? Value(historyCache[sheetId.value]!.historyIndex) : Value.absent();
          Value<double> colHeaderHeight = currCpm.colHeaderHeight.present ? Value(layoutCache.getLayout(sheetId.value).colHeaderHeight) : Value.absent();
          Value<double> rowHeaderWidth = currCpm.rowHeaderWidth.present ? Value(layoutCache.getLayout(sheetId.value).rowHeaderWidth) : Value.absent();
          Value<int> primarySelectionX = currCpm.primarySelectionX.present ? selectionCache.getSelectionState(sheetId.value).primarySelectionX : Value.absent();
          Value<int> primarySelectionY = currCpm.primarySelectionY.present ? selectionCache.getSelectionState(sheetId.value).primarySelectionY : Value.absent();
          Value<Set<CellPosition>> selectedCells = currCpm.selectedCells.present ? selectionCache.getSelectionState(sheetId.value).selectedCells : Value.absent();
          Value<int> selectionHistoryId = currCpm.selectionHistoryId.present ? selectionCache.getSelectionState(sheetId.value).selectionHistoryId : Value.absent();
          Value<double> scrollOffsetX = currCpm.scrollOffsetX.present ? selectionCache.getSelectionState(sheetId.value).scrollOffsetX : Value.absent();
          Value<double> scrollOffsetY = currCpm.scrollOffsetY.present ? selectionCache.getSelectionState(sheetId.value).scrollOffsetY : Value.absent();
          final bestSortFound = currCpm.bestSortFound.present ? Value(sortProgressCache.getSortProgressData(sheetId.value).bestSortFound) : Value.absent();
          final bestDistFound = currCpm.bestDistFound.present ? Value(sortProgressCache.getSortProgressData(sheetId.value).bestDistFound) : Value.absent();
          final cursors = currCpm.cursors.present ? Value(sortProgressCache.getSortProgressData(sheetId.value).cursors) : Value.absent();
          final possibleInts = currCpm.possibleInts.present ? Value(sortProgressCache.getSortProgressData(sheetId.value).possibleIntsById) : Value.absent();
          final validAreas = currCpm.validAreas.present ? Value(sortProgressCache.getSortProgressData(sheetId.value).validAreasById) : Value.absent();
          final sortIndex = currCpm.sortIndex.present ? Value(sortProgressCache.getSortProgressData(sheetId.value).sortIndex) : Value.absent();
          final analysisResult = currCpm.analysisResult.present ? Value(analysisResultCache.getAnalysisResult(sheetId.value)) : Value.absent();
          final sortInProgress = currCpm.sortInProgress.present ? Value(sortProgressCache.sortInProgress(sheetId.value)) : Value.absent();
          final toAlwaysApplyCurrentBestSort = currCpm.toAlwaysApplyCurrentBestSort.present ? Value(loadedSheetsDataStore.getSheet(sheetId.value).toAlwaysApplyCurrentBestSort) : Value.absent();
          final toApplyNextBestSort = currCpm.toApplyNextBestSort.present ? Value(sortStatusCache.getToApplyOnce(sheetId.value)) : Value.absent();
          final analysisDone = currCpm.analysisDone.present ? Value(sortStatusCache.getAnalysisDone(sheetId.value)) : Value.absent();
          var newCmp = SheetDataTablesCompanion(
            sheetId: sheetId,
            title: title,
            lastOpened: lastOpened,
            usedRows: usedRows,
            usedCols: usedCols,
            historyIndex: historyIndex,
            colHeaderHeight: colHeaderHeight,
            rowHeaderWidth: rowHeaderWidth,
            primarySelectionX: primarySelectionX,
            primarySelectionY: primarySelectionY,
            selectedCells: selectedCells,
            selectionHistoryId: selectionHistoryId,
            scrollOffsetX: scrollOffsetX,
            scrollOffsetY: scrollOffsetY,
            bestSortFound: bestSortFound,
            bestDistFound: bestDistFound,
            cursors: cursors,
            possibleInts: possibleInts,
            validAreas: validAreas,
            sortIndex: sortIndex,
            analysisResult: analysisResult,
            sortInProgress: sortInProgress,
            toAlwaysApplyCurrentBestSort: toAlwaysApplyCurrentBestSort,
            toApplyNextBestSort: toApplyNextBestSort,
            analysisDone: analysisDone,
          );
          void schemaCheck() {
            SheetDataEntity(
              sheetId: sheetId.present ? sheetId.value : 0,
              title: title.present ? title.value : '',
              lastOpened: lastOpend.present ? lastOpend.value : DateTime.now(),
              usedRows: usedRows.present ? usedRows.value : [],
              usedCols: usedCols.present ? usedCols.value : [],
              historyIndex: historyIndex.present ? historyIndex.value : 0,
              colHeaderHeight: colHeaderHeight.present ? colHeaderHeight.value : 0,
              rowHeaderWidth: rowHeaderWidth.present ? rowHeaderWidth.value : 0,
              primarySelectionX: primarySelectionX.present ? primarySelectionX.value : 0,
              primarySelectionY: primarySelectionY.present ? primarySelectionY.value : 0,
              selectedCells: selectedCells.present ? selectedCells.value : {},
              selectionHistoryId: selectionHistoryId.present ? selectionHistoryId.value : 0,
              scrollOffsetX: scrollOffsetX.present ? scrollOffsetX.value : 0,
              scrollOffsetY: scrollOffsetY.present ? scrollOffsetY.value : 0,
              bestSortFound: bestSortFound.present ? bestSortFound.value : [],
              bestDistFound: bestDistFound.present ? bestDistFound.value : [],
              cursors: cursors.present ? cursors.value : [],
              possibleInts: possibleInts.present ? possibleInts.value : [],
              validAreas: validAreas.present ? validAreas.value : [],
              sortIndex: sortIndex.present ? sortIndex.value : 0,
              analysisResult: analysisResult.present ? analysisResult.value : AnalysisResult.empty(),
              sortInProgress: sortInProgress.present ? sortInProgress.value : false,
              toAlwaysApplyCurrentBestSort: toAlwaysApplyCurrentBestSort.present ? toAlwaysApplyCurrentBestSort.value : false,
              toApplyNextBestSort: toApplyNextBestSort.present ? toApplyNextBestSort.value : false,
              analysisDone: analysisDone.present ? analysisDone.value : false,
            );
          }
          if (true == false) {
            schemaCheck();
          }
          newCmpWrp = SheetDataWrapper(
            newCmp,
          );
      }
      reversedUpdates.add(
        SyncRequestWithoutHist(newCmpWrp, dataBaseOperationType),
      );
    }
    return reversedUpdates;
  }

  /* Updates the history cache and returns the changeList without the history 
  information and with the history requests
  */
  @override
  void commitHistory(
    int sheetId,
    HistoryType historyType,
    bool sameHistIdFromLast,
  ) {
    final updateData = currentChangeList.changeListWithHist;

    List<SyncRequestWithoutHist> changeList = [];
    if (sameHistIdFromLast) {
      if (lastTimestamp == null || lastChronoId == null) {
        throw Exception(
          'Last timestamp or chronoId is null while sameHistIdFromLast is true',
        );
      }
    } else {
      lastTimestamp = DateTime.now();
      lastChronoId = chronoIdCounter++;
    }
    final historyReq = SyncRequestWithoutHist(
      HistoryWrapper(
        UpdateHistoriesTableCompanion(
          timestamp: Value(lastTimestamp!),
          chronoId: Value(lastChronoId!),
          sheetId: Value(sheetId),
          updates: Value(currentChangeList.changeListWithHist),
          type: Value(historyType),
        ),
      ),
      DataBaseOperationType.insert,
    );
    changeList.add(historyReq);
    changeList.addAll(updateData);

    final historyCenter = historyType == HistoryType.selectionChange
        ? selectionHistoryData
        : historyData;

    if (historyCenter.historyIndex < historyCenter.updateHistories.length - 1) {
      for (
        int i = historyCenter.historyIndex + 1;
        i < historyCenter.updateHistories.length;
        i++
      ) {
        changeList.add(
          SyncRequestWithoutHist(
            HistoryWrapper(
              UpdateHistoriesTableCompanion(
                timestamp: Value(historyCenter.updateHistories[i].timestamp),
                chronoId: Value(historyCenter.updateHistories[i].chronoId),
                sheetId: Value(sheetId),
                type: Value(historyType),
              ),
            ),
            DataBaseOperationType.delete,
          ),
        );
      }
      historyCenter.updateHistories = historyCenter.updateHistories.sublist(
        0,
        historyCenter.historyIndex + 1,
      );
    }
    historyCenter.updateHistories.add(
      UpdateHistoriesEntity(
        sheetId: sheetId,
        updates: currentChangeList.changeListWithHist,
        timestamp:
            (historyReq.companionWrapper as UpdateHistoriesTableCompanion)
                .timestamp
                .value,
        chronoId: (historyReq.companionWrapper as UpdateHistoriesTableCompanion)
            .chronoId
            .value,
        type: historyType,
      ),
    );
    historyCenter.historyIndex++;
    if (historyCenter.historyIndex ==
        SpreadsheetConstants.historyLimitPerSheet) {
      historyCenter.updateHistories.removeAt(0);
      changeList.add(
        SyncRequestWithoutHist(
          HistoryWrapper(
            UpdateHistoriesTableCompanion(
              timestamp: Value(historyCenter.updateHistories[0].timestamp),
              chronoId: Value(historyCenter.updateHistories[0].chronoId),
              sheetId: Value(sheetId),
              type: Value(historyType),
            ),
          ),
          DataBaseOperationType.delete,
        ),
      );
      historyCenter.historyIndex--;
    }
    changeList.add(
      SyncRequestWithoutHist(
        SheetDataWrapper(
          SheetDataTablesCompanion(
            sheetId: Value(sheetId),
            historyIndex: Value(historyCenter.historyIndex),
          ),
        ),
        DataBaseOperationType.update,
      ),
    );
    localDataSource.save(changeList);
  }

  @override
  void addSheetId(int sheetId) {
    final historyData = HistoryData.empty();
    historyCache.setUpdateHistories(sheetId, historyData);
    currentChangeList.changeListWithHist.add(
      SyncRequestWithHist(
        SheetDataWrapper(SheetDataTablesCompanion(sheetId: Value(sheetId))),
        SheetDataWrapper(SheetDataTablesCompanion(sheetId: Value(sheetId))),
        DataBaseOperationType.insert,
      ),
    );
  }
}
