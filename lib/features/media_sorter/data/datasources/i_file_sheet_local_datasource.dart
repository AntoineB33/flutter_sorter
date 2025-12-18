abstract class IFileSheetLocalDataSource {
  Future<Map<String, dynamic>> getSheet(String sheetName);
  Future<void> saveSheet(String sheetName, Map<String, dynamic> data);
}