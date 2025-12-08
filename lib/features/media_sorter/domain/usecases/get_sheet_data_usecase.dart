import '../entities/spreadsheet_cell.dart';
import '../repositories/sheet_repository.dart';

class GetSheetDataUseCase {
  final SheetRepository repository;

  GetSheetDataUseCase(this.repository);

  Future<String> getLastOpenedSheetName() {
    return repository.getLastOpenedSheetName();
  }

  Future<List<String>> getAllSheetNames() {
    return repository.getAllSheetNames();
  }

  Future<Map<String, dynamic>> loadSheet(String sheetName) {
    return repository.loadSheet(sheetName);
  }
}
