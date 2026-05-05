import 'package:trying_flutter/features/media_sorter/domain/models/layout_data.dart';

class LayoutCache {
  final Map<int, LayoutData> _layouts = {};

  LayoutData getLayout(int sheetId) {
    return _layouts[sheetId]!;
  }

  void setLayout(int sheetId, LayoutData layoutData) {
    _layouts[sheetId] = layoutData;
  }
}
