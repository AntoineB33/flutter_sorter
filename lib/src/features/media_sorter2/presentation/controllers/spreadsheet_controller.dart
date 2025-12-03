import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cell.dart';
import '../../data/datasources/spreadsheet_datasource.dart';
import '../../data/repositories/spreadsheet_repository_impl.dart';
import '../../domain/usecases/spreadsheet_usecases.dart';

// --- Dependency Injection Layer ---

// 1. Data Source Provider
final dataSourceProvider = Provider<SpreadsheetDataSource>((ref) {
  return InMemorySpreadsheetDataSource();
});

// 2. Repository Provider
final repositoryProvider = Provider<SpreadsheetRepository>((ref) {
  return SpreadsheetRepositoryImpl(ref.watch(dataSourceProvider));
});

// 3. Use Case Providers
final getSheetUseCaseProvider = Provider<GetSheetUseCase>((ref) {
  return GetSheetUseCase(ref.watch(repositoryProvider));
});

final updateCellUseCaseProvider = Provider<UpdateCellUseCase>((ref) {
  return UpdateCellUseCase(ref.watch(repositoryProvider));
});

// --- Controller Layer ---

// The State definition
class SpreadsheetState {
  final bool isLoading;
  final Map<String, Cell> cells; // Key format: "row:col"

  SpreadsheetState({this.isLoading = false, this.cells = const {}});
}

// The Controller (Notifier)
class SpreadsheetNotifier extends StateNotifier<SpreadsheetState> {
  final GetSheetUseCase _getSheet;
  final UpdateCellUseCase _updateCell;

  SpreadsheetNotifier(this._getSheet, this._updateCell)
      : super(SpreadsheetState(isLoading: true)) {
    loadSheet();
  }

  Future<void> loadSheet() async {
    try {
      final cells = await _getSheet();
      state = SpreadsheetState(isLoading: false, cells: cells);
    } catch (e) {
      // Handle error state
      state = SpreadsheetState(isLoading: false, cells: state.cells);
    }
  }

  Future<void> onCellChanged(int row, int col, String value) async {
    // Optimistic update: Update UI immediately before server response
    final key = '$row:$col';
    final currentCells = Map<String, Cell>.from(state.cells);
    
    currentCells[key] = Cell(row: row, col: col, value: value);
    state = SpreadsheetState(isLoading: false, cells: currentCells);

    // Call API in background
    try {
      await _updateCell(row, col, value);
    } catch (e) {
      // Revert if failed (omitted for brevity)
      print("Failed to save cell: $e");
    }
  }
}

// The Logic Provider
final spreadsheetControllerProvider =
    StateNotifierProvider<SpreadsheetNotifier, SpreadsheetState>((ref) {
  return SpreadsheetNotifier(
    ref.watch(getSheetUseCaseProvider),
    ref.watch(updateCellUseCaseProvider),
  );
});