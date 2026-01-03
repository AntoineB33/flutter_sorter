import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_model.dart';

class SheetRepositoryImpl implements SheetRepository {
  final FileSheetLocalDataSource dataSource;

  SheetRepositoryImpl(this.dataSource);

  @override
  Future<void> createFile(String fileName) async {
    await dataSource.createFile(fileName);
  }

  @override
  Future<SelectionModel> getLastSelection() async {
    return await dataSource.getLastSelection();
  }

  @override
  Future<void> saveLastSelection(SelectionModel selection) async {
    await dataSource.saveLastSelection(selection);
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
  Future<SheetModel> loadSheet(String sheetName) async {
    return await dataSource.getSheet(sheetName);
  }

  @override
  Future<void> updateSheet(String sheetName, SheetModel sheet) async {
    return await dataSource.saveSheet(sheetName, sheet);
  }

  @override
  Future<Map<String, SelectionModel>> getAllLastSelected() async {
    return await dataSource.getAllLastSelected();
  }

  @override
  Future<void> saveAllLastSelected(Map<String, SelectionModel> cells) async {
    await dataSource.saveAllLastSelected(cells);
  }

  @override
  Future<void> clearAllData() async {
    await dataSource.clearAllData();
  }
}
