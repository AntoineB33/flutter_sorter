import 'dart:convert';
import 'dart:isolate';

import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/calculate_usecase.dart';
import 'dart:io';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/isolate_message.dart';

class CalculationService {
  Future<AnalysisResult> runCalculation(List<List<String>> table, List<ColumnType> types) async {
    return compute(
      _isolateHandler,
      getMessage(table, types),
    );
  }
  
  IsolateMessage getMessage(
    List<List<String>> table,
    List<ColumnType> columnTypes,
  ) {
    if (table.length < 5000) {
      return IsolateMessage(Right(table), columnTypes);
    } else {
      final String combined = jsonEncode(table);
      final Uint8List bytes = utf8.encode(combined);
      final transferable = TransferableTypedData.fromList([bytes]);
      return IsolateMessage(Left(transferable), columnTypes);
    }
  }

  static AnalysisResult _isolateHandler(IsolateMessage message) {
    sleep(Duration(milliseconds: SpreadsheetConstants.debugDelayMs));
    final worker = CalculateUsecase(message.table, message.columnTypes);
    return worker.run();
  }
}