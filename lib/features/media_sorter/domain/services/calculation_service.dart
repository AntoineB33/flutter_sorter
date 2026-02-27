import 'dart:convert';
import 'dart:isolate';

import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort/calculate_usecase.dart';
import 'dart:io';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/isolate_message.dart';

class AnalysisReturn {
  final AnalysisResult result;
  final bool changed;
  final bool noSortToFind;
  final bool toFindValidSort;

  AnalysisReturn(this.result, this.changed, this.noSortToFind, this.toFindValidSort);
}

class CalculationService {
  static Future<void> runCalculation(List<dynamic> args) async {
    SendPort sendPort = args[0];
    SheetContent sheetContent = args[1];
    AnalysisResult prevResult = args[2];
    AnalysisResult result = _isolateHandler(getMessage(sheetContent));
    Isolate.exit(sendPort, AnalysisReturn(result, true, false, true));
  }
  
  static IsolateMessage getMessage(SheetContent sheetContent) {
    if (sheetContent.table.length < 5000) {
      return IsolateMessage(Right(sheetContent.table), sheetContent.columnTypes);
    } else {
      final String combined = jsonEncode(sheetContent.table);
      final Uint8List bytes = utf8.encode(combined);
      final transferable = TransferableTypedData.fromList([bytes]);
      return IsolateMessage(Left(transferable), sheetContent.columnTypes);
    }
  }

  static AnalysisResult _isolateHandler(IsolateMessage message) {
    final worker = CalculateUsecase(message);
    return worker.run();
  }
}