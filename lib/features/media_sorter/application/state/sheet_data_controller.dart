import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/helpers/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/data/services/spreadsheet_clipboard_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:uuid/uuid.dart';

class SheetDataController extends ChangeNotifier {
  final SheetDataUsecase sheetDataUsecase;

  SheetDataController(this.sheetDataUsecase);

  Future<Either<Failure, List<CellUpdate>>> paste() {
    return sheetDataUsecase.paste();
  }

  Future<void> copyToClipboard() {
    return sheetDataUsecase.copyToClipboard();
  }

  bool isLoaded(String sheetId) {
    return sheetDataUsecase.containsSheetId(sheetId);
  }

  String getCellContent(int row, int col, String sheetId) {
    return sheetDataUsecase.getCellContent(row, col, sheetId);
  }

  List<CellUpdate> delete() {
    return sheetDataUsecase.delete();
  }

  void applyUpdatesNoSort(
    List<UpdateUnit> updates,
    String sheetId,
    bool isFromHistory,
      bool isFromEditing,
  ) {
    sheetDataUsecase.applyUpdatesNoSort(updates, sheetId, isFromHistory, isFromEditing);
  }
}
