import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import 'app.dart'; // Import the new App file
import 'logger.dart'; // Assuming this is your custom logger helper
import 'src/features/media_sorter/data/repositories/spreadsheet_data_repository.dart';
import 'src/features/media_sorter/domain/usecases/analyze_table_usecase.dart';
import 'src/features/media_sorter/domain/usecases/copy_selection_usecase.dart';
import 'src/features/media_sorter/domain/usecases/get_table_data_usecase.dart';
import 'src/features/media_sorter/presentation/logic/spreadsheet_controller.dart';


void main() {
  _setupLogging();

  // 1. The Source of Truth (Created once, stays alive)
  final repository = SpreadsheetDataRepository(); 

  // 2. The UseCases (The "Verbs" of your app)
  final analyzeUseCase = AnalyzeTableUseCase(ComputeService(), repository);
  final copyUseCase = CopySelectionUseCase(repository, ClipboardService());
  final getTableUseCase = GetTableDataUseCase(repository); // Needed to display data!

  // 3. The Controller (Receives the "Verbs")
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SpreadsheetController(
            analyzeUseCase, 
            copyUseCase,
            getTableUseCase,
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

// Helper function to keep main() clean
void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  // You might need to make 'log' accessible or create a local instance
  final log = Logger('Main'); 
  log.info("Logger initialized");
}