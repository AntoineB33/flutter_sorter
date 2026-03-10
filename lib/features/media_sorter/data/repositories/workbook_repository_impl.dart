import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/data/services/utils_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sort_status_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';
import 'package:trying_flutter/utils/logger.dart';

class WorkbookRepositoryImpl implements WorkbookRepository {
  final FileSheetLocalDataSource fileSheetLocalDataSource;

  final LoadedSheetsCache loadedSheetsCache;
  final SelectionCache selectionCache;
  final SortStatusCache sortStatusCache;
  
  final ManageWaitingTasks<void> _saveRecentSheetIdsExecutor =
      ManageWaitingTasks<void>(Duration(seconds: 2000));

  WorkbookRepositoryImpl(
    this.fileSheetLocalDataSource,
    this.loadedSheetsCache,
    this.selectionCache,
    this.sortStatusCache,
  );

  @override
  bool containsSheetId(String sheetId) {
    return loadedSheetsCache.containsSheetId(sheetId);
  }

  @override
  List<String> getRecentSheetIds() {
    return loadedSheetsCache.getRecentSheetIds();
  }

  @override
  Future<Either<Failure, void>> clearAllData() async {
    final result = await UrilsService.handleDataSourceCall(
      () => fileSheetLocalDataSource.clearAllData(),
    );
    return result.fold((failure) => Left(failure), (_) => Right(null));
  }

  @override
  Future<Either<Failure, void>> loadRecentSheetIds() async {
    final result = await UrilsService.handleDataSourceCall(
      () => fileSheetLocalDataSource.recentSheetIds(),
    );

    return result.fold((failure) => Left(failure), (ids) {
      loadedSheetsCache.setRecentIds(ids);
      bool changed = false;
      int offset = 0;
      for (int i = 0; i < loadedSheetsCache.getRecentSheetIds().length; i++) {
        if (!UrilsService.isValidSheetName(
          loadedSheetsCache.getRecentSheetIds()[i - offset],
        )) {
          loadedSheetsCache.removeSheet(i - offset);
          offset++;
          changed = true;
        }
      }
      return changed ? Left(CacheRepairedFailure()) : Right(null);
    });
  }

  @override
  void saveRecentSheetIds() {
    _saveRecentSheetIdsExecutor.execute(() async {
      await fileSheetLocalDataSource.saveRecentSheetIds(loadedSheetsCache.getRecentSheetIds());
    });
  }
}
