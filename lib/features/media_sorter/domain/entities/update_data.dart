import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part 'update_data.g.dart';

@JsonSerializable(explicitToJson: true)
class UpdateData extends UpdateUnit {
  final DateTime timestamp;
  final int chronoId;
  final int sheetId;
  final Map<Record, UpdateUnit> updates;
  bool addOtherwiseRemove;
  UpdateData(
    this.chronoId,
    this.sheetId,
    this.updates,
    this.addOtherwiseRemove,{
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  Record getRecord() {
    return ('updateData', timestamp, chronoId, sheetId);
  }

  factory UpdateData.fromJson(Map<String, dynamic> json) =>
      _$UpdateDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UpdateDataToJson(this);
}

sealed class UpdateUnit {
  const UpdateUnit();

  Record getRecord();

  factory UpdateUnit.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case CellUpdate.type:
        return CellUpdate.fromJson(json);
      case ColumnTypeUpdate.type:
        return ColumnTypeUpdate.fromJson(json);
      case SheetDataUpdate.type:
        return SheetDataUpdate.fromJson(json);
      default:
        throw Exception('Unknown UpdateUnit type: ${json['type']}');
    }
  }

  Map<String, dynamic> toJson();
}

@JsonSerializable()
class SheetDataUpdate extends UpdateUnit {
  static const String type = 'SheetDataUpdate';
  final int sheetId;
  final String? newName;
  String? prevName;
  final int? historyIndex;
  int? prevHistoryIndex;
  final double? colHeaderHeight;
  double? prevColHeaderHeight;
  final double? rowHeaderWidth;
  double? prevRowHeaderWidth;
  final int? primarySelectedCellX;
  double? prevPrimarySelectedCellX;
  final int? primarySelectedCellY;
  double? prevPrimarySelectedCellY;
  final double? scrollOffsetX;
  double? prevScrollOffsetX;
  final double? scrollOffsetY;
  double? prevScrollOffsetY;
  final int? sortIndex;
  int? prevSortIndex;

  SheetDataUpdate(this.sheetId, {this.newName, this.historyIndex, this.colHeaderHeight, this.rowHeaderWidth, this.primarySelectedCellX, this.primarySelectedCellY, this.scrollOffsetX, this.scrollOffsetY, this.sortIndex});

  @override
  Record getRecord() {
    return (type, sheetId);
  }

  factory SheetDataUpdate.fromJson(Map<String, dynamic> json) =>
      _$SheetDataUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SheetDataUpdateToJson(this);
}

@JsonSerializable()
class CellUpdate extends UpdateUnit {
  static const String type = 'CellUpdate';
  final int sheetId;
  final int rowId;
  final int colId;
  String? prevValue;
  String newValue;
  CellUpdate(
    this.sheetId,
    this.rowId,
    this.colId,
    this.newValue, {
    this.prevValue,
  });

  @override
  String getRecord() {
    return 'CellUpdate-$sheetId-$rowId-$colId';
  }

  factory CellUpdate.fromJson(Map<String, dynamic> json) =>
      _$CellUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CellUpdateToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ColumnTypeUpdate extends UpdateUnit {
  static const String type = 'ColumnTypeUpdate';
  final int sheetId;
  final int colId;
  final ColumnType newColumnType;
  ColumnType? previousColumnType;
  ColumnTypeUpdate(
    this.sheetId,
    this.colId,
    this.newColumnType, {
    this.previousColumnType,
  });

  @override
  String getRecord() {
    return 'ColumnTypeUpdate-$sheetId-$colId';
  }

  factory ColumnTypeUpdate.fromJson(Map<String, dynamic> json) =>
      _$ColumnTypeUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ColumnTypeUpdateToJson(this);
}
