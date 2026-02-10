import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/parse_paste_data_usecase.dart';
import 'dart:async';
import 'dart:isolate';

import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';

class ThreadResult {
  final AnalysisResult result;
  final bool startSorter;

  ThreadResult(this.result, this.startSorter);
}

class SortController extends ChangeNotifier {
  bool findingBestSort = false;
  final Map<String, ManageWaitingTasks<void>> _saveExecutors = {};

  Isolate? _isolateB;
  Isolate? _isolateC;

  // We use Completers to handle the "result" promise which we might need to
  // abandon if the isolate is killed.
  ReceivePort? _portB;
  ReceivePort? _portC;
  
  final SaveSheetDataUseCase _saveSheetDataUseCase;
    

  late void Function(
    SheetData sheet,
    SelectionData selection,
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName, {
    bool updateHistory,
    bool notify,
  })
  stopEditing;
  late void Function(
    SheetData sheet,
    Map<String, AnalysisResult> analysisResults,
    SelectionData selection,
    Map<String, SelectionData> lastSelectionBySheet,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth,
    String currentSheetName,
    List<CellUpdate> updates,
  )
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

  void setBestMediaSortOrder(AnalysisResult result, List<int> order) {
    result.bestMediaSortOrder = order;
  }

  bool canBeSorted(SheetData sheet, AnalysisResult result) {
    debugPrint("hey");
    return sheet.calculated && result.bestMediaSortOrder != null;
  }

  bool lightCalculations(AnalysisResult result) {
    return false;
  }

  Future<void> calculate(
    SheetData sheet,
    Map<String, AnalysisResult> analysisResults,
    SelectionData selection,
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
  ) async {
    AnalysisResult result = analysisResults[currentSheetName]!;
    if (sheet.calculated && lightCalculations(result)) {
      return;
    }
    clear(result);
    cancelB();
    ThreadResult resultB = await runHeavyCalculationB(
      sheet.sheetContent,
      result,
    );
    analysisResults[currentSheetName] = resultB.result;
    if (resultB.startSorter) {
      result.bestMediaSortOrder = await runHeavyCalculationC(result);
    }
    sheet.calculated = true;
    saveAnalysisResult(currentSheetName, result);
    onAnalysisComplete(result, selection.primarySelectedCell);
    notifyListeners();
  }

  Future<void> saveAnalysisResult(String sheetName, AnalysisResult result) async {
    if (_saveExecutors[sheetName] == null) {
      _saveExecutors[sheetName] = ManageWaitingTasks<void>();
    }
    _saveExecutors[sheetName]!.execute(() async {
      await _saveSheetDataUseCase.saveAnalysisResult(sheetName, result);
      await Future.delayed(Duration(milliseconds: SpreadsheetConstants.saveAnalysisResultDelayMs));
    });
  }

  static Future<void> _isolateEntryC(List<dynamic> args) async {
    SendPort sendPort = args[0];
    AnalysisResult result = args[1];

    result.bestMediaSortOrder = await solveSatisfaction(
      result,
    );

    Isolate.exit(sendPort, result.bestMediaSortOrder);
  }

  void cancelC() {
    if (_isolateC != null) {
      _isolateC!.kill(priority: Isolate.immediate);
      _isolateC = null;
      _portC?.close();
    }
  }

  Future<List<int>?> runHeavyCalculationC(AnalysisResult result) async {
    cancelC();

    final receivePort = ReceivePort();
    _portC = receivePort;

    _isolateC = await Isolate.spawn(_isolateEntryC, [
      receivePort.sendPort,
      result,
    ]);

    try {
      final result = await receivePort.first;
      return result as List<int>?;
    } catch (e) {
      throw Exception("Isolate C execution interrupted");
    } finally {
      _isolateC = null;
    }
  }

  Future<ThreadResult> runHeavyCalculationB(
    SheetContent sheetContent,
    AnalysisResult result,
  ) async {
    // Requirements: "If A starts... cancel B if it was running."
    // This is handled by the Bloc calling cancelB() before A,
    // but we double check here to ensure clean state.

    final receivePort = ReceivePort();
    _portB = receivePort;

    _isolateB = await Isolate.spawn(CalculationService.runCalculation, [
      receivePort.sendPort,
      sheetContent,
      result,
    ]);

    // Wait for the first message
    try {
      AnalysisResult result = await receivePort.first;
      bool startSorter = true;
      return ThreadResult(result, startSorter);
    } catch (e) {
      // If port closes or isolate killed
      throw Exception("Isolate B execution interrupted");
    } finally {
      _isolateB = null; // Cleanup
    }
  }

  void cancelB() {
    if (_isolateB != null) {
      _isolateB!.kill(priority: Isolate.immediate);
      _isolateB = null;
      _portB?.close();
    }
  }

  static Future<List<int>?> solveSatisfaction(
    AnalysisResult result,
  ) async {
    int nVal = result.instrTable.length;
    if (result.errorRoot.newChildren!.isNotEmpty || nVal == 0) {
      return null;
    }
    final service = SortingService();

    try {
      // await for pauses the execution of this function
      // until the stream is closed by the server.
      await for (final solution in service.solveSortingStream(
        nVal,
        result.myRules,
      )) {
        return solution;
      }
    } catch (error) {
      result.errorRoot.newChildren!.add(
        NodeStruct(
          message: "Could not find a valid sorting satisfying all constraints.",
        ),
      );
    }
    return null;
  }

  void sortMedia(
    SheetData sheet,
    Map<String, AnalysisResult> analysisResults,
    SelectionData selection,
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth,
  ) {
    stopEditing(
      sheet,
      selection,
      lastSelectionBySheet,
      currentSheetName,
      notify: false,
    );
    List<int> sortOrder = [0];
    AnalysisResult result = analysisResults[currentSheetName]!;
    List<int> stack = result.bestMediaSortOrder!
        .asMap()
        .entries
        .map((e) => result.validRowIndexes[e.key])
        .toList()
        .reversed
        .toList();
    final rowToRowRefs = result.rowToRefFromAttCol;
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
              toNewPlacement[result.formatedTable[rowId][colId].integers[splitId]];
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
    setTable(
      sheet,
      analysisResults,
      selection,
      lastSelectionBySheet,
      row1ToScreenBottomHeight,
      colBToScreenRightWidth,
      currentSheetName,
      updates,
    );
  }

  Future<void> findBestSortToggle(
    SheetData sheet,
    AnalysisResult result,
    SelectionData selection,
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth,
  ) async {
    stopEditing(
      sheet,
      selection,
      lastSelectionBySheet,
      currentSheetName,
      notify: false,
    );
    if (findingBestSort) {
      findingBestSort = false;
    } else {
      findingBestSort = true;
      stopEditing(
        sheet,
        selection,
        lastSelectionBySheet,
        currentSheetName,
        notify: false,
      );
      int nVal = result.instrTable.length;
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
          maximizeBetween: result.maximizeBetween,
        )) {
          setBestMediaSortOrder(result, solution);
        }
      } catch (error) {
        clear(result);
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
