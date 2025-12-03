class Cell {
  final int row;
  final int col;
  final String value;

  const Cell({
    required this.row,
    required this.col,
    required this.value,
  });

  Cell copyWith({
    int? row,
    int? col,
    String? value,
  }) {
    return Cell(
      row: row ?? this.row,
      col: col ?? this.col,
      value: value ?? this.value,
    );
  }
}