import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/workbook_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/delegates/spreadsheet_keyboard_delegate.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  sl.registerLazySingleton<TreeController>(() => TreeController());
  sl.registerLazySingleton<SortController>(() => SortController());
  sl.registerLazySingleton(
    () => WorkbookController(
      GridController(),
      HistoryController(),
      SelectionController(),
      SheetDataController(
        saveSheetDataUseCase: SaveSheetDataUseCase(
          SheetRepositoryImpl(FileSheetLocalDataSource()),
        ),
      ),
      sl<TreeController>(),
      SpreadsheetStreamController(),
      sl<SortController>(),
      SpreadsheetKeyboardDelegate(),
    ),
  );
}
