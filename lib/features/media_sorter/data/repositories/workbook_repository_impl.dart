import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/utils_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sort_status_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';

class WorkbookRepositoryImpl implements WorkbookRepository {
  final FileSheetLocalDataSource fileSheetLocalDataSource;

  final LoadedSheetsCache loadedSheetsCache;
  final SelectionCache selectionCache;
  final SortStatusCache sortStatusCache;
  final WorkbookCache workbookCache;

  late ManageWaitingTasks<void> _saveRecentSheetIdsExecutor;
  late StreamController<Failure> _failureStreamController;
  @override
  String get currentSheetId => workbookCache.currentSheetId;

  WorkbookRepositoryImpl(
    this.fileSheetLocalDataSource,
    this.loadedSheetsCache,
    this.selectionCache,
    this.sortStatusCache,
    this.workbookCache,
  ) {
    _failureStreamController = StreamController<Failure>.broadcast();
    _saveRecentSheetIdsExecutor = ManageWaitingTasks<void>(
      Duration(seconds: 2),
      _failureStreamController,
    );
  }

  void dispose() {
    _saveRecentSheetIdsExecutor.dispose();
    _failureStreamController.close();
  }

  @override
  bool containsSheetId(String sheetId) {
    return workbookCache.containsSheetId(sheetId);
  }

  @override
  List<String> getRecentSheetIds() {
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
  void addNewSheetId(String sheetId, int index) {
    workbookCache.addSheetId(sheetId, index);
    _saveRecentSheetIdsExecutor.execute(() async {
      await fileSheetLocalDataSource.saveRecentSheetIds(
        workbookCache.getRecentSheetIds(),
      );
    });
  }

  @override
  Future<Either<Failure, void>> loadRecentSheetIds() async {
    final result = await UtilsService.handleDataSourceCall(
      () => fileSheetLocalDataSource.recentSheetIds(),
    );

    return result.fold((failure) => Left(failure), (ids) {
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
      return changed
          ? Left(CacheRepairedFailure(workbookCacheChanged: changed))
          : Right(null);
    });
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
