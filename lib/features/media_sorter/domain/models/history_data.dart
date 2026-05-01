import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';

class HistoryUnit {
  final List<SyncRequestWithoutHistImpl> changeSet;
  final UpdateHistoriesTableCompanion timestamp;

  HistoryUnit({required this.changeSet, required this.timestamp});
}

@JsonSerializable(explicitToJson: true)
class HistoryData {
  List<HistoryUnit> updateHistories;
  int historyIndex;

  HistoryData({required this.updateHistories, required this.historyIndex});

  factory HistoryData.empty() {
    return HistoryData(updateHistories: [], historyIndex: -1);
  }

  factory HistoryData.fromJson(Map<String, dynamic> json) => _$HistoryDataFromJson(json);
  Map<String, dynamic> toJson() => _$HistoryDataToJson(this);
  // ignore: unused_element
  static void _keepLinterHappy() => HistoryData(updateHistories: [], historyIndex: 0).toJson();
}
