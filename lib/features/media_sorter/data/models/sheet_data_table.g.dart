// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_data_table.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncRequestWithoutHist _$SyncRequestWithoutHistFromJson(
  Map<String, dynamic> json,
) => SyncRequestWithoutHist(
  DbCompanionWrapper.fromJson(json['companionWrapper'] as Map<String, dynamic>),
  $enumDecode(_$DataBaseOperationTypeEnumMap, json['dataBaseOperationType']),
);

Map<String, dynamic> _$SyncRequestWithoutHistToJson(
  SyncRequestWithoutHist instance,
) => <String, dynamic>{
  'companionWrapper': instance.companionWrapper.toJson(),
  'dataBaseOperationType':
      _$DataBaseOperationTypeEnumMap[instance.dataBaseOperationType]!,
};

const _$DataBaseOperationTypeEnumMap = {
  DataBaseOperationType.insert: 'insert',
  DataBaseOperationType.update: 'update',
  DataBaseOperationType.delete: 'delete',
  DataBaseOperationType.deleteWhere: 'deleteWhere',
};
