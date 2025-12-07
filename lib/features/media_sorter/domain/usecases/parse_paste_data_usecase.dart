class ParsePasteDataUseCase {
  List<CellUpdate> call(String rawText, int startRow, int startCol) {
    final List<CellUpdate> updates = [];
    final rows = rawText.split('\n');
    
    for (int r = 0; r < rows.length; r++) {
      final columns = rows[r].split('\t');
      for (int c = 0; c < columns.length; c++) {
        String val = columns[c].replaceAll('\r', '');
        updates.add(CellUpdate(
          row: startRow + r, 
          col: startCol + c, 
          value: val
        ));
      }
    }
    return updates;
  }
}

// simple DTO
class CellUpdate {
  final int row;
  final int col;
  final String value;
  CellUpdate({required this.row, required this.col, required this.value});
}