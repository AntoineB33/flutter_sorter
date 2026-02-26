// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cell.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cell _$CellFromJson(Map<String, dynamic> json) => Cell(
      rowId: (json['rowId'] as num).toInt(),
      colId: (json['colId'] as num).toInt(),
    );

Map<String, dynamic> _$CellToJson(Cell instance) => <String, dynamic>{
      'rowId': instance.rowId,
      'colId': instance.colId,
    };
