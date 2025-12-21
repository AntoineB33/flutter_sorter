class Attribute {
  final String? name;
  final int? rowId;
  final int? colId;

  Attribute({this.name, this.rowId, this.colId});

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
}
