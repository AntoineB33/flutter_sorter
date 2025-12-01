import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';

import 'app.dart'; // Import the new App file
import 'logger.dart'; // Assuming this is your custom logger helper
// Update import to match your structure
import 'src/features/spreadsheet/presentation/logic/spreadsheet_state.dart'; 

void main() {
  _setupLogging();

  runApp(
    // We wrap the app in the Providers here so the whole App has access
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SpreadsheetState()),
      ],
      child: const MyApp(),
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