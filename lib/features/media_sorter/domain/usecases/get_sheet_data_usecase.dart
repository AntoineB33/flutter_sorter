import '../entities/spreadsheet_cell.dart';
import '../repositories/spreadsheet_repository.dart';

class GetSheetDataUseCase {
  final SpreadsheetRepository repository;
  GetSheetDataUseCase(this.repository);

  Future<Map<(int, int), String>> call(int startRow, int endRow) {
    return repository.getRegion(startRow, endRow);
  }
}