import 'dart:async';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/i_file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/data/services/workbook_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/utils/logger.dart';

class SelectionRepositoryImpl implements SelectionRepository {
  final ManageWaitingTasks<void> _saveSelectionStatusExecutor =
      ManageWaitingTasks<void>(Duration(milliseconds: 2000));
  final FileSheetLocalDataSource saveDataSource;
  final SelectionCache selectionCache;
  final LoadedSheetsCache loadedSheetsCache;

  @override
  Stream<String> get updateData => selectionCache.updateData;

  SelectionRepositoryImpl(this.saveDataSource, this.selectionCache, this.loadedSheetsCache);

  @override
  Future<Either<CacheFailure, void>> saveLastSelection() async {
    try {
      await saveDataSource.saveLastSelection(selectionCache.selection);
      return Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  @override
  Future<Either<Failure, void>> saveAllLastSelected() async {
    try {
      await saveDataSource.saveAllLastSelected(selectionCache.lastSelectionBySheet);
      return Right(null);
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e.e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  void _completeMissing() {
    for (var sheetId in loadedSheetsCache.recentSheetIds) {
      if (!selectionCache.lastSelectionBySheet.containsKey(sheetId)) {
        selectionCache.setNewSelectionData(sheetId);
        logger.e("No last selection saved for sheet $sheetId");
      }
    }
  }

  @override
  void init() {
    // --- get last selection by sheet ---
    _completeMissing();
    for (var name in selectionCache.lastSelectionBySheet.keys.toList()) {
      if (!WorkbookService.isValidSheetName(name)) {
        logger.e(
          "Last selection found for sheet '$name' which is not in sheet names list, removing it.",
        );
        selectionCache.lastSelectionBySheet.remove(name);
      } else if (!loadedSheetsCache.recentSheetIds.contains(name)) {
        loadedSheetsCache.recentSheetIds.add(name);
        logger.e("No sheet data saved for selection of sheet $name");
      }
    }
  }

  @override
  Future<void> loadLastSelection() async {
    try {
      SelectionData? selectionData = await saveDataSource.getLastSelection();
    } catch (e) {
      _failureController.add(Failure(e));
      return;
    }
    selectionCache.setSelectionData(loadedSheetsCache.currentSheetId, selectionData, false);
  }

  @override
  Future<Either<Failure, void>> getAllLastSelected() async {
    try {
      Map<String, SelectionData> lastSelected = await saveDataSource.getAllLastSelected();
      selectionCache.setLastSelectionBySheet(lastSelected, false);
      return Right(null);
    } on FileNotFoundException catch (e) {
      return Left(FileNotFoundFailure(e.e));
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e.e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }
}
