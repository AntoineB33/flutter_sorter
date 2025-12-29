import 'package:get_it/get_it.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/parse_paste_data_usecase.dart';
// Import your new controllers
import 'features/media_sorter/presentation/controllers/spreadsheet_data_controller.dart';
import 'features/media_sorter/presentation/controllers/spreadsheet_selection_controller.dart';
import 'features/media_sorter/presentation/controllers/analysis_controller.dart';
// Keep your existing imports (UseCases, Repositories, DataSources)

final sl = GetIt.instance;

Future<void> init() async {

  // --- Data Layer ---
  sl.registerLazySingleton(() => FileSheetLocalDataSource());
  sl.registerLazySingleton<SheetRepository>(
    () => SheetRepositoryImpl(sl()), // Auto-injects DataSource
  );

  // --- Domain Layer ---
  sl.registerLazySingleton(() => GetSheetDataUseCase(sl()));
  sl.registerLazySingleton(() => SaveSheetDataUseCase(sl()));
  sl.registerLazySingleton(() => ParsePasteDataUseCase()); 

  // --- Presentation (Controllers) ---
  
  // 1. SpreadsheetDataController
  // Needs: GetSheetDataUseCase, SaveSheetDataUseCase, ParsePasteDataUseCase
  sl.registerFactory(
    () => SpreadsheetDataController(
      getDataUseCase: sl(),
      saveSheetDataUseCase: sl(),
      parsePasteDataUseCase: sl(),
    ),
  );

  // 2. SpreadsheetSelectionController
  // Needs: SaveSheetDataUseCase, GetSheetDataUseCase
  // Note: We do NOT inject SpreadsheetDataController here directly via SL.
  // It is passed via the UI ProxyProvider, so we only inject the UseCases here.
  sl.registerFactory(
    () => SpreadsheetSelectionController(
      saveSheetDataUseCase: sl(),
      getDataUseCase: sl(),
    ),
  );

  // 3. AnalysisController
  // Needs: None from SL (it mostly uses internal logic + Data/Selection passed from UI)
  // If it needs UseCases later, inject them here.
  sl.registerFactory(
    () => AnalysisController(),
  );
}