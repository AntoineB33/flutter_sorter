import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/calculate_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/isolate_messages.dart';
import 'dart:io';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';

class CalculationService {
  Future<AnalysisResult> runCalculation(List<List<String>> table, List<ColumnType> types) async {
    final calculateUsecase = CalculateUsecase(
      table,
      types,
    );
    return compute(
      _isolateHandler,
      calculateUsecase.getMessage(table, types),
    );
  }
   
  static AnalysisResult runCalculator(IsolateMessage message) {
    final Object dataPackage = switch (message) {
      RawDataMessage m => m.table,
      TransferableDataMessage m => m.dataPackage,
    };
    final worker = CalculateUsecase(dataPackage, message.columnTypes);
    return worker.run();
  }

  static AnalysisResult _isolateHandler(IsolateMessage message) {
    // 1. Handle Debug Delay (Synchronously)
    // Inside an isolate, use sleep() instead of Future.delayed to block execution
    // without returning a Future.
    sleep(Duration(milliseconds: SpreadsheetConstants.debugDelayMs));

    // 2. Run the calculation
    // You must move the logic of 'runCalculator' here, or make runCalculator
    // static and pass 'message' to it.
    return runCalculator(message);
  }
}