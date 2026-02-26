import 'package:json_annotation/json_annotation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';

part 'sheet_content.g.dart';

@JsonSerializable()
class SheetContent {
  List<List<String>> table;
  List<ColumnType> columnTypes;

  SheetContent({
    required this.table,
    required this.columnTypes
  });

  factory SheetContent.fromJson(Map<String, dynamic> json) => 
      _$SheetContentFromJson(json);

  Map<String, dynamic> toJson() => _$SheetContentToJson(this);
}