import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/media_sorter_injection.dart';
import 'app.dart';
import 'core/services/storage_service.dart';
import 'injection_container.dart' as di;
import 'package:logging/logging.dart';

void main() async {
  _setupLogging();

  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize the dependencies
  initMediaSorterDependencies();

  // Load the saved route before the app interface renders
  final String savedRoute = await StorageService.getLastRoute();


  // // 1. Catch Widget / Layout exceptions
  // FlutterError.onError = (FlutterErrorDetails details) {
  //   FlutterError.presentError(details); // Keeps the standard console logging
    
  //   // 🔴 PLACE A BREAKPOINT ON THE LINE BELOW 🔴
  //   debugPrint('Widget Error Intercepted: ${details.exception}'); 
  // };

  // // 2. Catch Asynchronous / Future exceptions (Optional but recommended)
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   // 🔴 PLACE A BREAKPOINT ON THE LINE BELOW 🔴
  //   debugPrint('Async Error Intercepted: $error');
  //   return true;
  // };

  runApp(MyApp(initialRoute: savedRoute));
}

// Helper function to keep main() clean
void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });
  // You might need to make 'log' accessible or create a local instance
  final log = Logger('Main'); 
  log.info("Logger initialized");
}