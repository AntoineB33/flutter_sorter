import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sort_status_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';
import 'package:uuid/uuid.dart';

class WorkbookRepositoryImpl implements WorkbookRepository {
  final LoadedSheetsCache loadedSheetsCache;
  final SelectionCache selectionCache;
  final SortStatusCache sortStatusCache;
  final WorkbookCache workbookCache;

  @override
  int get currentSheetId => workbookCache.currentSheetId;
  @override
  String get currentSheetName => loadedSheetsCache.getTitle(currentSheetId);

  WorkbookRepositoryImpl(
    this.loadedSheetsCache,
    this.selectionCache,
    this.sortStatusCache,
    this.workbookCache,
  );

  @override
  bool containsSheetId(int sheetId) {
    return workbookCache.containsSheetId(sheetId);
  }

  @override
  int getNewSheetId() {
    int newId = DateTime.now().millisecondsSinceEpoch;
    while (workbookCache.containsSheetId(newId)) {
      newId += 1; // Increment until we find a unique ID
    }
    return newId;
  }

  @override
  List<int> getRecentSheetIds() {
    return workbookCache.getRecentSheetIds();
  }

  @override
  Future<Either<Failure, void>> clearAllData() async {
    final result = await UtilsService.handleDataSourceCall(
      () => fileSheetLocalDataSource.clearAllData(),
    );
    return result.fold((failure) => Left(failure), (_) => Right(null));
  }

  @override
  void addNewSheetId(int sheetId, int index) {
    workbookCache.addSheetId(sheetId, index);
  }

  @override
  Future<Either<Failure, void>> loadRecentSheetIds() async {
    final result = await UtilsService.handleDataSourceCall(
      () => fileSheetLocalDataSource.recentSheetIds(),
    );

    return result.fold(
      (failure) {
        // generate sheet id :
        workbookCache.setRecentIds([Uuid().v4()]);
        return Left(failure);
      },
      (ids) {
        workbookCache.setRecentIds(ids);
        bool changed = false;
        int offset = 0;
        for (int i = 0; i < workbookCache.getRecentSheetIds().length; i++) {
          if (!UtilsService.isValidSheetName(
            workbookCache.getRecentSheetIds()[i - offset],
          )) {
            workbookCache.removeSheet(i - offset);
            offset++;
            changed = true;
          }
        }
        if (changed) {
          saveRecentSheetIds();
          return Left(CacheRepairedFailure(workbookCacheChanged: true));
        }
        return Right(null);
      },
    );
  }

  @override
  void saveRecentSheetIds() {
    _saveRecentSheetIdsExecutor.execute(() async {
      await fileSheetLocalDataSource.saveRecentSheetIds(
        workbookCache.getRecentSheetIds(),
      );
    });
  }
}
