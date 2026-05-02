import 'package:drift/drift.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/data/store/current_change_list.dart';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/layout_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sort_status_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sorting_progress_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/data/store/history_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
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
  void moveInUpdateHistory(
    HistoryType historyType,
    int direction,
  ) {
    int newHistoryIndex = historyData.historyIndex + direction;
    if (newHistoryIndex + direction < 0 ||
        newHistoryIndex + direction >= historyData.updateHistories.length) {
      currentChangeList.changeList = [];
      return;
    }
    var updateData = historyData.updateHistories[newHistoryIndex];
    if (historyType == HistoryType.editModeChange &&
        updateData.historyType != HistoryType.editModeChange) {
      currentChangeList.changeList = [];
      return;
    }
    if (historyType == HistoryType.other) {
      while (updateData.historyType == HistoryType.editModeChange) {
        newHistoryIndex += direction;
        if (newHistoryIndex + direction < 0 ||
            newHistoryIndex + direction >= historyData.updateHistories.length) {
          currentChangeList.changeList = [];
          return;
        }
      }
    }
    updateData = historyData.updateHistories[newHistoryIndex];
    historyData.historyIndex = newHistoryIndex;
    currentChangeList.changeList = updateData.changeSet;
  }

  List<SyncRequestWithoutHist> _removeLastHistoryBcEdit() {
    final lastUpdateData = historyData.updateHistories.last.changeSet.first;
    final lastUpdateCompanion =
        lastUpdateData.companionWrapper as UpdateHistoriesTableCompanion;
    List<SyncRequestWithoutHist> changeList = [];
    changeList.add(
      SyncRequestWithoutHist(
        HistoryWrapper(
          UpdateHistoriesTableCompanion(
            timestamp: Value(lastUpdateCompanion.timestamp.value),
            chronoId: Value(lastUpdateCompanion.chronoId.value),
            sheetId: Value(currentSheetId),
          ),
        ),
        DataBaseOperationType.delete,
      ),
    );
    historyData.updateHistories.removeAt(historyData.historyIndex);
    historyData.historyIndex--;
    changeList.add(
      SyncRequestWithoutHist(
        SheetDataWrapper(
          SheetDataTablesCompanion(
            sheetId: Value(currentSheetId),
            historyIndex: Value(historyData.historyIndex),
          ),
        ),
        DataBaseOperationType.update,
      ),
    );
    return changeList;
  }

  /* Updates the history cache and returns the changeList without the history 
  information and with the history requests
  */
  @override
  List<SyncRequestWithoutHist> commitHistory(
    List<SyncRequestWithHist> updatesI,
    int sheetId,
    HistoryType historyType,
    bool sameHistIdFromLast,
  ) {
    final updates = updatesI.map((e) => e as SyncRequestWithHist).toList();
    List<SyncRequestWithoutHist> historyChangeList = updates.map((update) {
      final DataBaseOperationType histOper =
          switch (update.dataBaseOperationType) {
            DataBaseOperationType.insert => DataBaseOperationType.delete,
            DataBaseOperationType.delete => DataBaseOperationType.insert,
            DataBaseOperationType.update => DataBaseOperationType.update,
            DataBaseOperationType.deleteWhere => DataBaseOperationType.insert,
          };
      return SyncRequestWithoutHist(update.historyCompW, histOper);
    }).toList();
    final updateData = updates.map((update) {
      return update.toSyncRequest();
    }).toList();

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
          updates: Value(historyChangeList),
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
                timestamp: Value(
                  historyCenter.updateHistories[i].timestamp.timestamp.value,
                ),
                chronoId: Value(
                  historyCenter.updateHistories[i].timestamp.chronoId.value,
                ),
                sheetId: Value(sheetId),
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
      HistoryUnit(
        changeSet: updateData,
        timestamp: historyReq.companionWrapper as UpdateHistoriesTableCompanion,
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
              timestamp: Value(
                historyCenter.updateHistories[0].timestamp.timestamp.value,
              ),
              chronoId: Value(
                historyCenter.updateHistories[0].timestamp.chronoId.value,
              ),
              sheetId: Value(sheetId),
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
    return changeList;
  }

  @override
  changeList addSheetId(int sheetId) {
    final historyData = HistoryData.empty(chronoIdCounter++);
    historyCache.setUpdateHistories(sheetId, historyData);
    final changeList = changeList();
    changeList.addUpdate(
      SheetDataUpdate(sheetId, true, historyIndex: historyData.historyIndex),
    );
    return changeList;
  }

  @override
  changeList stopEditing(bool escape) {
    changeList changeList = changeList();
    if (escape && isLastChangeInSameEditingMode) {
      changeList = _removeLastHistoryBcEdit();
    }
    isLastChangeInSameEditingMode = false;
    return changeList;
  }
}
