import 'dart:async';
import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/helpers/utils_services.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';

class SelectionUsecase {
  final SelectionRepository selectionRepository;
  final SheetDataRepository sheetDataRepository;
  final GridRepository gridRepository;
  final HistoryRepository historyRepository;
  final WorkbookRepository workbookRepository;

  late StreamSubscription<Failure> _failureSubscription;

  Point<int> get primarySelectedCell => selectionRepository.primarySelectedCell;

  SelectionUsecase(
    this.selectionRepository,
    this.sheetDataRepository,
    this.gridRepository,
    this.historyRepository,
    this.workbookRepository,
  ) {
    _failureSubscription = selectionRepository.failureStream.listen((failure) {
      UtilsServices.handleDataCorruption(Left(failure));
    });
  }

  void dispose() {
    _failureSubscription.cancel();
  }

  double getScrollOffsetX(String sheetId) {
    return selectionRepository.getScrollOffsetX(sheetId);
  }

  double getScrollOffsetY(String sheetId) {
    return selectionRepository.getScrollOffsetY(sheetId);
  }

  void clearLastSelection() {
    selectionRepository.clearLastSelection();
  }

  void selectAll() {
    selectionRepository.selectAll();
  }

  void setPrimarySelection(int row, int col, bool keepSelection) {
    selectionRepository.setPrimarySelection(row, col, keepSelection);
  }

  SelectionData getSelectionData(String sheetId) {
    return selectionRepository.getSelectionData(sheetId);
  }

  void saveLastSelection() {
    selectionRepository.saveLastSelection();
  }

  Future<bool> loadLastSelection() async {
    Either<Failure, void> result;
    result = await selectionRepository.loadLastSelection();
    return UtilsServices.handleDataCorruption(result);
  }

  Future<SelectionData> getLastSelection() async {
    return selectionRepository.getSelectionData(
      workbookRepository.currentSheetId,
    );
  }
}
