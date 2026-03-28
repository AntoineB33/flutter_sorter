import 'dart:convert';
import 'dart:isolate';

import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/data/services/calculate_service.dart';
import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/isolate_message.dart';

class AnalysisReturn {
  final AnalysisResult result;
  final bool changed;
  final bool toFindValidSort;

  AnalysisReturn(this.result, this.changed, this.toFindValidSort);
}

class CalculationService {
  static Future<void> runCalculation(List<dynamic> args) async {
    SendPort sendPort = args[0];
    CoreSheetContent sheetContent = args[1];
    // AnalysisResult prevResult = args[2];
    AnalysisResult result = _isolateHandler(getMessage(sheetContent));
    Isolate.exit(
      sendPort,
      AnalysisReturn(result, true, result.errorChildren.isEmpty),
    );
  }

  static IsolateMessage getMessage(CoreSheetContent sheetContent) {
    if (sheetContent.lastRow < 5000) {
      return IsolateMessage(
        Right(sheetContent.cells),
        sheetContent.columnTypes,
      );
    } else {
      final String combined = jsonEncode(sheetContent.cells);
      final Uint8List bytes = utf8.encode(combined);
      final transferable = TransferableTypedData.fromList([bytes]);
      return IsolateMessage(Left(transferable), sheetContent.columnTypes);
    }
  }

  static AnalysisResult _isolateHandler(IsolateMessage message) {
    final worker = CalculateService(message);
    return worker.run();
  }
}
