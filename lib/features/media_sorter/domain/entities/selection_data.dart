import 'dart:collection';

import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

class SelectionData {
  final Set<CellPosition> selectedCells;

  SelectionData({
    required this.selectedCells,
  });

  SelectionData.empty()
      :
      selectedCells = Set();
}