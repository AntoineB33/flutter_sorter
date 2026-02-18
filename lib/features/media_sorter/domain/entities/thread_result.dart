
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';

class ThreadResult {
  final AnalysisResult result;
  final bool changed;
  final bool startSorter;

  ThreadResult(this.result, this.changed, this.startSorter);
}