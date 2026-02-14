import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_response.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/parse_paste_data_usecase.dart';
import 'dart:async';

import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/services/isolate_service.dart';

class ThreadResult {
  final AnalysisResult result;
  final bool startSorter;

  ThreadResult(this.result, this.startSorter);
}

class SortController extends ChangeNotifier {
  final Map<String, ManageWaitingTasks<void>> _saveExecutors = {};
  final Map<String, IsolateService> _isolateServices = {};

  final SaveSheetDataUseCase _saveSheetDataUseCase;

  late void Function(
    SheetData sheet,
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName, {
    bool updateHistory,
    bool notify,
  })
  stopEditing;
  late void Function(
    SheetData sheet,
    Map<String, AnalysisResult> analysisResults,
    Map<String, SelectionData> lastSelectionBySheet,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth,
    String currentSheetName,
    List<CellUpdate> updates, {
    bool toCalculate,
  })
  setTable;
  late void Function(AnalysisResult result, Point<int> primarySelectedCell)
  onAnalysisComplete;

  final CalculationService calculationService = CalculationService();

  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) =>
      content.table.isNotEmpty ? content.table[0].length : 0;

  SortController(this._saveSheetDataUseCase);

  void clear(AnalysisResult result) {
    result.bestMediaSortOrder = null;
  }

  void setBestMediaSortOrder(
    Map<String, AnalysisResult> analysisResults,
    List<int> order,
    SheetData sheet,
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth,
  ) {
    analysisResults[currentSheetName]!.bestMediaSortOrder = order;
    sortMedia(
      sheet,
      analysisResults,
      lastSelectionBySheet,
      currentSheetName,
      row1ToScreenBottomHeight,
      colBToScreenRightWidth,
    );
  }

  bool canBeSorted(SheetData sheet, AnalysisResult result) {
    debugPrint("hey");
    return result.resultCalculated && result.validSortCalculated &&
        result.bestMediaSortOrder != null &&
        !result.sorted;
  }

  bool lightCalculations(AnalysisResult result) {
    return false;
  }

  Future<void> calculate(
    SheetData sheet,
    Map<String, AnalysisResult> analysisResults,
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
  ) async {
    AnalysisResult result = analysisResults[currentSheetName]!;
    if (result.resultCalculated && lightCalculations(result)) {
      return;
    }
    clear(result);
    _isolateServices[currentSheetName] ??= IsolateService();
    _isolateServices[currentSheetName]!.cancelB();
    ThreadResult resultB = await _isolateServices[currentSheetName]!
        .runHeavyCalculationB(sheet.sheetContent, result);
    analysisResults[currentSheetName] = resultB.result;
    result = resultB.result;
    result.resultCalculated = true;
    if (resultB.startSorter) {
      try {
        result.bestMediaSortOrder = await _isolateServices[currentSheetName]!
          .runHeavyCalculationC(result);
        result.validSortCalculated = true;
      } catch (e) {
        result.errorRoot.newChildren!.add(
          NodeStruct(
            message: "An error occurred while trying to find a valid sorting satisfying all constraints : $e",
          ),
        );
      }
    }
    saveAnalysisResult(currentSheetName, result);
    onAnalysisComplete(
      result,
      lastSelectionBySheet[currentSheetName]!.primarySelectedCell,
    );
    notifyListeners();
  }

  Future<void> saveAnalysisResult(
    String sheetName,
    AnalysisResult result,
  ) async {
    _saveExecutors[sheetName] ??= ManageWaitingTasks<void>();
    _saveExecutors[sheetName]!.execute(() async {
      await _saveSheetDataUseCase.saveAnalysisResult(sheetName, result);
      await Future.delayed(
        Duration(milliseconds: SpreadsheetConstants.saveAnalysisResultDelayMs),
      );
    });
  }

  static Future<SortingResponse?> solveSatisfaction(
    AnalysisResult result,
  ) async {
    int nVal = result.tableToAtt.length;
    if (result.errorRoot.newChildren!.isNotEmpty || nVal == 0) {
      return null;
    }
  
    try {
      // await for pauses the execution of this function
      // until the stream is closed by the server.
      return SortUsecase.solveSorting(result.myRules, result.validAreas, nVal);
    } catch (error) {
      result.errorRoot.newChildren!.add(
        NodeStruct(
          message: "An error occurred while trying to find a valid sorting satisfying all constraints : $error",
        ),
      );
    }
    return null;
  }

  void sortResult(
    Map<String, AnalysisResult> analysisResults,
    String currentSheetName,
    List<int> sortOrder,
  ) {
    AnalysisResult result = analysisResults[currentSheetName]!;
    int rowCount = result.tableToAtt.length;
    if (rowCount == 0) {
      return;
    }
    int colCount = result.tableToAtt[0].length;
    List<int> newInd = List.filled(rowCount, 0);
    for (int i = 0; i < rowCount; i++) {
      newInd[sortOrder[i]] = i;
    }
    result.tableToAtt = List.generate(
      rowCount,
      (i) => List.generate(
        colCount,
        (j) => HashSet<Attribute>.from(
          result.tableToAtt[sortOrder[i]][j].map(
            (e) => e.rowId != null ? Attribute.row(newInd[e.rowId!]) : e,
          ),
        ),
      ),
    );
    result.names.forEach((key, value) {
      value.rowId = newInd[value.rowId];
    });
    result.formatedTable = List.generate(
      rowCount,
      (i) => List.generate(
        colCount,
        (j) => StrInt(
          strings: result.formatedTable[sortOrder[i]][j].strings,
          integers: result.formatedTable[sortOrder[i]][j].integers
              .map((e) => newInd[e])
              .toList(),
        ),
      ),
    );
    result.attToRefFromAttColToCol.forEach((key, value) {
      if (key.rowId != null) {
        key.rowId = newInd[key.rowId!];
      }
      value = Map.fromEntries(
        value.entries.map((e) => MapEntry(newInd[e.key], e.value)),
      );
    });
    result.attToRefFromDepColToCol.forEach((key, value) {
      if (key.rowId != null) {
        key.rowId = newInd[key.rowId!];
      }
      value = Map.fromEntries(
        value.entries.map((e) => MapEntry(newInd[e.key], e.value)),
      );
    });
    for (int id = 0; id < result.validRowIndexes.length; id++) {
      result.validRowIndexes[id] = newInd[result.validRowIndexes[id]];
    }
    result.colToAtt = Map.fromEntries(
      result.colToAtt.entries.map(
        (e) => MapEntry(
          e.key,
          HashSet<Attribute>.from(
            e.value.map(
              (att) =>
                  att.rowId != null ? Attribute.row(newInd[att.rowId!]) : att,
            ),
          ),
        ),
      ),
    );
    result.myRules = Map.fromEntries(
      result.myRules.entries.map(
        (e) => MapEntry(
          newInd[e.key],
          Map.fromEntries(
            e.value.entries.map(
              (innerE) => MapEntry(
                newInd[innerE.key],
                innerE.value,
              ),
            ),
          ),
        ),
      ),
    );
    result.groupsToMaximize = result.groupsToMaximize
        .map((group) => group.map((id) => newInd[id]).toList())
        .toList();
    result.validAreas = List.generate(
      rowCount,
      (i) => result.validAreas[sortOrder[i]]
    );
  }

  void sortMedia(
    SheetData sheet,
    Map<String, AnalysisResult> analysisResults,
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth,
  ) {
    stopEditing(sheet, lastSelectionBySheet, currentSheetName, notify: false);
    List<int> sortOrder = [0];
    AnalysisResult result = analysisResults[currentSheetName]!;
    List<int> stack = result.bestMediaSortOrder!
        .asMap()
        .entries
        .map((e) => result.validRowIndexes[e.key])
        .toList()
        .reversed
        .toList();
    final table = sheet.sheetContent.table;
    List<int> added = List.filled(table.length, 0);
    for (int i in stack) {
      added[i] = 1;
    }
    List<String> toNewPlacement = List.filled(table.length, '');
    for (int rowId in result.validRowIndexes) {
      stack.add(rowId);
      while (stack.isNotEmpty) {
        int current = stack[stack.length - 1];
        if (added[current] == 2) {
          stack.removeLast();
          continue;
        }
        for (Attribute ref in result.tableToAtt[current].expand((i) => i).toList()) {
          if (ref.isRow() && added[ref.rowId!] != 2) {
            stack.add(ref.rowId!);
            added[ref.rowId!] = 1;
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
        if (result.formatedTable[rowId][colId].integers.isEmpty) {
          continue;
        }
        for (
          int splitId = 0;
          splitId < result.formatedTable[rowId][colId].strings.length;
          splitId++
        ) {
          sortedTable[rowId][colId] =
              result.formatedTable[rowId][colId].strings[splitId];
          if (result.formatedTable[rowId][colId].integers.length <= splitId) {
            break;
          }
          sortedTable[rowId][colId] +=
              toNewPlacement[result
                  .formatedTable[rowId][colId]
                  .integers[splitId]];
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
    sortResult(analysisResults, currentSheetName, sortOrder);
    setTable(
      sheet,
      analysisResults,
      lastSelectionBySheet,
      row1ToScreenBottomHeight,
      colBToScreenRightWidth,
      currentSheetName,
      updates,
      toCalculate: false,
    );
  }

  Future<void> findBestSortToggle(
    SheetData sheet,
    Map<String, AnalysisResult> analysisResults,
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth,
  ) async {
    AnalysisResult result = analysisResults[currentSheetName]!;
    if (result.isFindingBestSort) {
      result.isFindingBestSort = false;
      notifyListeners();
      return;
    }
    result.isFindingBestSort = true;
    stopEditing(sheet, lastSelectionBySheet, currentSheetName, notify: false);
    int nVal = result.tableToAtt.length;
    if (result.errorRoot.newChildren!.isNotEmpty || nVal == 0) {
      return;
    }
    final service = SortingService();

    try {
      // await for pauses the execution of this function
      // until the stream is closed by the server.
      await for (final solution in service.solveSortingStream(
        nVal,
        result.myRules,
        groupsToMaximize: result.groupsToMaximize,
      )) {
        if (!result.isFindingBestSort) {
          // If the user has toggled off the "finding best sort" mode, we should stop processing results.
          break;
        }
        setBestMediaSortOrder(
          analysisResults,
          solution.sortedIds!,
          sheet,
          lastSelectionBySheet,
          currentSheetName,
          row1ToScreenBottomHeight,
          colBToScreenRightWidth,
        );
      }
    } catch (error) {
      clear(result);
      result.errorRoot.newChildren!.add(
        NodeStruct(
          message: "Could not find a valid sorting satisfying all constraints.",
        ),
      );
    }
  }
}
