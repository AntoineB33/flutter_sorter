import '../entities/cell.dart';
import '../repositories/spreadsheet_repository.dart';

// UseCase 1: Fetching the sheet data
class GetSheetUseCase {
  final SpreadsheetRepository _repository;

  GetSheetUseCase(this._repository);

  Future<Map<String, Cell>> execute(String sheetId) {
    return _repository.getSheet(sheetId);
  }
}

// UseCase 2: Updating a single cell
class UpdateCellUseCase {
  final SpreadsheetRepository _repository;

  UpdateCellUseCase(this._repository);

  Future<void> execute(String sheetId, int row, int col, String value) {
    return _repository.updateCell(sheetId, row, col, value);
  }
}