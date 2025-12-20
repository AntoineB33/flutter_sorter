class Cell {
  final int rowId;
  final int colId;

  Cell({required this.rowId, required this.colId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Cell && rowId == other.rowId && colId == other.colId;
  }

  @override
  int get hashCode => Object.hash(rowId, colId);
}
