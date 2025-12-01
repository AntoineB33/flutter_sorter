abstract class ISpreadsheetDataRepository {
  List<List<String>> get table;
  List<String> get columnTypes;
}