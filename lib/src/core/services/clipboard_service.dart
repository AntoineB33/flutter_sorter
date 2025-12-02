import 'package:flutter/services.dart';

abstract class IClipboardService {
  Future<String?> copyText(String text);
}

class ClipboardService implements IClipboardService {
  @override
  Future<String?> copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}