// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cell_position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CellPosition _$CellPositionFromJson(Map<String, dynamic> json) => CellPosition(
  (json['rowId'] as num).toInt(),
  (json['colId'] as num).toInt(),
);

Map<String, dynamic> _$CellPositionToJson(CellPosition instance) =>
    <String, dynamic>{'rowId': instance.rowId, 'colId': instance.colId};
