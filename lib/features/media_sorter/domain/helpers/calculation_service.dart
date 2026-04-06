import 'dart:isolate';

import 'package:trying_flutter/features/media_sorter/data/models/isolate_message.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/data/services/calculate_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/core_sheet_content.dart';

class AnalysisReturn {
  final AnalysisResult result;
  final bool changed;
  final bool toFindValidSort;

  AnalysisReturn(this.result, this.changed, this.toFindValidSort);
}

class CalculationService {
  static Future<void> runCalculation(IsolateMessage args) async {
    SendPort sendPort = args.sendPort;
    CoreSheetContent sheetContent = args.sheetContent;
    // AnalysisResult prevResult = args.prevResult;

    final worker = CalculateService(sheetContent);
    AnalysisResult result = worker.run();
    Isolate.exit(
      sendPort,
      AnalysisReturn(result, true, result.errorChildren.isEmpty),
    );
  }
}
