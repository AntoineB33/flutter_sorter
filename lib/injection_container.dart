import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trying_flutter/features/media_sorter/data/models/cell_model.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/local_spreadsheet_service.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/spreadsheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/spreadsheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/parse_paste_data_usecase.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // --- External ---
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([CellModelSchema], directory: dir.path);
  sl.registerLazySingleton(() => isar);

  // --- Data Layer ---
  sl.registerLazySingleton(() => TableLocalDataSource(sl())); // Auto-injects Isar
  sl.registerLazySingleton<SpreadsheetRepository>(
    () => SpreadsheetRepositoryImpl(sl()), // Auto-injects DataSource
  );

  // --- Domain Layer ---
  sl.registerLazySingleton(() => GetSheetDataUseCase(sl()));
  sl.registerLazySingleton(() => SaveCellUseCase(sl()));
  sl.registerLazySingleton(() => ParsePasteDataUseCase());

  // --- Presentation Layer ---
  // Factory means "create a new instance every time I ask"
  sl.registerFactory(() => SpreadsheetController(getDataUseCase: sl(), saveCellUseCase: sl(), parsePasteDataUseCase: sl()));
}