import '../repositories/sheet_repository.dart';

class SaveSheetDataUseCase {
  final SheetRepository repository;

  SaveSheetDataUseCase(this.repository);

  Future<void> saveSheet(
    String sheetName,
    List<List<String>> table,
    List<String> columnTypes,
  ) {
    return repository.updateSheet(sheetName, table, columnTypes);
  }
}
