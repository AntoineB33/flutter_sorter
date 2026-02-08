import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/parse_paste_data_usecase.dart';

class SortController extends ChangeNotifier {
  Map<int, List<SortingRule>> myRules = {};
  List<int>? _bestMediaSortOrder;
  bool findingBestSort = false;
  final ManageWaitingTasks<AnalysisResult> _calculateExecutor =
      ManageWaitingTasks<AnalysisResult>();
  void Function(SheetData sheet, SelectionData selection, Map<String, SelectionData> lastSelectionBySheet, String currentSheetName, {bool updateHistory, bool notify}) stopEditing;
  void Function(SheetData sheet, SelectionData selection, String currentSheetName, List<CellUpdate> updates) setTable;

      
  final CalculationService calculationService = CalculationService();

  List<int>? get bestMediaSortOrder => _bestMediaSortOrder;
  
  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) => content.table.isNotEmpty ? content.table[0].length : 0;

  SortController(this.stopEditing, this.setTable);

  void clear() {
    _bestMediaSortOrder = null;
  }

  void setBestMediaSortOrder(List<int> order) {
    _bestMediaSortOrder = order;
  }

  bool canBeSorted() {
    return _bestMediaSortOrder != null;
  }

  

  void calculate(SheetData sheet, int rowCount, int colCount, Function(AnalysisResult, Point<int>) onAnalysisComplete, SelectionData selection, SortController sortController) {
    clear();
    _calculateExecutor.execute(
      () async {
        AnalysisResult result = await calculationService.runCalculation(
          sheet.sheetContent,
        );
        await sortController.solveSatisfaction(sheet, selection, {}, "", result);
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

  void getRules(AnalysisResult result) {
    int nVal = result.instrTable.length;
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
  }

  Future<void> solveSatisfaction(SheetData sheet, SelectionData selection, Map<String, SelectionData> lastSelectionBySheet, String currentSheetName, AnalysisResult result) async {
    stopEditing(sheet, selection, lastSelectionBySheet, currentSheetName, notify: false);
    int nVal = result.instrTable.length;
    if (result.errorRoot.newChildren!.isNotEmpty || nVal == 0) {
      return;
    }
    getRules(result);
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
  void sortMedia(SheetData sheet, SelectionData selection, Map<String, SelectionData> lastSelectionBySheet, String currentSheetName, List<int> validRowIndexes, List<bool> isMedium, List<List<StrInt>> formatedTable, List<List<String>> table, List<List<int>> rowToRefFromAttCol) {
    stopEditing(sheet, selection, lastSelectionBySheet, currentSheetName, notify: false);
    List<int> sortOrder = [0];
    List<int> stack = bestMediaSortOrder!
        .asMap()
        .entries
        .map((e) => validRowIndexes[e.key])
        .toList()
        .reversed
        .toList();
    final rowToRowRefs = rowToRefFromAttCol;
    final table = sheet.sheetContent.table;
    List<int> added = List.filled(table.length, 0);
    for (int i in stack) {
      added[i] = 1;
    }
    List<String> toNewPlacement = List.filled(table.length, '');
    for (int rowId in validRowIndexes) {
      stack.add(rowId);
      while (stack.isNotEmpty) {
        int current = stack[stack.length - 1];
        if (added[current] == 2) {
          stack.removeLast();
          continue;
        }
        for (int ref in rowToRowRefs[current]) {
          if (added[ref] != 2) {
            stack.add(ref);
            added[ref] = 1;
          }
        }
        if (stack[stack.length - 1] == current) {
          toNewPlacement[current] = sortOrder.length.toString();
          sortOrder.add(current);
          stack.removeLast();
          added[current] = 2;
        }
      }
    }
    for (int rowId = 1; rowId < table.length; rowId++) {
      if (added[rowId] == 0) {
        sortOrder.add(rowId);
      }
    }
    List<List<String>> sortedTable = sortOrder.map((i) => table[i]).toList();
    for (int rowId = 1; rowId < rowCount(sheet.sheetContent); rowId++) {
      for (int colId = 0; colId < colCount(sheet.sheetContent); colId++) {
        if (formatedTable[rowId][colId].integers.isEmpty) {
          continue;
        }
        for (
          int splitId = 0;
          splitId < formatedTable[rowId][colId].strings.length;
          splitId++
        ) {
          sortedTable[rowId][colId] =
              formatedTable[rowId][colId].strings[splitId];
          if (formatedTable[rowId][colId].integers.length <= splitId) {
            break;
          }
          sortedTable[rowId][colId] +=
              toNewPlacement[formatedTable[rowId][colId].integers[splitId]];
        }
      }
    }
    final List<CellUpdate> updates = [];
    for (int rowId = 1; rowId < sortedTable.length; rowId++) {
      for (int colId = 0; colId < sortedTable[rowId].length; colId++) {
        updates.add(
          CellUpdate(row: rowId, col: colId, value: sortedTable[rowId][colId]),
        );
      }
    }
    setTable(sheet, selection, currentSheetName, updates);
  }

  Future<void> findBestSortToggle(SheetData sheet, AnalysisResult result, SelectionData selection, Map<String, SelectionData> lastSelectionBySheet, String currentSheetName) async {
    if (findingBestSort) {
      findingBestSort = false;
    } else {
      findingBestSort = true;
      stopEditing(sheet, selection, lastSelectionBySheet, currentSheetName, notify: false);
      int nVal = result.instrTable.length;
      if (result.errorRoot.newChildren!.isNotEmpty || nVal == 0) {
        return;
      }
      getRules(result);
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


}