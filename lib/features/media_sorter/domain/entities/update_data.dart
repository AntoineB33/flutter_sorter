import 'dart:math';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part 'update_data.g.dart';

class UpdateData {
  final DateTime timestamp;
  final int chronoId;
  final String sheetId;
  final List<UpdateUnit> updates;
  UpdateData(this.chronoId, this.sheetId, this.updates) : timestamp = DateTime.now();
}

sealed class UpdateUnit {}

@JsonSerializable()
class SheetNameUpdate extends UpdateUnit {
  final String newName;
  final String? previousName;

  SheetNameUpdate(this.newName, this.previousName);

  factory SheetNameUpdate.fromJson(Map<String, dynamic> json) =>
      _$SheetNameUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$SheetNameUpdateToJson(this);
}

@JsonSerializable()
class CellUpdate extends UpdateUnit {
  int rowId;
  int colId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String prevValue;
  String newValue;
  CellUpdate(this.rowId, this.colId, this.newValue, this.prevValue);

  factory CellUpdate.fromJson(Map<String, dynamic> json) =>
      _$CellUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$CellUpdateToJson(this);
}

@JsonSerializable()
class ColumnTypeUpdate extends UpdateUnit {
  int colId;
  ColumnType newColumnType;
  ColumnType? previousColumnType;
  ColumnTypeUpdate(this.colId, this.newColumnType, this.previousColumnType);

  factory ColumnTypeUpdate.fromJson(Map<String, dynamic> json) =>
      _$ColumnTypeUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$ColumnTypeUpdateToJson(this);
}