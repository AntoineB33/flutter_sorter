import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'logic/spreadsheet_state.dart';
import 'presentation/pages/home_page.dart';
import 'package:logging/logging.dart';
import 'logger.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  log.info("Logger initialized");
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SpreadsheetState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spreadsheet Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
