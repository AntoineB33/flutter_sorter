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
  UpdateData(this.chronoId, this.sheetId, this.updates, {this.addOtherwiseRemove = false, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
  
  String getStringKey() {
    return 'UpdateData-$timestamp-$chronoId';
  }

  bool isStringKey(String key) {
    return key.startsWith('UpdateData-');
  }

  factory UpdateData.fromJson(Map<String, dynamic> json) =>
      _$UpdateDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UpdateDataToJson(this);
}

sealed class UpdateUnit {
  const UpdateUnit();

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

class Pass extends UpdateUnit {
  Pass();
  factory Pass.fromJson() => Pass();
  @override
  Map<String, dynamic> toJson() => {};
}

@JsonSerializable()
class SheetNameUpdate extends UpdateUnit {
  final String type = 'SheetNameUpdate';
  final String newName;
  String? previousName;

  SheetNameUpdate(this.newName, {this.previousName});

  factory SheetNameUpdate.fromJson(Map<String, dynamic> json) =>
      _$SheetNameUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SheetNameUpdateToJson(this);
}

@JsonSerializable()
class CellUpdate extends UpdateUnit {
  final String type = 'CellUpdate';
  final int rowId;
  final int colId;
  String? prevValue;
  String newValue;
  CellUpdate(this.rowId, this.colId, this.newValue, {this.prevValue});

  String getStringKey() {
    return 'CellUpdate-$rowId-$colId';
  }

  factory CellUpdate.fromJson(Map<String, dynamic> json) =>
      _$CellUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CellUpdateToJson(this);
}

@JsonSerializable()
class ColumnTypeUpdate extends UpdateUnit {
  final String type = 'ColumnTypeUpdate';
  final int colId;
  final ColumnType newColumnType;
  ColumnType? previousColumnType;
  ColumnTypeUpdate(this.colId, this.newColumnType, {this.previousColumnType});

  factory ColumnTypeUpdate.fromJson(Map<String, dynamic> json) =>
      _$ColumnTypeUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ColumnTypeUpdateToJson(this);
}
