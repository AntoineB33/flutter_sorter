import 'dart:collection';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_response.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/parse_paste_data_usecase.dart';
import 'dart:async';

import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort/sort_usecase.dart';
import 'package:trying_flutter/features/media_sorter/data/services/isolate_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/analysis_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/sort_status_data_store.dart';
import 'package:trying_flutter/utils/logger.dart';

class SortService {
  final AnalysisDataStore analysisDataStore;
  final LoadedSheetsDataStore loadedSheetsDataStore;
  final SortStatusDataStore sortStatusDataStore;
  final Map<String, IsolateService> _isolateServices = {};

  SortService(
    this.sortStatusDataStore,
    this.loadedSheetsDataStore,
    this.analysisDataStore,
  );

  bool lightCalculations(AnalysisResult result) {
    return false;
  }

  Future<void> calculate(String name) async {
    SortStatus sortStatus = sortStatusDataStore.getSortStatus(name);
    AnalysisResult result = analysisDataStore.getAnalysisResult(name);
    if (sortStatus.resultCalculated && lightCalculations(result)) {
      return;
    }
    _isolateServices[name] ??= IsolateService();
    _isolateServices[name]!.cancelB();
    AnalysisReturn resultB = await _isolateServices[name]!.runHeavyCalculationB(
      loadedSheetsDataStore.getSheet(name).sheetContent,
      result,
    );
    sortStatusDataStore.updateSortStatus(name, (status) {
      status.resultCalculated = true;
      status.validSortFound = !resultB.noSortToFind && status.validSortFound;
      if (resultB.result.validRowIndexes.isEmpty) {
        status.validSortFound = true;
      }
    });
    if (resultB.changed) {
      analysisDataStore.updateResults(name, resultB.result);
    }
    sortStatus = sortStatusDataStore.getSortStatus(name);
    if (!sortStatus.validSortFound) {
      try {
        SortingResponse? response = await _isolateServices[name]!.findBestSort(
          result,
          false,
        );
        if (response != null) {
          analysisDataStore.getAnalysisResult(name).sorted =
              response.isNaturalOrderValid;
          result.currentBestSort = response.sortedIds;
        }
        if (sortStatus.toSort) {
          sortMedia(name);
          sortStatusDataStore.updateSortStatus(name, (status) {
            status.validSortFound = true;
            status.toSort = false;
          });
        } else if (sortStatus.isFindingBestSort) {
          sortStatusDataStore.updateSortStatus(name, (status) {
            status.validSortFound = true;
          });
          findBestSortToggleFunc(name);
        } else {
          sortStatusDataStore.removeSortStatus(name);
        }
      } catch (e) {
        result.errorRoot.newChildren!.add(
          NodeStruct(
            message:
                "An error occurred while trying to find a valid sorting satisfying all constraints : $e",
          ),
        );
      }
    }
  }

  void cancelFindingBestSort(String sheetId) {
    if (_isolateServices.containsKey(sheetId)) {
      _isolateServices[sheetId]!.cancelC();
    }
  }

  Stream<SortingResponse> findBestSort(String sheetId) async* {
    if (!_isolateServices.containsKey(sheetId)) {
      _isolateServices[sheetId] = IsolateService();
    }
    await for (final solution in _isolateServices[sheetId]!.findBestSort()) {
      yield solution;
    }
  }

}
