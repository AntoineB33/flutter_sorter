// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_struct.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeStruct _$NodeStructFromJson(Map<String, dynamic> json) => NodeStruct(
      instruction: json['instruction'] as String?,
      message: json['message'] as String?,
      rowId: (json['rowId'] as num?)?.toInt(),
      colId: (json['colId'] as num?)?.toInt(),
      name: json['name'] as String?,
      att: json['att'] == null
          ? null
          : Attribute.fromJson(json['att'] as Map<String, dynamic>),
      cell: json['cell'] == null
          ? null
          : Cell.fromJson(json['cell'] as Map<String, dynamic>),
      cells: (json['cells'] as List<dynamic>?)
          ?.map((e) => Cell.fromJson(e as Map<String, dynamic>))
          .toList(),
      dist: (json['dist'] as num?)?.toInt(),
      minDist: (json['minDist'] as num?)?.toInt(),
      newChildren: (json['newChildren'] as List<dynamic>?)
          ?.map((e) => NodeStruct.fromJson(e as Map<String, dynamic>))
          .toList(),
      hideIfEmpty: json['hideIfEmpty'] as bool? ?? false,
      startOpen: json['startOpen'] as bool? ?? false,
    )
      ..children = (json['children'] as List<dynamic>)
          .map((e) => NodeStruct.fromJson(e as Map<String, dynamic>))
          .toList()
      ..isExpanded = json['isExpanded'] as bool
      ..idOnTap = json['idOnTap'] as String?
      ..defaultOnTap = json['defaultOnTap'] as bool
      ..cellsToSelect = (json['cellsToSelect'] as List<dynamic>?)
          ?.map((e) => Cell.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$NodeStructToJson(NodeStruct instance) =>
    <String, dynamic>{
      'instruction': instance.instruction,
      'message': instance.message,
      'cell': instance.cell,
      'att': instance.att,
      'rowId': instance.rowId,
      'colId': instance.colId,
      'cells': instance.cells,
      'name': instance.name,
      'dist': instance.dist,
      'minDist': instance.minDist,
      'children': instance.children,
      'newChildren': instance.newChildren,
      'hideIfEmpty': instance.hideIfEmpty,
      'startOpen': instance.startOpen,
      'isExpanded': instance.isExpanded,
      'idOnTap': instance.idOnTap,
      'defaultOnTap': instance.defaultOnTap,
      'cellsToSelect': instance.cellsToSelect,
    };
