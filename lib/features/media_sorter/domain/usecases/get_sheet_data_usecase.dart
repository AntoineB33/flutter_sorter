import '../repositories/sheet_repository.dart';
import 'dart:math';

class GetSheetDataUseCase {
  final SheetRepository repository;

  GetSheetDataUseCase(this.repository);

  Future<String> getLastOpenedSheetName() {
    return repository.getLastOpenedSheetName();
  }

  Future<List<String>> getAllSheetNames() {
    return repository.getAllSheetNames();
  }

  Future<(List<List<String>>, List<String>, Point<int>, Point<int>)> loadSheet(String sheetName) {
    return repository.loadSheet(sheetName);
  }
}
