import 'dart:async';

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
import 'package:trying_flutter/features/media_sorter/domain/models/history_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/update_history_model.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';

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
  bool commitScheduled = false;

  int get currentSheetId => workbookCache.currentSheetId;
  CoreSheetContent get currentSheet =>
      loadedSheetsDataStore.getSheet(currentSheetId);
  HistoryData get historyData => historyCache[currentSheetId]!;
  HistoryData get selectionHistoryData => selectionCache.getSelectionData(currentSheetId);

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
  bool moveInUpdateHistory(
    int sheetId,
    HistoryType historyType,
    int direction,
  ) {
    int newHistoryIndex = historyData.historyIndex + direction;
    if (newHistoryIndex + direction < 0 ||
        newHistoryIndex + direction >= historyData.updateHistories.length) {
      return false;
    }
    var updateData = historyData.updateHistories[newHistoryIndex];
    if (historyType == HistoryType.editModeChange &&
        updateData.type != HistoryType.editModeChange) {
      return false;
    }
    if (historyType == HistoryType.other) {
      while (updateData.type == HistoryType.editModeChange) {
        newHistoryIndex += direction;
        if (newHistoryIndex + direction < 0 ||
            newHistoryIndex + direction >= historyData.updateHistories.length) {
          return false;
        }
      }
    }
    updateData = historyData.updateHistories[newHistoryIndex];
    final currentChanges = updateData.updates;
    currentChanges.add(
      SyncRequestWithoutHist(
        HistoryWrapper(
          UpdateHistoriesTableCompanion(
            timestamp: Value(updateData.timestamp),
            chronoId: Value(updateData.chronoId),
            sheetId: Value(updateData.sheetId),
            updates: Value(reverseHistoryEntity(updateData.updates)),
            type: Value(updateData.type),
          ),
        ),
        DataBaseOperationType.update,
      ),
    );
    historyData.historyIndex = newHistoryIndex;
    localDataSource.save(currentChanges);
    return true;
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
          final currCpm =
              (update.companionWrapper as SheetDataWrapper).companion;
          final sheetId = currCpm.sheetId.value;
          Value<String> title = currCpm.title.present
              ? Value(loadedSheetsDataStore.getSheet(sheetId).title)
              : Value.absent();
          Value<DateTime> lastOpened = currCpm.lastOpened.present
              ? Value(loadedSheetsDataStore.getSheet(sheetId).lastOpened)
              : Value.absent();
          Value<List<int>> usedRows = currCpm.usedRows.present
              ? Value(loadedSheetsDataStore.getSheet(sheetId).usedRows)
              : Value.absent();
          Value<List<int>> usedCols = currCpm.usedCols.present
              ? Value(loadedSheetsDataStore.getSheet(sheetId).usedCols)
              : Value.absent();
          Value<int> historyIndex = currCpm.historyIndex.present
              ? Value(historyCache[sheetId]!.historyIndex)
              : Value.absent();
          Value<double> colHeaderHeight = currCpm.colHeaderHeight.present
              ? Value(layoutCache.getLayout(sheetId).colHeaderHeight)
              : Value.absent();
          Value<double> rowHeaderWidth = currCpm.rowHeaderWidth.present
              ? Value(layoutCache.getLayout(sheetId).rowHeaderWidth)
              : Value.absent();
          Value<int> primarySelectionX = currCpm.primarySelectionX.present
              ? selectionCache.getSelectionState(sheetId).primarySelectionX
              : Value.absent();
          Value<int> primarySelectionY = currCpm.primarySelectionY.present
              ? selectionCache.getSelectionState(sheetId).primarySelectionY
              : Value.absent();
          Value<Set<CellPosition>> selectedCells = currCpm.selectedCells.present
              ? selectionCache.getSelectionState(sheetId).selectedCells
              : Value.absent();
          Value<int> selectionHistoryId = currCpm.selectionHistoryId.present
              ? selectionCache.getSelectionState(sheetId).selectionHistoryId
              : Value.absent();
          Value<double> scrollOffsetX = currCpm.scrollOffsetX.present
              ? selectionCache.getSelectionState(sheetId).scrollOffsetX
              : Value.absent();
          Value<double> scrollOffsetY = currCpm.scrollOffsetY.present
              ? selectionCache.getSelectionState(sheetId).scrollOffsetY
              : Value.absent();
          Value<List<int>> bestSortFound = currCpm.bestSortFound.present
              ? Value(
                  sortProgressCache.getSortProgressData(sheetId).bestSortFound,
                )
              : Value.absent();
          Value<List<int>> bestDistFound = currCpm.bestDistFound.present
              ? Value(
                  sortProgressCache.getSortProgressData(sheetId).bestDistFound,
                )
              : Value.absent();
          Value<List<int>> cursors = currCpm.cursors.present
              ? Value(sortProgressCache.getSortProgressData(sheetId).cursors)
              : Value.absent();
          Value<List<List<int>>> possibleInts = currCpm.possibleInts.present
              ? Value(
                  sortProgressCache
                      .getSortProgressData(sheetId)
                      .possibleIntsById,
                )
              : Value.absent();
          Value<List<List<List<int>>>> validAreas = currCpm.validAreas.present
              ? Value(
                  sortProgressCache.getSortProgressData(sheetId).validAreasById,
                )
              : Value.absent();
          Value<int> sortIndex = currCpm.sortIndex.present
              ? Value(sortProgressCache.getSortProgressData(sheetId).sortIndex)
              : Value.absent();
          Value<AnalysisResult> analysisResult = currCpm.analysisResult.present
              ? Value(analysisResultCache.getAnalysisResult(sheetId))
              : Value.absent();
          Value<bool> sortInProgress = currCpm.sortInProgress.present
              ? Value(sortProgressCache.sortInProgress(sheetId))
              : Value.absent();
          Value<bool> toAlwaysApplyCurrentBestSort =
              currCpm.toAlwaysApplyCurrentBestSort.present
              ? Value(
                  loadedSheetsDataStore
                      .getSheet(sheetId)
                      .toAlwaysApplyCurrentBestSort,
                )
              : Value.absent();
          Value<bool> toApplyNextBestSort = currCpm.toApplyNextBestSort.present
              ? Value(sortStatusCache.getToApplyOnce(sheetId))
              : Value.absent();
          Value<bool> analysisDone = currCpm.analysisDone.present
              ? Value(sortStatusCache.getAnalysisDone(sheetId))
              : Value.absent();
          var newCmp = SheetDataTablesCompanion(
            sheetId: Value(sheetId),
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
          if (true == false) {
            SheetDataEntity(
              sheetId: currCpm.sheetId.present ? sheetId : 0,
              title: title.present ? title.value : '',
              lastOpened: lastOpened.present
                  ? lastOpened.value
                  : DateTime.now(),
              usedRows: usedRows.present ? usedRows.value : [],
              usedCols: usedCols.present ? usedCols.value : [],
              historyIndex: historyIndex.present ? historyIndex.value : 0,
              colHeaderHeight: colHeaderHeight.present
                  ? colHeaderHeight.value
                  : 0,
              rowHeaderWidth: rowHeaderWidth.present ? rowHeaderWidth.value : 0,
              primarySelectionX: primarySelectionX.present
                  ? primarySelectionX.value
                  : 0,
              primarySelectionY: primarySelectionY.present
                  ? primarySelectionY.value
                  : 0,
              selectedCells: selectedCells.present ? selectedCells.value : {},
              selectionHistoryId: selectionHistoryId.present
                  ? selectionHistoryId.value
                  : 0,
              scrollOffsetX: scrollOffsetX.present ? scrollOffsetX.value : 0,
              scrollOffsetY: scrollOffsetY.present ? scrollOffsetY.value : 0,
              bestSortFound: bestSortFound.present ? bestSortFound.value : [],
              bestDistFound: bestDistFound.present ? bestDistFound.value : [],
              cursors: cursors.present ? cursors.value : [],
              possibleInts: possibleInts.present ? possibleInts.value : [],
              validAreas: validAreas.present ? validAreas.value : [],
              sortIndex: sortIndex.present ? sortIndex.value : 0,
              analysisResult: analysisResult.present
                  ? analysisResult.value
                  : AnalysisResult.empty(),
              sortInProgress: sortInProgress.present
                  ? sortInProgress.value
                  : false,
              toAlwaysApplyCurrentBestSort: toAlwaysApplyCurrentBestSort.present
                  ? toAlwaysApplyCurrentBestSort.value
                  : false,
              toApplyNextBestSort: toApplyNextBestSort.present
                  ? toApplyNextBestSort.value
                  : false,
              analysisDone: analysisDone.present ? analysisDone.value : false,
            );
          }
          newCmpWrp = SheetDataWrapper(sheetId, newCmp);
        case HistoryWrapper():
          throw Exception('HistoryWrapper reversal not implemented');
        case SheetCellWrapper():
          final currCpm =
              (update.companionWrapper as SheetCellWrapper).companion;
          final sheetId = currCpm.sheetId;
          final row = currCpm.row;
          final col = currCpm.col;
          Value<String> content = currCpm.content.present
              ? Value(
                  loadedSheetsDataStore.getCellContent(
                    sheetId.value,
                    row.value,
                    col.value,
                  ),
                )
              : Value.absent();
          newCmpWrp = SheetCellWrapper(
            sheetId.value,
            row.value,
            col.value,
            SheetCellsTableCompanion(content: content),
          );
        case RowHeightWrapper():
          final currCpm =
              (update.companionWrapper as RowHeightWrapper).companion;
          final sheetId = currCpm.sheetId;
          final rowIndex = currCpm.rowIndex;
          Value<double> bottomPos = currCpm.bottomPos.present
              ? Value(
                  layoutCache
                      .getLayout(sheetId.value)
                      .rowsBottomPos[rowIndex.value],
                )
              : Value.absent();
          var newCmp = RowsBottomPosTableCompanion(
            sheetId: sheetId,
            rowIndex: rowIndex,
            bottomPos: bottomPos,
          );
          void schemaCheck() {
            RowsBottomPosEntity(
              sheetId: sheetId.value,
              rowIndex: rowIndex.value,
              bottomPos: bottomPos.present ? bottomPos.value : 0,
            );
          }
          if (true == false) {
            schemaCheck();
          }
          newCmpWrp = RowHeightWrapper(newCmp);
        case ColWidthWrapper():
          final currCpm =
              (update.companionWrapper as ColWidthWrapper).companion;
          final sheetId = currCpm.sheetId;
          final colIndex = currCpm.colIndex;
          newCmpWrp = ColWidthWrapper(
            ColRightPosTableCompanion(
              sheetId: sheetId,
              colIndex: colIndex,
              rightPos: Value(
                layoutCache
                    .getLayout(sheetId.value)
                    .colRightPos[colIndex.value],
              ),
            ),
          );
        case RowsManuallyAdjustedHeightWrapper():
          final currCpm =
              (update.companionWrapper as RowsManuallyAdjustedHeightWrapper)
                  .companion;
          final sheetId = currCpm.sheetId;
          final rowIndex = currCpm.rowIndex;
          newCmpWrp = RowsManuallyAdjustedHeightWrapper(
            RowsManuallyAdjustedHeightTableCompanion(
              sheetId: sheetId,
              rowIndex: rowIndex,
              manuallyAdjusted: Value(
                layoutCache
                    .getLayout(sheetId.value)
                    .rowsManuallyAdjusted[rowIndex.value],
              ),
            ),
          );
        case ColsManuallyAdjustedWidthWrapper():
          final currCpm =
              (update.companionWrapper as ColsManuallyAdjustedWidthWrapper)
                  .companion;
          final sheetId = currCpm.sheetId;
          final colIndex = currCpm.colIndex;
          newCmpWrp = ColsManuallyAdjustedWidthWrapper(
            ColsManuallyAdjustedWidthTableCompanion(
              sheetId: sheetId,
              colIndex: colIndex,
              manuallyAdjusted: Value(
                layoutCache
                    .getLayout(sheetId.value)
                    .colsManuallyAdjusted[colIndex.value],
              ),
            ),
          );
      }
      reversedUpdates.add(
        SyncRequestWithoutHist(newCmpWrp, dataBaseOperationType),
      );
    }
    return reversedUpdates;
  }

  @override
  void scheduleCommit() {
    if (commitScheduled) {
      return;
    }
    commitScheduled = true;
    scheduleMicrotask(() {
      commitHistory();
      commitScheduled = false;
    });
  }

  void commitHistory() {
    List<SyncRequestWithoutHist> changeList = [];
    final timestamp = Value(DateTime.now());
    final chronoId = Value(chronoIdCounter++);
    for (int sheetId in currentChangeList.changes.keys) {
      final sheetChange = currentChangeList.changes[sheetId]!;
      for (HistoryType historyType in HistoryType.values) {
        final currentChanges = sheetChange[historyType];
        if (currentChanges == null || currentChanges.isEmpty) {
          continue;
        }
        final historyReq = SyncRequestWithoutHist(
          HistoryWrapper(
            UpdateHistoriesTableCompanion(
              timestamp: timestamp,
              chronoId: chronoId,
              sheetId: Value(sheetId),
              updates: Value(currentChanges),
              type: Value(historyType),
            ),
          ),
          DataBaseOperationType.insert,
        );
        changeList.add(historyReq);
        changeList.addAll(currentChanges);

        final historyCenter = historyType == HistoryType.selectionChange
            ? selectionHistoryData
            : historyData;

        if (historyCenter.historyIndex <
            historyCenter.updateHistories.length - 1) {
          for (
            int i = historyCenter.historyIndex + 1;
            i < historyCenter.updateHistories.length;
            i++
          ) {
            changeList.add(
              SyncRequestWithoutHist(
                HistoryWrapper(
                  UpdateHistoriesTableCompanion(
                    timestamp: Value(
                      historyCenter.updateHistories[i].timestamp,
                    ),
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
          UpdateHistoryModel(
            timestamp: (historyReq.companionWrapper.companion as UpdateHistoriesTableCompanion).timestamp.value,
            chronoId: (historyReq.companionWrapper.companion as UpdateHistoriesTableCompanion).chronoId.value,
            sheetId: sheetId,
            updates: currentChanges,
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
              sheetId,
              SheetDataTablesCompanion(
                historyIndex: Value(historyCenter.historyIndex),
              ),
            ),
            DataBaseOperationType.update,
          ),
        );
      }
    }
    localDataSource.save(changeList);
    currentChangeList.clear();
  }

  @override
  void addSheetId(int sheetId) {
    final historyData = HistoryData.empty();
    historyCache.setUpdateHistories(sheetId, historyData);
  }
}
