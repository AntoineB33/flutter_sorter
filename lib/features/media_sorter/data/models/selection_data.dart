import 'package:json_annotation/json_annotation.dart';
import 'package:trying_flutter/features/media_sorter/data/models/update_data.dart';

part 'selection_data.g.dart';

@JsonSerializable(explicitToJson: true)
class SelectionState {
  final CellPosition primarySelection;
  final Set<CellPosition> selectedCells;

  SelectionState({required this.primarySelection, required this.selectedCells});

  factory SelectionState.empty() => SelectionState(
    primarySelection: CellPosition(0, 0),
    selectedCells: {CellPosition(0, 0)},
  );

  factory SelectionState.fromJson(Map<String, dynamic> json) => _$SelectionStateFromJson(json);

  Map<String, dynamic> toJson() => _$SelectionStateToJson(this);
  // ignore: unused_element
  static void _keepLinterHappy() => SelectionState.empty().toJson();
}

@JsonSerializable(explicitToJson: true)
class SelectionData {
  final List<SelectionState> selectionStates;
  final int primSelHistoryId;

  SelectionData({
    required this.selectionStates,
    required this.primSelHistoryId,
  });

  SelectionData.empty()
    : selectionStates = [SelectionState.empty()],
      primSelHistoryId = 0;

  SelectionData copyWith({
    List<SelectionState>? selectionStates,
    int? primSelHistoryId,
  }) {
    return SelectionData(
      selectionStates: selectionStates ?? this.selectionStates,
      primSelHistoryId: primSelHistoryId ?? this.primSelHistoryId,
    );
  }

  factory SelectionData.fromJson(Map<String, dynamic> json) => _$SelectionDataFromJson(json);

  Map<String, dynamic> toJson() => _$SelectionDataToJson(this);
  // ignore: unused_element
  static void _keepLinterHappy() => SelectionData.empty().toJson();
}
