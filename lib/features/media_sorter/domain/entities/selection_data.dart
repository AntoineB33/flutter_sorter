import 'dart:collection';

import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

class SelectionData {
  final Set<CellPosition> selectedCells;
  final List<CellPosition> primSelHistory;
  final int primSelHistoryId;

  SelectionData({
    required this.selectedCells,
    required this.primSelHistory,
    required this.primSelHistoryId,
  });

  SelectionData.empty()
      :
      selectedCells = <CellPosition>{},
      primSelHistory = [],
      primSelHistoryId = -1;

  SelectionData copyWith({
    Set<CellPosition>? selectedCells,
    List<CellPosition>? primSelHistory,
    int? primSelHistoryId,
  }) {
    return SelectionData(
      selectedCells: selectedCells ?? this.selectedCells,
      primSelHistory: primSelHistory ?? this.primSelHistory,
      primSelHistoryId: primSelHistoryId ?? this.primSelHistoryId,
    );
  }
}