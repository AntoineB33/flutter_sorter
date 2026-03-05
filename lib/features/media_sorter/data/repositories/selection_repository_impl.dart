import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/services/workbook_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/utils/logger.dart';

class SelectionRepositoryImpl implements SelectionRepository {
  final FileSheetLocalDataSource saveDataSource;
  final SelectionCache selectionDataStore;
  final LoadedSheetsCache loadedSheetsDataStore;

  @override
  Stream<String> get updateData => selectionDataStore.updateData;

  SelectionRepositoryImpl(this.saveDataSource, this.selectionDataStore, this.loadedSheetsDataStore);

  @override
  Future<Either<CacheFailure, void>> saveLastSelection() async {
    try {
      await saveDataSource.saveLastSelection(selectionDataStore.selection);
      return Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  @override
  Future<Either<Failure, void>> saveAllLastSelected() async {
    try {
      await saveDataSource.saveAllLastSelected(selectionDataStore.lastSelectionBySheet);
      return Right(null);
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e.e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  void _completeMissing() {
    for (var sheetId in loadedSheetsDataStore.recentSheetIds) {
      if (!selectionDataStore.lastSelectionBySheet.containsKey(sheetId)) {
        selectionDataStore.setNewSelectionData(sheetId);
        logger.e("No last selection saved for sheet $sheetId");
      }
    }
  }

  @override
  void init() {
    // --- get last selection by sheet ---
    _completeMissing();
    for (var name in selectionDataStore.lastSelectionBySheet.keys.toList()) {
      if (!WorkbookService.isValidSheetName(name)) {
        logger.e(
          "Last selection found for sheet '$name' which is not in sheet names list, removing it.",
        );
        selectionDataStore.lastSelectionBySheet.remove(name);
      } else if (!loadedSheetsDataStore.recentSheetIds.contains(name)) {
        loadedSheetsDataStore.recentSheetIds.add(name);
        logger.e("No sheet data saved for selection of sheet $name");
      }
    }
  }
}
