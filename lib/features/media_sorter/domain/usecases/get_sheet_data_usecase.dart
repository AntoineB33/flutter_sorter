import '../entities/spreadsheet_cell.dart';
import '../repositories/spreadsheet_repository.dart';

class GetSheetDataUseCase {
  final SpreadsheetRepository repository;
  GetSheetDataUseCase(this.repository);

  Future<List<SpreadsheetCell>> execute() {
    return repository.loadSheet();
  }
}