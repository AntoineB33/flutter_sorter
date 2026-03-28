import 'package:trying_flutter/features/media_sorter/domain/entities/layout_data.dart';

class LayoutCache {
  final Map<int, LayoutData> _layouts = {};

  LayoutData getLayout(int sheetId) {
    return _layouts[sheetId]!;
  }
}
