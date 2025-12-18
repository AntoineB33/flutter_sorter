class Cell {
  final int row;
  final int col;

  Cell({
    required this.row,
    required this.col
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Cell &&
        row == other.row &&
        col == other.col;
  }

  @override
  int get hashCode => Object.hash(row, col);
}
