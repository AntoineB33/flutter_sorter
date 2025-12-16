import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'dart:math';

class SheetRepositoryImpl implements SheetRepository {
  final FileSheetLocalDataSource dataSource;

  SheetRepositoryImpl(this.dataSource);

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
  Future<(List<List<String>> table, List<String> columnTypes, Point<int>, Point<int>)> loadSheet(String sheetName) async {
    Map<String, dynamic> mapData = await dataSource.getSheet(sheetName);
    final rawTable = mapData["table"] as List?;
    final rawColumnTypes = mapData["columnTypes"] as List?;
    List<List<String>> table = rawTable?.map((row) {
      // Convert each row (which is a List) into a List<String>
      return (row as List).map((cell) => cell.toString()).toList();
    }).toList() ?? [];
    List<String> columnTypes = rawColumnTypes?.map((type) => type.toString()).toList() ?? [];
    
    final startMap = mapData['selectionStart'] ?? {"x": 0, "y": 0};
    final endMap = mapData['selectionEnd'] ?? {"x": 0, "y": 0};
    final selectionStart = Point<int>(startMap['x'] as int, startMap['y'] as int);
    final selectionEnd = Point<int>(endMap['x'] as int, endMap['y'] as int);
    return (table, columnTypes, selectionStart, selectionEnd);
  }

  @override
  Future<void> updateSheet(String sheetName, List<List<String>> table, List<String> columnTypes, Point<int> selectionStart, Point<int> selectionEnd) async {
    final data = {
      "table": table,
      "columnTypes": columnTypes,
      "selectionStart": {"x": selectionStart.x, "y": selectionStart.y},
      "selectionEnd": {"x": selectionEnd.x, "y": selectionEnd.y},
    };
    return await dataSource.saveSheet(sheetName, data);
  }

  @override
  Future<void> clearAllData() async {
    await dataSource.clearAllData();
  }
}