import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/update_history_model.dart';

part 'history_data.g.dart';


@JsonSerializable(explicitToJson: true)
class HistoryData {
  List<UpdateHistoryModel> updateHistories;
  int historyIndex;

  HistoryData({required this.updateHistories, required this.historyIndex});

  factory HistoryData.empty() {
    return HistoryData(updateHistories: [], historyIndex: -1);
  }

  factory HistoryData.fromJson(Map<String, dynamic> json) =>
      _$HistoryDataFromJson(json);
  Map<String, dynamic> toJson() => _$HistoryDataToJson(this);
  // ignore: unused_element
  static void _keepLinterHappy() =>
      HistoryData(updateHistories: [], historyIndex: 0).toJson();
}
