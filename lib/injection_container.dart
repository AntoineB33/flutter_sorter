import 'package:get_it/get_it.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';

final sl = GetIt.instance; // sl = Service Locator

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

  // --- Presentation Layer ---
  // Factory means "create a new instance every time I ask"
  sl.registerFactory(
    () => SpreadsheetController(
      getDataUseCase: sl(),
      saveSheetDataUseCase: sl(),
      parsePasteDataUseCase: sl(),
    ),
  );
  sl.registerFactory(() => TreeController(sl()));
}
