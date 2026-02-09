import 'package:flutter/services.dart';


class SpreadsheetClipboardService {

  SpreadsheetClipboardService();

  Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<String?> getText() async {
    final data = await Clipboard.getData('text/plain');
    return data?.text;
  }
}