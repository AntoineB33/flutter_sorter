import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part 'update_data.g.dart';

@JsonSerializable(explicitToJson: true)
class UpdateData extends UpdateUnit {
  final DateTime timestamp;
  final int chronoId;
  final int sheetId;
  final Map<String, UpdateUnit> updates;
  bool addOtherwiseRemove;
  UpdateData(
    this.chronoId,
    this.sheetId,
    this.updates, {
    this.addOtherwiseRemove = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

    @override
  String getStringKey() {
    return 'UpdateData-$timestamp-$chronoId';
  }

  factory UpdateData.fromJson(Map<String, dynamic> json) =>
      _$UpdateDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UpdateDataToJson(this);
}

sealed class UpdateUnit {
  const UpdateUnit();

  String getStringKey();

  factory UpdateUnit.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'CellUpdate':
        return CellUpdate.fromJson(json);
      case 'ColumnTypeUpdate':
        return ColumnTypeUpdate.fromJson(json);
      case 'SheetNameUpdate':
        return SheetNameUpdate.fromJson(json);
      default:
        throw Exception('Unknown UpdateUnit type: ${json['type']}');
    }
  }

  Map<String, dynamic> toJson();
}

@JsonSerializable()
class HistoryIndexChg extends UpdateUnit {
  final int sheetId;
  final int historyIndex;
  HistoryIndexChg(this.sheetId, this.historyIndex);
  @override
  String getStringKey() {
    return 'historyIndex-$sheetId';
  }
  factory HistoryIndexChg.fromJson(Map<String, dynamic> json) =>
    _$HistoryIndexChgFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$HistoryIndexChgToJson(this);
}

@JsonSerializable()
class CellUpdate extends UpdateUnit {
  final String type = 'CellUpdate';
  final int sheetId;
  final int rowId;
  final int colId;
  String? prevValue;
  String newValue;
  CellUpdate(this.sheetId, this.rowId, this.colId, this.newValue, {this.prevValue});

  @override
  String getStringKey() {
    return 'CellUpdate-$sheetId-$rowId-$colId';
  }

  factory CellUpdate.fromJson(Map<String, dynamic> json) =>
      _$CellUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CellUpdateToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ColumnTypeUpdate extends UpdateUnit {
  final String type = 'ColumnTypeUpdate';
  final int sheetId;
  final int colId;
  final ColumnType newColumnType;
  ColumnType? previousColumnType;
  ColumnTypeUpdate(this.sheetId, this.colId, this.newColumnType, {this.previousColumnType});

  @override
  String getStringKey() {
    return 'ColumnTypeUpdate-$sheetId-$colId';
  }

  factory ColumnTypeUpdate.fromJson(Map<String, dynamic> json) =>
      _$ColumnTypeUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ColumnTypeUpdateToJson(this);
}
