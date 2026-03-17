import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/helpers/calculation_service.dart';
import 'dart:async';

import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/workbook_usecase.dart';
import 'package:trying_flutter/utils/logger.dart';

class SortController extends ChangeNotifier {
  final SheetDataUsecase sheetDataUsecase;
  final SortUsecase sortUseCase;
  final WorkbookUsecase workbookUsecase;

  final CalculationService calculationService = CalculationService();
  late StreamSubscription _subscription;

  String get currentSheetId => workbookUsecase.currentSheetId;

  SortController(
    this.sheetDataUsecase,
    this.sortUseCase,
    this.workbookUsecase,
  ) {
    _subscription = sortUseCase.failureStream.listen((Failure failure) {
      _onFailure(failure);
    });
  }

  Future<void> loadAnalysisResult(String sheetId) {
    return sortUseCase.loadAnalysisResult(sheetId);
  }

  Future<void> loadSortStatus() async {
    sortUseCase.loadSortStatus();
  }

  List<String> getRecentSheetIds() {
    return workbookUsecase.getRecentSheetIds();
  }

  void _onFailure(Failure failure) {
    logger.e('A failure occurred during saving.');
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  bool getAnalysisDone(String sheetId) {
    return sortUseCase.getAnalysisDone(sheetId);
  }

  Future<void> analyze(String sheetId) {
    return sortUseCase.analyze(sheetId);
  }

  void lightCalculations(String sheetId) {
    sortUseCase.lightCalculations(sheetId);
  }

  Future<Stream<SortProgressDataMsg>> launchCalculation(String sheetId) {
    return sortUseCase.launchCalculation(sheetId);
  }

  bool handleSortProgressDataMsg(
    SortProgressDataMsg sortProgressDataMsg,
    String sheetId,
  ) {
    return sortUseCase.handleSortProgressDataMsg(sortProgressDataMsg, sheetId);
  }

  bool willNextBestSortBeApplied(String sheetId) {
    return sortUseCase.willNextBestSortBeApplied(sheetId);
  }

  List<UpdateUnit> sortTableWithCurrentBestSort(String sheetId) {
    return sortUseCase.sortTableWithCurrentBestSort(sheetId);
  }

  bool getToApplyOnce(String sheetId) {
    return sortUseCase.getToApplyOnce(sheetId);
  }

  bool isCalculating(String sheetId) {
    return sortUseCase.isCalculating(sheetId);
  }

  void setToApplyOnce(String sheetId, bool toApplyOnce) {
    sortUseCase.setToApplyOnce(sheetId, toApplyOnce);
  }

  void setSortedWithCurrentBestSort(String sheetId, bool value) {
    sortUseCase.setSortedWithCurrentBestSort(sheetId, value);
  }

  bool isSortedWithValidSort() {
    return sortUseCase.isSortedWithValidSort(currentSheetId);
  }

  bool isApplyBetterSortButtonLocked() {
    return sortUseCase.isApplyBetterSortButtonLocked();
  }

  bool sortedWithCurrentBestSort(String sheetId) {
    return sortUseCase.sortedWithCurrentBestSort(sheetId);
  }

  bool isApplyBetterSortButtonInAction() {
    return sortUseCase.isApplyBetterSortButtonInAction();
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

  void findBestSortToggle(bool value) {
    sortUseCase.setFindingBestSort(currentSheetId, value);
  }

  void setToAlwaysApplyBestSort(String sheetId, bool toAlwaysApply) {
    sortUseCase.setToAlwaysApplyBestSort(sheetId, toAlwaysApply);
  }
}
