// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attribute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attribute _$AttributeFromJson(Map<String, dynamic> json) => Attribute(
      name: json['name'] as String?,
      colId: (json['colId'] as num?)?.toInt(),
    )..rowId = (json['rowId'] as num?)?.toInt();

Map<String, dynamic> _$AttributeToJson(Attribute instance) => <String, dynamic>{
      'name': instance.name,
      'rowId': instance.rowId,
      'colId': instance.colId,
    };
