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

  Future<void> saveLastOpenedSheetName(String sheetName) {
    // Assuming the repository has a method to save the last opened sheet name
    return repository.saveLastOpenedSheetName(sheetName);
  }

  Future<void> saveAllSheetNames(List<String> sheetNames) {
    // Assuming the repository has a method to save all sheet names
    // You might need to implement this method in the repository if it doesn't exist
    return repository.saveAllSheetNames(sheetNames);
  }
}
