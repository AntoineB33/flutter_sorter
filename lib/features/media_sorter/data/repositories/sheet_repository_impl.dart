import 'dart:math';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';

class SheetRepositoryImpl implements SheetRepository {
  final FileSheetLocalDataSource dataSource;

  SheetRepositoryImpl(this.dataSource);

  @override
  Future<Point<int>> getLastSelectedCell() async {
    final cellMap = await dataSource.getLastSelectedCell();
    return Point<int>(cellMap["x"]!, cellMap["y"]!);
  }

  @override
  Future<void> saveLastSelectedCell(Point<int> selectionStart) async {
    final cell = {"x": selectionStart.x, "y": selectionStart.y};
    await dataSource.saveLastSelectedCell(cell);
  }

  @override
  Future<String> getLastOpenedSheetName() async {
    return await dataSource.getLastOpenedSheetName();
  }

  @override
  Future<void> saveLastOpenedSheetName(String sheetName) async {
    await dataSource.saveLastOpenedSheetName(sheetName);
  }

  @override
  Future<List<String>> getAllSheetNames() async {
    return await dataSource.getAllSheetNames();
  }

  @override
  Future<void> saveAllSheetNames(List<String> sheetNames) async {
    await dataSource.saveAllSheetNames(sheetNames);
  }

  @override
  Future<(List<List<String>> table, List<String> columnTypes)> loadSheet(
    String sheetName,
  ) async {
    final mapData = await dataSource.getSheet(sheetName);
    final sheet = SheetModel.fromJson(mapData);
    return (sheet.table, sheet.columnTypes);
  }

  @override
  Future<void> updateSheet(
    String sheetName,
    List<List<String>> table,
    List<String> columnTypes,
  ) async {
    final data = {"table": table, "columnTypes": columnTypes};
    return await dataSource.saveSheet(sheetName, data);
  }

  @override
  Future<Map<String, Point<int>>> getAllLastSelected() async {
    final cellMaps = await dataSource.getAllLastSelected();
    return cellMaps.map(
      (key, cellMap) => MapEntry(key, Point<int>(cellMap["x"]!, cellMap["y"]!)),
    );
  }

  @override
  Future<void> saveAllLastSelected(Map<String, Point<int>> cells) async {
    final cellList = cells.map(
      (key, cell) => MapEntry(key, {"x": cell.x, "y": cell.y}),
    );
    await dataSource.saveAllLastSelected(cellList);
  }

  @override
  Future<void> clearAllData() async {
    await dataSource.clearAllData();
  }
}
