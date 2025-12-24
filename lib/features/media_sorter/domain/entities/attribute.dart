class Attribute {
  final String? name;
  final int? rowId;
  final int? colId;

  // 1. Private constructor: Cannot be called directly
  const Attribute._({this.name, this.rowId, this.colId});

  // ✅ FIX: Add 'factory' keyword
  factory Attribute({String? name, int? colId}) {
    return Attribute._(name: name, rowId: null, colId: colId);
  }

  // 2. Row-specific constructor: Accepts ONLY rowId
  factory Attribute.row(int rowId) {
    return Attribute._(rowId: rowId);
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
}
