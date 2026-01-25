import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/spreadsheet_controller.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  final GetSheetDataUseCase getDataUseCase = GetSheetDataUseCase(
    SheetRepositoryImpl(FileSheetLocalDataSource()),
  );
  sl.registerLazySingleton(
    () => SheetDataController(
      getDataUseCase: getDataUseCase,
      saveSheetDataUseCase: SaveSheetDataUseCase(
        SheetRepositoryImpl(FileSheetLocalDataSource()),
      ),
    ),
  );
  sl.registerLazySingleton(() => SelectionController());
  sl.registerFactory(
    () => SpreadsheetController(
      GridController(),
      HistoryController(),
      sl<SelectionController>(),
      sl<SheetDataController>(),
      TreeController(),
      SpreadsheetStreamController(),
    ),
  );
}
