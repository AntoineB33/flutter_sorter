abstract class SheetDataRepository {
  String get currentSheetId;
  int rowCount(String sheetId);
  int colCount(String sheetId);
  void delete();
}