
import '../entities/analysis_result.dart';

abstract class IComputeService {
  // It takes the data AS PARAMETERS, not from a hidden repo
  Future<AnalysisResult> analyze(List<List<String>> data, List<String> types);
}