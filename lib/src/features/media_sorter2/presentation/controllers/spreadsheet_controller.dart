import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cell.dart';
import '../../data/datasources/spreadsheet_datasource.dart';
import '../../data/repositories/spreadsheet_repository_impl.dart';
import '../../domain/repositories/spreadsheet_repository.dart';
import '../../domain/usecases/spreadsheet_usecases.dart';

// --- Dependency Injection (Unchanged) ---
final dataSourceProvider = Provider<SpreadsheetDataSource>((ref) {
  return InMemorySpreadsheetDataSource();
});

final repositoryProvider = Provider<SpreadsheetRepository>((ref) {
  return SpreadsheetRepositoryImpl(ref.watch(dataSourceProvider));
});

final getSheetUseCaseProvider = Provider<GetSheetUseCase>((ref) {
  return GetSheetUseCase(ref.watch(repositoryProvider));
});

final updateCellUseCaseProvider = Provider<UpdateCellUseCase>((ref) {
  return UpdateCellUseCase(ref.watch(repositoryProvider));
});

// --- Controller Layer ---

class SpreadsheetController extends FamilyAsyncNotifier<Map<String, Cell>, String> {
  late String _sheetId;

  @override
  FutureOr<Map<String, Cell>> build(String arg) async {
    _sheetId = arg;
    // Load specific sheet data from DB
    return await ref.read(getSheetUseCaseProvider).execute(_sheetId);
  }

  Future<void> onCellChanged(int row, int col, String value) async {
    final key = '$row:$col';
    final currentMap = state.valueOrNull ?? {};

    // PERFORMANCE FIX: Use an immutable map library or a row-based structure here
    // For now, standard optimization:
    state = AsyncData({...currentMap, key: Cell(row: row, col: col, value: value)}); 
    
    // Save to DB
    ref.read(updateCellUseCaseProvider).execute(_sheetId, row, col, value);
  }
}

// 3. The Provider
final spreadsheetControllerProvider =
    AsyncNotifierProvider<SpreadsheetController, Map<String, Cell>>(
        SpreadsheetController.new);