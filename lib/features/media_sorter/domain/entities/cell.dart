import 'package:json_annotation/json_annotation.dart';

part 'cell.g.dart';

@JsonSerializable()
class Cell {
  int rowId;
  final int colId;

  Cell({required this.rowId, required this.colId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cell && rowId == other.rowId && colId == other.colId;

  @override
  int get hashCode => Object.hash(rowId, colId);

  factory Cell.fromJson(Map<String, dynamic> json) => _$CellFromJson(json);
  Map<String, dynamic> toJson() => _$CellToJson(this);
}