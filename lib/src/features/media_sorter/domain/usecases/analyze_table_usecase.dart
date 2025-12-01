import 'package:trying_flutter/src/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/src/features/media_sorter/domain/services/i_compute_service.dart';
import 'package:trying_flutter/src/features/media_sorter/domain/repositories/i_spreadsheet_data_repository.dart';

class AnalyzeTableUseCase {
  final IComputeService _computeService;
  final ISpreadsheetDataRepository _dataRepository;

  AnalyzeTableUseCase(this._computeService, this._dataRepository);

  Future<AnalysisResult> execute() async {
    // 1. Get Data from Source A
    final data = _dataRepository.table;
    final types = _dataRepository.columnTypes;

    // 2. Pass to Service B
    return await _computeService.analyze(data, types);
  }
}