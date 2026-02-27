import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';
import 'package:uuid/uuid.dart';

class ParsePasteDataUseCase {
  final LoadedSheetsDataStore loadedSheetDataStore;

  ParsePasteDataUseCase(this.loadedSheetDataStore);

  UpdateData pasteText(String rawText, int startRow, int startCol) {
    final List<UpdateUnit> updates = [];
    final rows = rawText.split('\n');

    for (int r = 0; r < rows.length; r++) {
      final columns = rows[r].split('\t');
      for (int c = 0; c < columns.length; c++) {
        String val = columns[c].replaceAll('\r', '');
        updates.add(
          CellUpdate(
            startRow + r,
            startCol + c,
            val,
            loadedSheetDataStore.getCellContent(startRow + r, startCol + c),
          ),
        );
      }
    }
    return UpdateData(
      Uuid().v4(),
      DateTime.now(),
      updates,
    );
  }
}
