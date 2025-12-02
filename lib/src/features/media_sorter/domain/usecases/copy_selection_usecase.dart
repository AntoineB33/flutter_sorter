import 'dart:math';
import '../../../../core/services/clipboard_service.dart'; // The service we defined previously
import '../repositories/i_spreadsheet_data_repository.dart';

class CopySelectionUseCase {
  final ISpreadsheetDataRepository _repository;
  final IClipboardService _clipboardService;

  CopySelectionUseCase(this._repository, this._clipboardService);

  Future<String?> execute(Point<int> start, Point<int> end) async {
    // 1. Get the authoritative data from the Repository
    final table = _repository.table;

    // 2. Normalize coordinates
    final r1 = min(start.x, end.x);
    final r2 = max(start.x, end.x);
    final c1 = min(start.y, end.y);
    final c2 = max(start.y, end.y);

    final buffer = StringBuffer();

    // 3. Extract and Format (Business Logic)
    for (int r = r1; r <= r2; r++) {
      if (r >= table.length) break;
      final rowValues = <String>[];
      for (int c = c1; c <= c2; c++) {
        rowValues.add((c < table[r].length) ? table[r][c] : '');
      }
      buffer.writeln(rowValues.join('\t'));
    }

    // 4. Send to Infrastructure
    await _clipboardService.copyText(buffer.toString().trimRight());
  }
}