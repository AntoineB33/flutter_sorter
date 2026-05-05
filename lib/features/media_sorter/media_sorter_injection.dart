import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:trying_flutter/features/media_sorter/application/coordinators/spreadsheet_coordinator.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/local_data_source.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/grid_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/history_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/selection_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_data_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sort_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/tree_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/workbook_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/data/store/current_change_list.dart';
import 'package:trying_flutter/features/media_sorter/data/store/history_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/isolate_receive_ports_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/layout_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sorting_progress_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/grid_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/history_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/selection_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/tree_usecase.dart';
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

final slMediaSorter = GetIt.instance; // sl = Service Locator

Future<void> initMediaSorterDependencies() async {
  IsolateReceivePortsCache isolateReceivePortsCache =
      IsolateReceivePortsCache();

  AppDatabase database = AppDatabase();


  DriftLocalDataSource saveDataSource = DriftLocalDataSource(database);

  LoadedSheetsCache loadedSheetsCache = LoadedSheetsCache();
  SortStatusCache sortStatusCache = SortStatusCache(loadedSheetsCache);
  AnalysisResultCache analysisResultCache = AnalysisResultCache(
    loadedSheetsCache,
  );
  SelectionCache selectionCache = SelectionCache();
  LayoutCache layoutCache = LayoutCache();
  WorkbookCache workbookCache = WorkbookCache();
  SortProgressCache sortProgressCache = SortProgressCache();
  HistoryCache historyCache = HistoryCache();
  CurrentChangeList currentChangeList = CurrentChangeList();

  SheetDataRepositoryImpl sheetDataRepository = SheetDataRepositoryImpl(
    saveDataSource,
    loadedSheetsCache,
    selectionCache,
    sortProgressCache,
    analysisResultCache,
    workbookCache,
    layoutCache,
    historyCache,
    currentChangeList,
  );
  SortRepositoryImpl sortRepository = SortRepositoryImpl(
    saveDataSource,
    analysisResultCache,
    loadedSheetsCache,
    sortProgressCache,
    sortStatusCache,
    isolateReceivePortsCache,
    selectionCache,
    workbookCache,
    currentChangeList,
  );
  GridRepositoryImpl gridRepository = GridRepositoryImpl(
    loadedSheetsCache,
    workbookCache,
    selectionCache,
    layoutCache,
    currentChangeList,
  );
  HistoryRepositoryImpl historyRepository = HistoryRepositoryImpl(
    saveDataSource,
    loadedSheetsCache,
    workbookCache,
    selectionCache,
    historyCache,
    layoutCache,
    sortStatusCache,
    sortProgressCache,
    analysisResultCache,
    currentChangeList,
  );
  SortRepositoryImpl saveRepository = SortRepositoryImpl(
    saveDataSource,
    analysisResultCache,
    loadedSheetsCache,
    sortProgressCache,
    sortStatusCache,
      isolateReceivePortsCache,
    selectionCache,
    workbookCache,
    currentChangeList,
  );
  WorkbookRepositoryImpl workbookRepository = WorkbookRepositoryImpl(
    saveDataSource,
    loadedSheetsCache,
    selectionCache,
    sortStatusCache,
    workbookCache,
      currentChangeList
  );
  SelectionRepositoryImpl selectionRepository = SelectionRepositoryImpl(
    selectionCache,
    loadedSheetsCache,
    workbookCache,
    currentChangeList,
  );
  TreeRepositoryImpl treeRepository = TreeRepositoryImpl(
    analysisResultCache,
    loadedSheetsCache,
    selectionCache,
    sortStatusCache,
    workbookCache,
  );

  SortUsecase sortUsecase = SortUsecase(
    saveRepository,
    sheetDataRepository,
    workbookRepository,
    selectionRepository,
    historyRepository,
  );
  WorkbookUsecase workbookUsecase = WorkbookUsecase(
    workbookRepository,
    loadedSheetsCache,
    selectionRepository,
    sortRepository,
    sheetDataRepository,
    gridRepository,
    historyRepository,
  );
  HistoryUsecase historyUsecase = HistoryUsecase(
    historyRepository,
  );
  GridUsecase gridUsecase = GridUsecase(
    gridRepository,
    treeRepository,
    historyRepository,
  );
  SelectionUsecase selectionUsecase = SelectionUsecase(
    selectionRepository,
    sheetDataRepository,
    gridRepository,
    historyRepository,
    workbookRepository,
  );
  TreeUsecase treeUsecase = TreeUsecase(treeRepository);
  SheetDataUsecase sheetDataUsecase = SheetDataUsecase(
    sheetDataRepository,
    sortRepository,
    gridRepository,
    selectionRepository,
    historyRepository,
    workbookRepository,
  );

  SortController sortController = SortController(
    sheetDataUsecase,
    sortUsecase,
    workbookUsecase,
  );
  HistoryController historyController = HistoryController(historyUsecase);
  SheetDataController sheetDataController = SheetDataController(
    sheetDataUsecase,
    workbookUsecase,
  );
  GridController gridController = GridController(
    sheetDataUsecase,
    gridUsecase,
    workbookUsecase,
    selectionUsecase,
  );
  SelectionController selectionController = SelectionController(
    selectionUsecase,
    sortUsecase,
    historyUsecase,
    workbookUsecase,
    sheetDataUsecase,
  );
  WorkbookController workbookController = WorkbookController(
    workbookUsecase,
    sortUsecase,
  );
  TreeController treeController = TreeController(treeUsecase, selectionUsecase);

  SpreadsheetCoordinator spreadsheetCoordinator = SpreadsheetCoordinator(
    historyController,
    sheetDataController,
    gridController,
    sortController,
    selectionController,
    workbookController,
    treeController,
  );

  slMediaSorter.registerLazySingleton<SpreadsheetCoordinator>(
    () => spreadsheetCoordinator,
  );
  slMediaSorter.registerLazySingleton<WorkbookController>(
    () => workbookController,
  );
  slMediaSorter.registerLazySingleton<SheetDataController>(
    () => sheetDataController,
  );
  slMediaSorter.registerLazySingleton<GridController>(() => gridController);
  slMediaSorter.registerLazySingleton<TreeController>(() => treeController);
  slMediaSorter.registerLazySingleton<SelectionController>(
    () => selectionController,
  );
  slMediaSorter.registerLazySingleton<SortController>(() => sortController);
  slMediaSorter.registerLazySingleton<HistoryController>(
    () => historyController,
  );
  slMediaSorter.registerLazySingleton<SheetDataUsecase>(() => sheetDataUsecase);

  slMediaSorter.registerLazySingleton<DriftLocalDataSource>(
    () => saveDataSource,
    dispose: (repo) => repo.dispose(),
  );
  slMediaSorter.registerLazySingleton<SelectionRepositoryImpl>(
    () => selectionRepository,
  );
  slMediaSorter.registerLazySingleton<SheetDataRepositoryImpl>(
    () => sheetDataRepository,
  );
  slMediaSorter.registerLazySingleton<SortRepositoryImpl>(() => sortRepository);
}
