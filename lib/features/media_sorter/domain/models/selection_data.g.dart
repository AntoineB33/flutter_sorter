// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selection_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SelectionState _$SelectionStateFromJson(Map<String, dynamic> json) =>
    SelectionState(
      primarySelection: CellPosition.fromJson(
        json['primarySelection'] as Map<String, dynamic>,
      ),
      selectedCells: (json['selectedCells'] as List<dynamic>)
          .map((e) => CellPosition.fromJson(e as Map<String, dynamic>))
          .toSet(),
    );

Map<String, dynamic> _$SelectionStateToJson(SelectionState instance) =>
    <String, dynamic>{
      'primarySelection': instance.primarySelection.toJson(),
      'selectedCells': instance.selectedCells.map((e) => e.toJson()).toList(),
    };

SelectionData _$SelectionDataFromJson(Map<String, dynamic> json) =>
    SelectionData(
      selectionStates: (json['selectionStates'] as List<dynamic>)
          .map((e) => SelectionState.fromJson(e as Map<String, dynamic>))
          .toList(),
      primSelHistoryId: (json['primSelHistoryId'] as num).toInt(),
    );

Map<String, dynamic> _$SelectionDataToJson(
  SelectionData instance,
) => <String, dynamic>{
  'selectionStates': instance.selectionStates.map((e) => e.toJson()).toList(),
  'primSelHistoryId': instance.primSelHistoryId,
};
