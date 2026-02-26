// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selection_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SelectionData _$SelectionDataFromJson(Map<String, dynamic> json) =>
    SelectionData(
      selectedCells: (json['selectedCells'] as List<dynamic>)
          .map(
              (e) => const PointConverter().fromJson(e as Map<String, dynamic>))
          .toList(),
      primarySelectedCell: const PointConverter()
          .fromJson(json['primarySelectedCell'] as Map<String, dynamic>),
      scrollOffsetX: (json['scrollOffsetX'] as num).toDouble(),
      scrollOffsetY: (json['scrollOffsetY'] as num).toDouble(),
      editingMode: json['editingMode'] as bool,
      previousContent: json['previousContent'] as String,
    );

Map<String, dynamic> _$SelectionDataToJson(SelectionData instance) =>
    <String, dynamic>{
      'selectedCells':
          instance.selectedCells.map(const PointConverter().toJson).toList(),
      'primarySelectedCell':
          const PointConverter().toJson(instance.primarySelectedCell),
      'scrollOffsetX': instance.scrollOffsetX,
      'scrollOffsetY': instance.scrollOffsetY,
      'editingMode': instance.editingMode,
      'previousContent': instance.previousContent,
    };
