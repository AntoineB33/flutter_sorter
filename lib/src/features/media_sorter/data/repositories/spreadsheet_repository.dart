import '../../domain/repositories/i_spreadsheet_repository.dart';
import '../data_sources/spreadsheet_local_data_source.dart';

class SpreadsheetRepository implements ISpreadsheetRepository {
  final SpreadsheetLocalDataSource dataSource;

  SpreadsheetRepository(this.dataSource);

  @override
  Future<void> saveSpreadsheet({
    required String name, 
    required List<List<String>> table, 
    required List<String> columnTypes
  }) async {
    // Construct the data map here or in a Model toJson() method
    final data = {
      "table": table, 
      "columnTypes": columnTypes
    };
    
    await dataSource.saveSpreadsheetData(name, data);
  }
}