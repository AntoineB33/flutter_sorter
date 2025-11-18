class Cell {
  final int row;
  final int col;
  final String value;

  Cell({
    required this.row,
    required this.col,
    required this.value,
  });

  Cell copyWith({String? value}) {
    return Cell(
      row: row,
      col: col,
      value: value ?? this.value,
    );
  }
}
