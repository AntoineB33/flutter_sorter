class DynAndInt {
  dynamic dyn;
  int id;

  DynAndInt(this.dyn, this.id);
}

class Attribute {
  final String? name;
  final int? row;
  final int? col;

  const Attribute({this.name, this.row, this.col});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Attribute &&
        name == other.name &&
        row == other.row &&
        col == other.col;
  }

  @override
  int get hashCode => Object.hash(name, row, col);
}
