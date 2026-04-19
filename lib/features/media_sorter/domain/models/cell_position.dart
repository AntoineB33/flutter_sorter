

import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class CellPosition {
  final int rowId;
  final int colId;
  CellPosition(this.rowId, this.colId);

  factory CellPosition.fromJson(Map<String, dynamic> json) =>
      _$CellPositionFromJson(json);
  Map<String, dynamic> toJson() => _$CellPositionToJson(this);
  // ignore: unused_element
  static void _keepLinterHappy() => CellPosition(0, 0).toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellPosition &&
          runtimeType == other.runtimeType &&
          rowId == other.rowId &&
          colId == other.colId;

  @override
  int get hashCode => rowId.hashCode ^ colId.hashCode;
}