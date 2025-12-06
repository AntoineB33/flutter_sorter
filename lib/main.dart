import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/storage_service.dart';
import 'injection_container.dart' as di;
import 'package:logging/logging.dart';

void main() async {
  _setupLogging();

  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize the dependencies

  // Load the saved route before the app interface renders
  final String savedRoute = await StorageService.getLastRoute();

  runApp(MyApp(initialRoute: savedRoute));
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