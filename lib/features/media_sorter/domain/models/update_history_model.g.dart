// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateHistoryModel _$UpdateHistoryModelFromJson(Map<String, dynamic> json) =>
    UpdateHistoryModel(
      timestamp: DateTime.parse(json['timestamp'] as String),
      chronoId: (json['chronoId'] as num).toInt(),
      sheetId: (json['sheetId'] as num).toInt(),
      updates: (json['updates'] as List<dynamic>)
          .map(
            (e) => SyncRequestWithoutHist.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      type: $enumDecode(_$HistoryTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$UpdateHistoryModelToJson(UpdateHistoryModel instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'chronoId': instance.chronoId,
      'sheetId': instance.sheetId,
      'updates': instance.updates.map((e) => e.toJson()).toList(),
      'type': _$HistoryTypeEnumMap[instance.type]!,
    };

const _$HistoryTypeEnumMap = {
  HistoryType.selectionChange: 'selectionChange',
  HistoryType.editModeChange: 'editModeChange',
  HistoryType.other: 'other',
};
