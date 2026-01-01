import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';
import 'dart:math';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';

class GetSheetDataUseCase {
  final SheetRepository repository;

  GetSheetDataUseCase(this.repository);

  Future<Point<int>> getLastSelectedCell() {
    return repository.getLastSelectedCell();
  }

  Future<String> getLastOpenedSheetName() {
    return repository.getLastOpenedSheetName();
  }

  Future<List<String>> getAllSheetNames() {
    return repository.getAllSheetNames();
  }

  Future<Map<String, Point<int>>> getAllLastSelected() async {
    return await repository.getAllLastSelected();
  }

  Future<SheetModel> loadSheet(String sheetName) {
    return repository.loadSheet(sheetName);
  }
}
