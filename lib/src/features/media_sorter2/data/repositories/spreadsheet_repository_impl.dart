import '../../domain/entities/cell.dart';
import '../datasources/spreadsheet_datasource.dart';
import '../../domain/repositories/spreadsheet_repository.dart';


// 2. The Implementation (Belongs in Data layer)
class SpreadsheetRepositoryImpl implements SpreadsheetRepository {
  final SpreadsheetDataSource dataSource;

  SpreadsheetRepositoryImpl(this.dataSource);

  @override
  Future<Map<String, Cell>> loadSheet() async {
    return await dataSource.fetchSheet();
  }

  @override
  Future<Cell> saveCell(int row, int col, String value) async {
    return await dataSource.updateCell(row, col, value);
  }
}