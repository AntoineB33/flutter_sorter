abstract class SheetLocalDataSource {
  Future<List<List<String>>> getSheet(String sheetName);
  Future<void> saveSheet(String sheetName, List<List<String>> data);
}