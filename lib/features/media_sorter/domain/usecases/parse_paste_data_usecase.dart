import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';

class ParsePasteDataUseCase {
  List<UpdateData> pasteText(String rawText, int startRow, int startCol) {
    final List<UpdateData> updates = [];
    final rows = rawText.split('\n');

    for (int r = 0; r < rows.length; r++) {
      final columns = rows[r].split('\t');
      for (int c = 0; c < columns.length; c++) {
        String val = columns[c].replaceAll('\r', '');
        updates.add(
          CellUpdate(rowId: startRow + r, colId: startCol + c, newValue: val),
        );
      }
    }
    return updates;
  }
}
