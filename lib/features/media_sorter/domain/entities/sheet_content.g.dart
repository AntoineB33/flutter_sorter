// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SheetContent _$SheetContentFromJson(Map<String, dynamic> json) => SheetContent(
      table: (json['table'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as String).toList())
          .toList(),
      columnTypes: (json['columnTypes'] as List<dynamic>)
          .map((e) => $enumDecode(_$ColumnTypeEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$SheetContentToJson(SheetContent instance) =>
    <String, dynamic>{
      'table': instance.table,
      'columnTypes':
          instance.columnTypes.map((e) => _$ColumnTypeEnumMap[e]!).toList(),
    };

const _$ColumnTypeEnumMap = {
  ColumnType.names: 'names',
  ColumnType.dependencies: 'dependencies',
  ColumnType.sprawl: 'sprawl',
  ColumnType.attributes: 'attributes',
  ColumnType.filePath: 'filePath',
  ColumnType.urls: 'urls',
};
