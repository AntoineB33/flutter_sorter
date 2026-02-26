import 'dart:math';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part 'update_data.g.dart';

sealed class UpdateData {
  final DateTime timestamp;
  UpdateData(this.timestamp);
  
  // 1. Polymorphic Deserialization
  factory UpdateData.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    
    // Switch on the discriminator key to return the correct subclass
    return switch (type) {
      'sheetName' => SheetNameUpdate.fromJson(json),
      'cell' => CellUpdate.fromJson(json),
      'columnType' => ColumnTypeUpdate.fromJson(json),
      _ => throw FormatException('Unknown UpdateData type: $type'),
    };
  }

  // 2. Polymorphic Serialization
  Map<String, dynamic> toJson() {
    // Dart 3 exhaustiveness checking ensures we don't miss a subclass
    return switch (this) {
      SheetNameUpdate s => s.toJson()..['type'] = 'sheetName',
      CellUpdate c => c.toJson()..['type'] = 'cell',
      ColumnTypeUpdate ct => ct.toJson()..['type'] = 'columnType',
    };
  }
}

@JsonSerializable()
class SheetNameUpdate extends UpdateData {
  final String newName;
  final String? previousName;

  SheetNameUpdate(super.timestamp, this.newName, this.previousName);
  
  factory SheetNameUpdate.fromJson(Map<String, dynamic> json) =>
      _$SheetNameUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SheetNameUpdateToJson(this);
}

@JsonSerializable()
class CellUpdate extends UpdateData {
  int rowId;
  int colId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Point<int> cell;
  String previousValue;
  String newValue;
  CellUpdate(super.timestamp, this.rowId, this.colId,
    this.newValue,
    {this.previousValue = "",
  }) : cell = Point<int>(rowId, colId);

  factory CellUpdate.fromJson(Map<String, dynamic> json) =>
      _$CellUpdateFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$CellUpdateToJson(this);
}

@JsonSerializable()
class ColumnTypeUpdate extends UpdateData {
  int colId;
  ColumnType newColumnType;
  ColumnType? previousColumnType;
  ColumnTypeUpdate(super.timestamp, this.colId,
    this.newColumnType,
    this.previousColumnType,
  );

  factory ColumnTypeUpdate.fromJson(Map<String, dynamic> json) =>
      _$ColumnTypeUpdateFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$ColumnTypeUpdateToJson(this);
}
