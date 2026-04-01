import 'dart:convert';
import 'dart:isolate';

import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/data/services/calculate_service.dart';
import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/core_sheet_content.dart';

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
    
    final worker = CalculateService(sheetContent);
    AnalysisResult result = worker.run();
    Isolate.exit(
      sendPort,
      AnalysisReturn(result, true, result.errorChildren.isEmpty),
    );
  }
}
