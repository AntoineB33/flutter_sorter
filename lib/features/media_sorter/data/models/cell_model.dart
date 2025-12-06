import 'package:isar/isar.dart';

// This line is crucial. It tells the generator where to write the file.
// format: part 'filename.g.dart';
part 'cell_model.g.dart'; 

@collection
class CellModel {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('col')]) 
  late int row;
  
  late int col;
  
  late String value;
}