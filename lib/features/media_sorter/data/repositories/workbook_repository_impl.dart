import 'dart:async';

import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/local_data_source.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sort_status_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';

class WorkbookRepositoryImpl implements WorkbookRepository {
  final ILocalDataSource fileSheetLocalDataSource;

  final LoadedSheetsCache loadedSheetsCache;
  final SelectionCache selectionCache;
  final SortStatusCache sortStatusCache;
  final WorkbookCache workbookCache;

  @override
  int get currentSheetId => workbookCache.currentSheetId;
  @override
  String get currentSheetName => loadedSheetsCache.getTitle(currentSheetId);

  WorkbookRepositoryImpl(
    this.fileSheetLocalDataSource,
    this.loadedSheetsCache,
    this.selectionCache,
    this.sortStatusCache,
    this.workbookCache,
  );

  int _getNewSheetId() {
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
  Future<Either<Failure, Unit>> clearAllData() async {
    try {
      await fileSheetLocalDataSource.clearAllData();
      return Right(unit);
    } on CacheException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  List<SyncRequestWithHist> addNewSheetId(int index) {
    int newSheetId = _getNewSheetId();
    workbookCache.addSheetId(newSheetId, index);
    final companionWrapper = SheetDataWrapper(
      SheetDataTablesCompanion(sheetId: Value(newSheetId)),
    );
    return [
      SyncRequestWithHist(
        companionWrapper,
        companionWrapper,
        DataBaseOperationType.insert,
      ),
    ];
  }

  @override
  Future<Either<Failure, Unit>> loadRecentSheetIds() async {
    try {
      final recentSheetIds = await fileSheetLocalDataSource
          .getSheetIdAndLastOpened();
      final sortedSheetIds =
          (recentSheetIds.toList()
                ..sort((a, b) => b.lastOpened.compareTo(a.lastOpened)))
              .map((e) => e.sheetId)
              .toList();
      workbookCache.setRecentIds(sortedSheetIds);
      return Right(unit);
    } on CacheException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}
