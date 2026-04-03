import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/features/media_sorter/core/entities/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/helpers/calculation_service.dart';
import 'dart:async';

import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/workbook_usecase.dart';

class SortController extends ChangeNotifier {
  final SheetDataUsecase sheetDataUsecase;
  final SortUsecase sortUseCase;
  final WorkbookUsecase workbookUsecase;

  final CalculationService calculationService = CalculationService();
  late StreamSubscription _subscription;

  int get currentSheetId => workbookUsecase.currentSheetId;

  SortController(
    this.sheetDataUsecase,
    this.sortUseCase,
    this.workbookUsecase,
  );

  List<int> getRecentSheetIds() {
    return workbookUsecase.getRecentSheetIds();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  bool getAnalysIsDone(int sheetId) {
    return sortUseCase.getAnalysIsDone(sheetId);
  }

  Future<void> analyze(int sheetId) {
    return sortUseCase.analyze(sheetId);
  }

  Future<Stream<SortProgressDataMsg>> launchCalculation(int sheetId) {
    return sortUseCase.launchCalculation(sheetId);
  }

  bool handleSortProgressDataMsg(
    SortProgressDataMsg sortProgressDataMsg,
    int sheetId,
  ) {
    return sortUseCase.handleSortProgressDataMsg(sortProgressDataMsg, sheetId);
  }

  bool willNextBestSortBeApplied(int sheetId) {
    return sortUseCase.willNextBestSortBeApplied(sheetId);
  }

  @useResult
  ChangeSet sortTableWithCurrentBestSort(int sheetId) {
    return sortUseCase.sortTableWithCurrentBestSort(sheetId);
  }

  bool getToApplyOnce(int sheetId) {
    return sortUseCase.getToApplyOnce(sheetId);
  }

  bool isCalculating(int sheetId) {
    return sortUseCase.isCalculating(sheetId);
  }

  void setToApplyOnce(int sheetId, bool toApplyOnce) {
    sortUseCase.setToApplyOnce(sheetId, toApplyOnce);
  }

  void setSortedWithCurrentBestSort(int sheetId, bool value) {
    sortUseCase.setSortedWithCurrentBestSort(sheetId, value);
  }

  bool isSortedWithValidSort() {
    return sortUseCase.isSortedWithValidSort(currentSheetId);
  }

  bool isApplyBetterSortButtonLocked() {
    return sortUseCase.isApplyBetterSortButtonLocked();
  }

  bool sortedWithCurrentBestSort(int sheetId) {
    return sortUseCase.sortedWithCurrentBestSort(sheetId);
  }

  bool isFindingBestSort() {
    return sortUseCase.isFindingBestSort(currentSheetId);
  }

  bool isAlwaysApplySortToggleLocked() {
    return !sortUseCase.canFindBetterSort(currentSheetId);
  }

  bool isCurrentBestSortAlwaysApplied() {
    return sortUseCase.isCurrentBestSortAlwaysApplied(currentSheetId);
  }

  void setFindingBestSort(int sheetId, bool value) {
    sortUseCase.setFindingBestSort(sheetId, value);
  }

  void setToAlwaysApplyBestSort(int sheetId, bool toAlwaysApply) {
    sortUseCase.setToAlwaysApplyBestSort(sheetId, toAlwaysApply);
  }

  void loadSortStatus() {
    sortUseCase.loadSortStatus();
  }
}
