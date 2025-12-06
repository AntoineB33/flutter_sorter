import '../repositories/spreadsheet_repository.dart';

class SaveCellUseCase {
  final SpreadsheetRepository repository;

  SaveCellUseCase(this.repository);

  Future<void> call(int row, int col, String value) {
    return repository.updateCell(row, col, value);
  }
}