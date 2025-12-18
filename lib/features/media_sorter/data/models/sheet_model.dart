

// class SheetModel {
//   final List<List<String>> table;
//   final List<String> columnTypes;
//   // ... other fields

//   factory SheetModel.fromJson(Map<String, dynamic> json) {
//     // Move the parsing logic here
//     final rawTable = json["table"] as List?;
//     // ... logic from repository ...
//     return SheetModel(...);
//   }

//   Map<String, dynamic> toJson() => { ... };
// }