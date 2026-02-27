import 'dart:math';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part 'update_data.g.dart';

@JsonSerializable()
class UpdateData {
  final String id;
  final DateTime timestamp;
  @UpdateUnitConverter()
  final List<UpdateUnit> updates;

  UpdateData(this.id, this.timestamp, this.updates);

  factory UpdateData.fromJson(Map<String, dynamic> json) =>
      _$UpdateDataFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateDataToJson(this);
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
  Point<int> cell;
  String prevValue;
  String newValue;
  CellUpdate(
    this.rowId,
    this.colId,
    this.newValue,
    this.prevValue) : cell = Point<int>(rowId, colId);

  factory CellUpdate.fromJson(Map<String, dynamic> json) =>
      _$CellUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$CellUpdateToJson(this);
}

@JsonSerializable()
class ColumnTypeUpdate extends UpdateUnit {
  int colId;
  ColumnType newColumnType;
  ColumnType? previousColumnType;
  ColumnTypeUpdate(
    this.colId,
    this.newColumnType,
    this.previousColumnType,
  );

  factory ColumnTypeUpdate.fromJson(Map<String, dynamic> json) =>
      _$ColumnTypeUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$ColumnTypeUpdateToJson(this);
}

class UpdateUnitConverter implements JsonConverter<UpdateUnit, Map<String, dynamic>> {
  const UpdateUnitConverter();

  @override
  UpdateUnit fromJson(Map<String, dynamic> json) {
    // Look for a 'type' key to figure out which subclass to build
    final type = json['type'] as String?;
    
    switch (type) {
      case 'SheetNameUpdate':
        return SheetNameUpdate.fromJson(json);
      case 'CellUpdate':
        return CellUpdate.fromJson(json);
      case 'ColumnTypeUpdate':
        return ColumnTypeUpdate.fromJson(json);
      default:
        throw ArgumentError('Unknown UpdateUnit type: $type');
    }
  }

  @override
  Map<String, dynamic> toJson(UpdateUnit object) {
    // Serialize the specific subclass and inject the 'type' discriminator
    if (object is SheetNameUpdate) {
      return object.toJson()..['type'] = 'SheetNameUpdate';
    } else if (object is CellUpdate) {
      return object.toJson()..['type'] = 'CellUpdate';
    } else if (object is ColumnTypeUpdate) {
      return object.toJson()..['type'] = 'ColumnTypeUpdate';
    }
    throw ArgumentError('Unknown UpdateUnit instance');
  }
}