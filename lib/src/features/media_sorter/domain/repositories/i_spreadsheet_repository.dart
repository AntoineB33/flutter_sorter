abstract class ISpreadsheetRepository {
  Future<void> saveSpreadsheet({
    required String name, 
    required List<List<String>> table, 
    required List<String> columnTypes
  });
}