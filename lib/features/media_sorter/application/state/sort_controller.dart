import 'dart:collection';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/helpers/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';
import 'dart:async';

import 'package:trying_flutter/features/media_sorter/application/state/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sort_status_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/coordinator_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/workbook_usecase.dart';
import 'package:trying_flutter/utils/logger.dart';
import 'package:uuid/uuid.dart';

class SortController extends ChangeNotifier {
  final SheetDataUsecase sheetDataUsecase;
  final SortUsecase sortUseCase;
  final CoordinatorUsecase coordinatorUsecase;
  final WorkbookUseCase workbookUsecase;

  final CalculationService calculationService = CalculationService();
  late StreamSubscription _subscription;

  SortController(
    this.sheetDataUsecase,
    this.sortUseCase,
    this.coordinatorUsecase,
    this.workbookUsecase,
  ) {
    _subscription = sortUseCase.failureStream.listen((Failure failure) {
      _onFailure(failure);
    });
  }

  List<String> getSheetIds() {
    return sortUseCase.getSheetIds();
  }

  void _onFailure(Failure failure) {
    logger.e('A failure occurred during saving.');
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> calculateCurrentSheet() async {
    await calculateOnChange(sortUseCase.currentSheetId);
  }

  Future<void> calculateOnChange(String sheetId) async {
    await for (final SortProgressDataMsg sortProgressDataMsg
        in sortUseCase.calculateOnChange(sheetId)) {
      if (_handleSortProgressDataMsg(sortProgressDataMsg, sheetId)) {
        break;
      }
    }
  }

  Future<void> launchCalculation(String sheetId) async {
    await for (final SortProgressDataMsg sortProgressDataMsg
        in sortUseCase.launchCalculation(sheetId)) {
      if (_handleSortProgressDataMsg(sortProgressDataMsg, sheetId)) {
        break;
      }
    }
  }

  bool _handleSortProgressDataMsg(
    SortProgressDataMsg sortProgressDataMsg,
    String sheetId,
  ) {
    bool stopLoop = sortUseCase.handleSortProgressDataMsg(
      sortProgressDataMsg,
      sheetId,
    );
    if (sortProgressDataMsg.newBestSortFound &&
        sortUseCase.getToApplyNextSort(sheetId)) {
      final List<UpdateUnit> updates = sortUseCase.sortTable(sheetId);
      coordinatorUsecase.applyUpdates(updates, sheetId, true, false);
      if (sortUseCase.getToApplyOnce(sheetId)) {
        sortUseCase.setToApplyOnce(sheetId, false);
      }
    }
    return stopLoop;
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

  Future<void> loadAnalysisResult(String sheetName) async {
    try {
      await _getSheetDataUseCase.getAnalysisResult(sheetName);
    } catch (e) {
      logger.e("Error getting analysis result for $sheetName: $e");
    }
  }
}
