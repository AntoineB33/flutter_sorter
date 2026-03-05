import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_data/sheet_save_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/workbook_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/managers/spreadsheet_keyboard_delegate.dart';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sort_status_cache.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  final GetSheetDataUseCase getDataUseCase = GetSheetDataUseCase(
    SheetSaveRepositoryImpl(FileSheetLocalDataSource()),
  );
  final SaveSheetDataUseCase saveSheetDataUseCase = SaveSheetDataUseCase(
    SheetSaveRepositoryImpl(FileSheetLocalDataSource()),
  );
  LoadedSheetsCache loadedSheetsDataStore = LoadedSheetsCache();
  SortStatusCache sortStatusDataStore = SortStatusCache(loadedSheetsDataStore);
  AnalysisResultCache analysisDataStore = AnalysisResultCache(
    loadedSheetsDataStore,
  );
  sl.registerFactory<SortController>(
    () => SortController(
      getDataUseCase,
      saveSheetDataUseCase,
      sortStatusDataStore,
      loadedSheetsDataStore,
      analysisDataStore,
    ),
  );
}
