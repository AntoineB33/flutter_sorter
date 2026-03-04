abstract class SortRepository {
  Stream<void> get progressStream;
  void sortMedia(String sheetId);
  Future<void> calculateOnChange();
}