import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_type.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart'; // For SyncRequestWithoutHist

part 'update_history_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UpdateHistoryModel {
  final DateTime timestamp;
  final int chronoId;
  final int sheetId;
  final List<SyncRequestWithoutHist> updates;
  final HistoryType type;

  UpdateHistoryModel({
    required this.timestamp,
    required this.chronoId,
    required this.sheetId,
    required this.updates,
    required this.type,
  });

  factory UpdateHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateHistoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateHistoryModelToJson(this);
  // ignore: unused_element
  static void _keepLinterHappy() => UpdateHistoryModel(
    timestamp: DateTime.now(),
    chronoId: 0,
    sheetId: 0,
    updates: [],
    type: HistoryType.other,
  ).toJson();
}