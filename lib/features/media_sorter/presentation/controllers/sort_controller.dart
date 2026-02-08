import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';

class SortController extends ChangeNotifier {
  Map<int, List<SortingRule>> myRules = {};
  List<int>? _bestMediaSortOrder;
  bool findingBestSort = false;
  final ManageWaitingTasks<AnalysisResult> _calculateExecutor =
      ManageWaitingTasks<AnalysisResult>();

      
  final CalculationService calculationService = CalculationService();

  List<int>? get bestMediaSortOrder => _bestMediaSortOrder;

  SortController();

  void clear() {
    _bestMediaSortOrder = null;
  }

  void setBestMediaSortOrder(List<int> order) {
    _bestMediaSortOrder = order;
  }

  bool canBeSorted() {
    return _bestMediaSortOrder != null;
  }

  

  void calculate(SheetContent sheetContent, int rowCount, int colCount, Function(AnalysisResult, Point<int>) onAnalysisComplete, SelectionData selection, SortController sortController) {
    _calculateExecutor.execute(
      () async {
        AnalysisResult result = await calculationService.runCalculation(
          sheetContent,
        );
        await sortController.solveSatisfaction(result);
        return result;
      },
      onComplete: (AnalysisResult result) {
        result.rowCount = rowCount;
        result.colCount = colCount;
        result.noResult = false;

        onAnalysisComplete(result, selection.primarySelectedCell);
        notifyListeners();
      },
    );
  }

  Future<void> solveSatisfaction(AnalysisResult result) async {
    int nVal = result.instrTable.length;
    if (result.errorRoot.newChildren!.isNotEmpty || nVal == 0) {
      return;
    }

    myRules = {};
    for (int rowId = 0; rowId < nVal; rowId++) {
      myRules[rowId] = [];
      for (final instr in result.instrTable[rowId].keys) {
        if (!instr.isConstraint) {
          continue;
        }
        for (int target in instr.numbers) {
          for (final interval in instr.intervals) {
            int minVal = interval[0];
            int maxVal = interval[1];
            myRules[rowId]!.add(
              SortingRule(
                minVal: minVal,
                maxVal: maxVal,
                relativeTo: target,
              ),
            );
          }
        }
      }
    }

    final service = SortingService();

    try {
      // await for pauses the execution of this function
      // until the stream is closed by the server.
      await for (final solution in service.solveSortingStream(
        nVal,
        myRules,
      )) {
        setBestMediaSortOrder(solution);
      }
    } catch (error) {
      clear();
      result.errorRoot.newChildren!.add(
        NodeStruct(
          message:
              "Could not find a valid sorting satisfying all constraints.",
        ),
      );
    }
  }

}