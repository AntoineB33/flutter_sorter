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
import 'package:trying_flutter/features/media_sorter/domain/helpers/utils_services.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/helpers/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/data/services/spreadsheet_clipboard_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';

class SheetDataUsecase {
  final SheetDataRepository sheetDataRepository;
  final SortRepository sortRepository;
  final GridRepository gridRepository;
  final HistoryRepository historyRepository;

  final StreamSubscription<Failure> _failureSubscription;

  SheetDataUsecase({
    required this.sheetDataRepository,
    required this.sortRepository,
    required this.gridRepository,
    required this.historyRepository,
  }) : _failureSubscription = sheetDataRepository.failureStream.listen((failure) {
          UtilsServices.handleDataCorruption(Left(failure));
        });
  
  void dispose() {
    _failureSubscription.cancel();
  }

  bool containsSheetId(String sheetId) {
    return sheetDataRepository.containsSheetId(sheetId);
  }

  int rowCount(String sheetId) {
    return sheetDataRepository.rowCount(sheetId);
  }

  int colCount(String sheetId) {
    return sheetDataRepository.colCount(sheetId);
  }

  String getCellContent(int row, int col, String sheetId) {
    return sheetDataRepository.getCellContent(Point<int>(row, col), sheetId);
  }

  SheetData getSheet(String sheetId) {
    return sheetDataRepository.getSheet(sheetId);
  }

  void applyUpdatesNoSort(
    List<UpdateUnit> updates,
    String sheetId,
    bool isFromHistory,
  ) {
    sheetDataRepository.update(updates, sheetId);
    if (gridRepository.adjustRowHeightAfterUpdate(sheetId, updates)) {}
    if (!isFromHistory) {
      historyRepository.commitHistory(updates, sheetId);
    }
  }

  List<CellUpdate> delete() {
    return sheetDataRepository.delete();
  }

  Future<Either<Failure, List<CellUpdate>>> paste() {
    return sheetDataRepository.pasteSelection();
  }
}
