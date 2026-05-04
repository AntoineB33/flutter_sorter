// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryData _$HistoryDataFromJson(Map<String, dynamic> json) => HistoryData(
  updateHistories: (json['updateHistories'] as List<dynamic>)
      .map((e) => UpdateHistoryModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  historyIndex: (json['historyIndex'] as num).toInt(),
);

Map<String, dynamic> _$HistoryDataToJson(
  HistoryData instance,
) => <String, dynamic>{
  'updateHistories': instance.updateHistories.map((e) => e.toJson()).toList(),
  'historyIndex': instance.historyIndex,
};
