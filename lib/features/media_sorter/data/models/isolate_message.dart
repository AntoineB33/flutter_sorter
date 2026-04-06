import 'dart:isolate';

import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/core_sheet_content.dart';

class IsolateMessage {
  final SendPort sendPort;
  final CoreSheetContent sheetContent;
  final AnalysisResult prevResult;

  IsolateMessage(this.sendPort, this.sheetContent, this.prevResult);
}