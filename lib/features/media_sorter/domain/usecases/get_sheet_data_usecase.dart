import 'package:flutter/foundation.dart';

import '../repositories/sheet_repository.dart';
import 'dart:math';

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

  Future<Map<String, Point<int>>> getAllLastSelected(List<String> sheetNames) async {
    Map<String, Point<int>> result = await repository.getAllLastSelected();
    for (var name in sheetNames) {
      if (!result.containsKey(name)) {
        result[name] = Point(0, 0);
        debugPrint("No last selected cell for sheet $name, defaulting to (0,0)");
      }
    }
    return result;
  }

  Future<(List<List<String>>, List<String>)> loadSheet(String sheetName) {
    return repository.loadSheet(sheetName);
  }
}
