import '../entities/cell.dart';
import '../../data/repositories/spreadsheet_repository_impl.dart';

class GetSheetUseCase {
  final SpreadsheetRepository repository;
  GetSheetUseCase(this.repository);

  Future<Map<String, Cell>> call() {
    return repository.loadSheet();
  }
}

class UpdateCellUseCase {
  final SpreadsheetRepository repository;
  UpdateCellUseCase(this.repository);

  Future<Cell> call(int row, int col, String value) {
    // Add business logic here (e.g., validate formulas)
    return repository.saveCell(row, col, value);
  }
}