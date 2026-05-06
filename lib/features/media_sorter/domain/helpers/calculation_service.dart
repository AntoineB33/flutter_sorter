import 'dart:isolate';

import 'package:trying_flutter/features/media_sorter/domain/models/isolate_message.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/data/services/calculate_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/core_sheet_content.dart';

class AnalysisReturn {
  final AnalysisResult result;
  final bool changed;

  AnalysisReturn(this.result, this.changed);
}

class CalculationService {
  static Future<void> runCalculation(IsolateMessage args) async {
    SendPort sendPort = args.sendPort;
    CoreSheetContent sheetContent = args.sheetContent;
    // AnalysisResult prevResult = args.prevResult;

    final worker = CalculateService(sheetContent);
    final result = worker.run();
    Isolate.exit(
      sendPort,
      AnalysisReturn(result, true),
    );
  }
}
