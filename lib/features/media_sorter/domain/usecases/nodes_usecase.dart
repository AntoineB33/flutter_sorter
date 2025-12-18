import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';

class NodesUsecase {
  final AnalysisResult analysisResult;

  NodesUsecase(this.analysisResult);
  
  String getRowName(row) {
    List<String> rowNames = [];
    for (final index in analysisResult.nameIndexes) {
      for (final name in analysisResult.tableToAtt[row][index]) {
        if (name.name != null) {
          rowNames.add(name.name!);
        }
      }
    }
    return 'Row $row: ${rowNames.join(', ')}';
  }

  String getColumnLabel(int col) {
    String columnLabel = "";
    int tempCol = col + 1; // Excel columns start at 1, not 0

    // Convert column number to letters (e.g., 1 -> A, 27 -> AA)
    while (tempCol > 0) {
      int remainder = (tempCol - 1) % 26;
      columnLabel = String.fromCharCode(65 + remainder) + columnLabel;
      tempCol = (tempCol - 1) ~/ 26;
    }

    return columnLabel;
  }
}