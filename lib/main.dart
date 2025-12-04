import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart'; // Import the new App file
import 'logger.dart'; // Assuming this is your custom logger helper


void main() {
  _setupLogging();

  runApp(
    // ProviderScope is required for Riverpod to work
    const ProviderScope(
      child: SpreadsheetApp(),
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