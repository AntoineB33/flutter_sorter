import 'package:flutter/services.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';


class SpreadsheetClipboardService {
  final SheetDataController dataController;

  SpreadsheetClipboardService(this.dataController);

  Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<String?> getText() async {
    final data = await Clipboard.getData('text/plain');
    return data?.text;
  }
}