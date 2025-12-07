import '../repositories/sheet_repository.dart';

class SaveSheetDataUseCase {
  final SheetRepository repository;

  SaveSheetDataUseCase(this.repository);

  Future<void> execute(String sheetName, List<List<String>> data) {
    return repository.updateSheet(sheetName, data);
  }
}