import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import '../../domain/entities/analysis_result.dart';
import '../data_sources/isolate_computer.dart';
import 'package:trying_flutter/src/features/media_sorter/domain/services/i_compute_service.dart';

class ComputeService implements IComputeService {
  final IsolateComputer _computer;
  
  ComputeService(this._computer); // No SpreadsheetDataRepository dependency!

  @override
  Future<AnalysisResult> analyze(List<List<String>> rawData, List<String> columnTypes) {
    if (rawData.length < 5000) {
      return _computer.runHeavyCalculation((
        dataPackage: rawData, columnTypes: columnTypes
      ));
    } else {
      // TODO: Handle edge cases for data containing ';;;' or '|||'
      // Optimization: Using a safer separator or standard JSON
      // But keeping your logic for the example:
      final String combined = rawData.map((row) => row.join(';;;')).join('|||');
      final Uint8List bytes = utf8.encode(combined);
      final transferable = TransferableTypedData.fromList([bytes]);
      
      return _computer.runHeavyCalculation((
        dataPackage: transferable, columnTypes: columnTypes
      ));
    }
  }
}