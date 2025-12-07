import '../entities/spreadsheet_cell.dart';
import '../repositories/sheet_repository.dart';

class GetSheetDataUseCase {
  final SheetRepository repository;

  GetSheetDataUseCase(this.repository);

  Future<String> getLastOpenedSheetName() {
    return repository.getLastOpenedSheetName();
  }

  Future<(List<List<String>>, List<String>)> execute(String sheetName) {
    return repository.loadSheet(sheetName);
  }
}