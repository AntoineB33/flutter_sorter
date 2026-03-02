import 'package:meta/meta.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_response.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'dart:async';
import 'package:trying_flutter/features/media_sorter/data/services/isolate_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sort_status_cache.dart';

class SortService {
  final AnalysisCache analysisDataStore;
  final LoadedSheetsCache loadedSheetsDataStore;
  final SortStatusCache sortStatusDataStore;
  final Map<String, IsolateService> _isolateServices = {};

  SortService(
    this.sortStatusDataStore,
    this.loadedSheetsDataStore,
    this.analysisDataStore,
  );

  bool sameResLightCheck(String sheetId) {
    return false;
  }

  void lightCalculate(String sheetId) {
    analysisDataStore.setOkToCalculateResult(sheetId, true);
  }

  Future<void> onCellChange(String sheetId) async {
    lightCalculate(sheetId);
    if (!analysisDataStore.okToCalculateResult(sheetId) ||
        sortStatusDataStore.isCalculatingResult(sheetId) &&
            sameResLightCheck(sheetId)) {
      return;
    }
    _isolateServices[sheetId] ??= IsolateService();
    _isolateServices[sheetId]!.cancelB();
    AnalysisReturn resultB = await _isolateServices[sheetId]!
        .runHeavyCalculationB(
          loadedSheetsDataStore.getSheet(sheetId).sheetContent,
          analysisDataStore.getAnalysisResult(sheetId),
        );
    sortStatusDataStore.update(sheetId, resultB.toFindValidSort);
    if (resultB.changed) {
      analysisDataStore.updateResults(sheetId, resultB.result);
    }
    if (resultB.toFindValidSort) {
      try {
        SortingResponse? response = await _isolateServices[sheetId]!
            .findBestSort(resultB.result, false);
        if (response != null) {
          analysisDataStore.getAnalysisResult(sheetId).sorted =
              response.isNaturalOrderValid;
          result.currentBestSort = response.sortedIds;
        }
        if (sortStatus.toSort) {
          sortMedia(sheetId);
          sortStatusDataStore.updateSortStatus(sheetId, (status) {
            status.validSortFound = true;
            status.toSort = false;
          });
        } else if (sortStatus.isFindingBestSort) {
          sortStatusDataStore.updateSortStatus(sheetId, (status) {
            status.validSortFound = true;
          });
          findBestSortToggleFunc(sheetId);
        } else {
          sortStatusDataStore.removeSortStatus(sheetId);
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
