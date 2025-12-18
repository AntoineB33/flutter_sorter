import 'dart:math';

import '../repositories/sheet_repository.dart';

class SaveSheetDataUseCase {
  final SheetRepository repository;

  SaveSheetDataUseCase(this.repository);

  Future<void> saveLastSelectedCell(Point<int> cell) {
    return repository.saveLastSelectedCell(cell);
  }

  Future<void> saveSheet(
    String sheetName,
    List<List<String>> table,
    List<String> columnTypes
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

  Future<void> saveAllLastSelected(Map<String, Point<int>> cells) {
    return repository.saveAllLastSelected(cells);
  }

  Future<void> clearAllData() {
    return repository.clearAllData();
  }
}
