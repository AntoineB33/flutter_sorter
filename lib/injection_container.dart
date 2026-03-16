import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/i_file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/grid_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/history_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/selection_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_data_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sort_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/workbook_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/data/store/isolate_receive_ports_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sorting_progress_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/workbook_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/workbook_controller.dart';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sort_status_cache.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  IsolateReceivePortsCache isolateReceivePortsCache = IsolateReceivePortsCache();

  IFileSheetLocalDataSource saveDataSource = FileSheetLocalDataSource(sharedPreferences);

  LoadedSheetsCache loadedSheetsCache = LoadedSheetsCache();
  SortStatusCache sortStatusCache = SortStatusCache(loadedSheetsCache);
  AnalysisResultCache analysisResultCache = AnalysisResultCache(
    loadedSheetsCache,
  );
  SelectionCache selectionCache = SelectionCache();
  WorkbookCache workbookCache = WorkbookCache();
  SortProgressCache sortProgressCache = SortProgressCache();

  SheetDataRepositoryImpl sheetDataRepository = SheetDataRepositoryImpl(
    loadedSheetsCache,
    selectionCache,
    workbookCache,
    saveDataSource,
  );
  SortRepositoryImpl sortRepository = SortRepositoryImpl(
    analysisResultCache,
    loadedSheetsCache,
    sortProgressCache,
    sortStatusCache,
    isolateReceivePortsCache,
    saveDataSource,
    selectionCache,
    workbookCache,
  );
  GridRepositoryImpl gridRepository = GridRepositoryImpl(
    loadedSheetsCache,
    workbookCache,
    selectionCache,
  );
  HistoryRepositoryImpl historyRepository = HistoryRepositoryImpl(
    loadedSheetsCache,
    workbookCache,
    selectionCache,
  );
  WorkbookRepositoryImpl workbookRepository = WorkbookRepositoryImpl(
    saveDataSource,
    loadedSheetsCache,
    selectionCache,
    sortStatusCache,
    workbookCache,
  );
  SelectionRepositoryImpl selectionRepository = SelectionRepositoryImpl(
    saveDataSource,
    selectionCache,
    loadedSheetsCache,
    workbookCache,
  );

  SheetDataUsecase getDataUseCase = SheetDataUsecase(
    sheetDataRepository: SheetDataRepositoryImpl(
      loadedSheetsCache,
      selectionCache,
      workbookCache,
      saveDataSource,
    ),
    sortRepository: sortRepository,
    gridRepository: gridRepository,
    historyRepository: historyRepository,
  );
  SheetDataUsecase sheetDataUseCase = SheetDataUsecase(
    sheetDataRepository: SheetDataRepositoryImpl(
      loadedSheetsCache,
      selectionCache,
      workbookCache,
      saveDataSource,
    ),
    sortRepository: sortRepository,
    gridRepository: gridRepository,
    historyRepository: historyRepository,
  );
  SortUsecase sortUsecase = SortUsecase(
    sortRepository,
    sheetDataRepository,
    workbookRepository,
    selectionRepository,
  );
  WorkbookUsecase workbookUsecase = WorkbookUsecase(workbookRepository, selectionRepository, sortRepository, sheetDataRepository);

  SortController sortController = SortController(
    sheetDataUseCase,
    sortUsecase,
    workbookUsecase,
  );

  sl.registerFactory<SortController>(() => sortController);
}
