import 'package:flutter/material.dart';
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

  bool getToApplyNextSort(String sheetId) {
    return sortUseCase.getToApplyNextSort(sheetId);
  }

  List<UpdateUnit> sortTable(String sheetId) {
    return sortUseCase.sortTable(sheetId);
  }

  bool getToApplyOnce(String sheetId) {
    return sortUseCase.getToApplyOnce(sheetId);
  }

  void setToApplyOnce(String sheetId, bool toApplyOnce) {
    sortUseCase.setToApplyOnce(sheetId, toApplyOnce);
  }

  bool isApplyBetterSortButtonLocked() {
    return sortUseCase.isApplyBetterSortButtonLocked();
  }

  bool isBetterSortFound() {
    return sortUseCase.isBetterSortFound();
  }

  bool isApplyBetterSortButtonInAction() {
    return sortUseCase.isApplyBetterSortButtonInAction();
  }

  void applyBetterSortButton() {
    sortUseCase.applyBetterSortButton();
  }

  void findBestSortToggle() {
    sortUseCase.findBestSortToggle();
  }

  bool showApplySortToggle() {
    return sortUseCase.showApplySortToggle();
  }

  void applySortToggle() {
    sortUseCase.applySortToggle();
  }
}
