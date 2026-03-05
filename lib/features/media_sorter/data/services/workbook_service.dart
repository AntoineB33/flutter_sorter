class WorkbookService {
  static bool isValidSheetName(String name) {
    return name.isNotEmpty &&
        !name.contains(RegExp(r'[\\/:*?"<>|]'));
  }
}