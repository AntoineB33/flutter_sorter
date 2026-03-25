import 'package:trying_flutter/features/media_sorter/domain/entities/layout_data.dart';

class LayoutCache {
  final Map<String, LayoutData> _layouts = {};

  LayoutData getLayout(int sheetId) {
    return _layouts[sheetId]!;
  }

  double getScrollOffsetX(int sheetId) {
    return _layouts[sheetId]?.scrollOffsetX ?? 0.0;
  }

  double getScrollOffsetY(int sheetId) {
    return _layouts[sheetId]?.scrollOffsetY ?? 0.0;
  }
}
