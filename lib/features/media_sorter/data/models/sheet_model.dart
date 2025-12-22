class SheetModel {
  final List<List<String>> table;
  final List<String> columnTypes;

  SheetModel({required this.table, required this.columnTypes});

  // This factory handles the ugly 'dynamic' parsing in one isolated place
  factory SheetModel.fromJson(Map<String, dynamic> json) {
    var rawTable = json['table'] as List? ?? [];
    
    // Safely convert the table, handling non-string values gracefully
    List<List<String>> parsedTable = rawTable.map((row) {
      if (row is List) {
        return row.map((cell) => cell.toString()).toList();
      }
      return <String>[]; // Handle malformed rows safely
    }).toList();

    var rawTypes = json['columnTypes'] as List? ?? [];
    List<String> parsedTypes = rawTypes.map((e) => e.toString()).toList();

    return SheetModel(table: parsedTable, columnTypes: parsedTypes);
  }
  
  Map<String, dynamic> toJson() => {
    'table': table,
    'columnTypes': columnTypes,
  };
}