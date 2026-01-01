import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';

abstract class IFileSheetLocalDataSource {
  Future<SheetModel> getSheet(String sheetName);
  Future<void> saveSheet(String sheetName, SheetModel sheet);
}