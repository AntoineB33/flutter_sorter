import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cell.dart';
import '../../data/datasources/spreadsheet_datasource.dart';
import '../../data/repositories/spreadsheet_repository_impl.dart';
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

// We replace StateNotifier with AsyncNotifier.
// The state is simply the Map of cells.
class SpreadsheetController extends AsyncNotifier<Map<String, Cell>> {
  
  // 1. Initialize State
  @override
  FutureOr<Map<String, Cell>> build() async {
    final getSheet = ref.read(getSheetUseCaseProvider);
    return await getSheet();
  }

  // 2. Update Logic
  Future<void> onCellChanged(int row, int col, String value) async {
    final updateCell = ref.read(updateCellUseCaseProvider);
    final key = '$row:$col';

    // Current state check to avoid null issues
    final currentMap = state.valueOrNull ?? {};

    // Optimistic Update: Create a new map with the updated value immediately
    final updatedMap = Map<String, Cell>.from(currentMap);
    updatedMap[key] = Cell(row: row, col: col, value: value);

    // Update the local state immediately so the UI reflects the change
    state = AsyncData(updatedMap);

    // Perform API call in background
    try {
      await updateCell(row, col, value);
    } catch (e, stack) {
      // If API fails, revert state (optional, or show error)
      state = AsyncError<Map<String, Cell>>(e, stack).copyWithPrevious(state);
    }
  }
}

// 3. The Provider
final spreadsheetControllerProvider =
    AsyncNotifierProvider<SpreadsheetController, Map<String, Cell>>(
        SpreadsheetController.new);