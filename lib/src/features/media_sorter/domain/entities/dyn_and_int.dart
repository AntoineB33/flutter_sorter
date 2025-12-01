class DynAndInt {
  dynamic dyn;
  int id;

  DynAndInt(this.dyn, this.id);
}

class AttAndCol {
  dynamic name;
  dynamic col;

  AttAndCol(this.name, this.col);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AttAndCol && name == other.name && col == other.col;
  }

  @override
  int get hashCode => Object.hash(name, col);
}
