
import 'package:json_annotation/json_annotation.dart';

part 'attribute.g.dart';

@JsonSerializable()
class Attribute {
  final String? name;
  int? rowId;
  final int? colId;

  // 1. Private constructor: Cannot be called directly
  Attribute._({this.name, this.rowId, this.colId});

  // ✅ FIX: Add 'factory' keyword
  factory Attribute({String? name, int? colId}) {
    return Attribute._(name: name, rowId: null, colId: colId);
  }

  // 2. Row-specific constructor: Accepts ONLY rowId
  factory Attribute.row(int rowId) {
    return Attribute._(rowId: rowId);
  }

  bool isRow() {
    return rowId != null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Attribute &&
        name == other.name &&
        rowId == other.rowId &&
        colId == other.colId;
  }

  @override
  int get hashCode => Object.hash(name, rowId, colId);

  factory Attribute.fromJson(Map<String, dynamic> json) => 
      _$AttributeFromJson(json);
  
  Map<String, dynamic> toJson() => _$AttributeToJson(this);
}
