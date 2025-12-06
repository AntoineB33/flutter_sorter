import 'package:isar/isar.dart';
import '../models/cell_model.dart';

class TableLocalDataSource {
  final Isar isar;

  TableLocalDataSource(this.isar);

  /// Fetches a rectangular region of cells efficiently.
  Future<List<CellModel>> fetchCellChunk({
    required int minRow, 
    required int maxRow, 
    required int minCol, 
    required int maxCol
  }) async {
    return await isar.cellModels
        .filter()
        .rowBetween(minRow, maxRow) // Uses the index
        .and()
        .colBetween(minCol, maxCol) // Filters the columns within those rows
        .findAll();
  }

  Future<void> saveCell({
    required int row, 
    required int col, 
    required String value
  }) async {
    await isar.writeTxn(() async {
      // 1. Check if cell exists
      final existingCell = await isar.cellModels
          .filter()
          .rowEqualTo(row)
          .and()
          .colEqualTo(col)
          .findFirst();

      if (existingCell != null) {
        // 2. Update existing
        existingCell.value = value;
        await isar.cellModels.put(existingCell);
      } else {
        // 3. Create new
        final newCell = CellModel()
          ..row = row
          ..col = col
          ..value = value;
        await isar.cellModels.put(newCell);
      }
    });
  }
}